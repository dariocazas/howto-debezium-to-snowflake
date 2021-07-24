-- Based on: 
-- https://docs.snowflake.com/en/user-guide/data-pipelines-examples.html#transforming-loaded-json-data-on-a-schedule
-- https://docs.snowflake.com/en/sql-reference/sql/merge.html


create or replace 
    stream "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET_STREAM_REPLICATION" 
    on table "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET";

create or replace 
    table "DEMO_DB"."PUBLIC"."REPLICA_MYSQL_INVENTORY_PET" 
    ( id number PRIMARY KEY comment 'primary key of the source table'
    , cdc_ts_ms number comment 'the timestamp when the CDC connector capture the event (RECORD_CONTENT:payload.ts_ms)'
    , src_db_ts_ms number comment 'the timestamp when database register the event, not available on database snapshot (RECORD_CONTENT:payload.source.ts_ms)'
    , src_db_pos number comment 'database sequential generated, not available on database snapshot or row insert (RECORD_CONTENT:payload.source.pos)'
    , replication_task_ts_ms number comment 'the timestamp when snowflake task fills the record'
    , payload variant comment 'data after operation'
    , cdc_operation char comment 'CDC registrer operation in source DB')
comment = 'Replica from CDC over Mysql Inventory Pet'
;

create or replace task "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET_TASK_REPLICATION"
    warehouse = compute_wh
    schedule = '1 minute'
    allow_overlapping_execution = false
    when
        system$stream_has_data('DEMO_DB.PUBLIC.CDC_MYSQL_INVENTORY_PET_STREAM_REPLICATION')
    as
        merge into "DEMO_DB"."PUBLIC"."REPLICA_MYSQL_INVENTORY_PET" n
        using 
            (with 
                prequery as (select RECORD_METADATA:key.payload.id id
                    , RECORD_CONTENT:payload.ts_ms cdc_ts_ms
                    , RECORD_CONTENT:payload.source.ts_ms src_db_ts_ms
                    , RECORD_CONTENT:payload.source.pos src_db_pos
                    , RECORD_CONTENT:payload.after payload
                    , RECORD_CONTENT:payload.op cdc_operation
                    from "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET_STREAM_REPLICATION"),
                rank_query as (select *
                    , ROW_NUMBER() over (PARTITION BY id order by src_db_ts_ms desc, src_db_pos desc, cdc_ts_ms desc) as rn
                    from prequery)
                select id, cdc_ts_ms, src_db_ts_ms, src_db_pos, payload, cdc_operation
                from rank_query
                where rn = 1) r1
            on n.id = to_number(r1.id)
        when not matched and r1.cdc_operation <> 'd' 
            then insert 
                (id, cdc_ts_ms, src_db_ts_ms, src_db_pos, replication_task_ts_ms, payload, cdc_operation)
                values 
                (r1.id, r1.cdc_ts_ms, r1.src_db_ts_ms, r1.src_db_pos, date_part(epoch_millisecond, CURRENT_TIMESTAMP), r1.payload, r1.cdc_operation)
        when matched and r1.cdc_operation = 'd'
            then delete
        when matched and r1.cdc_operation <> 'd'
            then update set id=r1.id
                , cdc_ts_ms=r1.cdc_ts_ms
                , src_db_ts_ms=r1.src_db_ts_ms
                , src_db_pos=r1.src_db_pos
                , replication_task_ts_ms=date_part(epoch_millisecond, CURRENT_TIMESTAMP)
                , payload=r1.payload
                , cdc_operation=r1.cdc_operation
;

ALTER TASK "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET_TASK_REPLICATION" RESUME;

create or replace view "DEMO_DB"."PUBLIC"."MYSQL_INVENTORY_PET"
as 
    select payload:id id, payload:name name, payload:owner owner, payload:sex sex, payload:species species
    from "DEMO_DB"."PUBLIC"."REPLICA_MYSQL_INVENTORY_PET";

