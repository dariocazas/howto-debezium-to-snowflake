-- Based on: 
-- https://docs.snowflake.com/en/user-guide/data-pipelines-examples.html#transforming-loaded-json-data-on-a-schedule
-- https://docs.snowflake.com/en/sql-reference/sql/merge.html


-- To simplify the howto, we only use role sysadmin. Remember review/apply 00-security.sql script
use role sysadmin;


-- Create the replica table, including extra columns to support replica logic and process trazability
create or replace 
    table "DEMO_DB"."PUBLIC"."REPLICA_POSTGRESDB_INVENTORY_PRODUCT" 
    ( id number PRIMARY KEY comment 'primary key of the source table'
    , sourcedb_lsn string comment 'postgres log sequence number, used for ordering events (RECORD_CONTENT:payload.source.lsn)'
    , payload variant comment 'data after operation (RECORD_CONTENT:payload.after)'
    , cdc_operation char comment 'CDC registered operation in source DB (RECORD_CONTENT:payload.op)'
    , cdc_source_info variant comment 'Debezium source field, for trazability (RECORD_CONTENT:payload.source)'
    , ts_ms_sourcedb number comment 'the timestamp when database register the event, not available on database snapshot (RECORD_CONTENT:payload.source.ts_ms)'
    , ts_ms_cdc number comment 'the timestamp when the CDC connector capture the event (RECORD_CONTENT:payload.ts_ms)'
    , ts_ms_replica_sf number comment 'the timestamp when snowflake task fills the record')
comment = 'Replica from CDC over PostgreSQL Inventory Products';

-- Create final view with same columns as PostgreSQL database to use like the same table
create or replace view "DEMO_DB"."PUBLIC"."POSTGRESDB_INVENTORY_PRODUCT"
as 
    select payload:id id, payload:name name, payload:description description, payload:created_on created_on
    from "DEMO_DB"."PUBLIC"."REPLICA_POSTGRESDB_INVENTORY_PRODUCT";

-- Create a stream from CDC events table, to process new events into replica table
create or replace 
    stream "DEMO_DB"."PUBLIC"."CDC_POSTGRESDB_INVENTORY_PRODUCT_STREAM_REPLICATION" 
    on table "DEMO_DB"."PUBLIC"."CDC_POSTGRESDB_INVENTORY_PRODUCT";


-- After create stream (avoid loss events), process all events available in CDC events table
merge into "DEMO_DB"."PUBLIC"."REPLICA_POSTGRESDB_INVENTORY_PRODUCT" replica_table
    using 
        (with 
            prequery as (select RECORD_METADATA:key.payload.id id
                    , to_number(RECORD_CONTENT:payload.source.lsn) sourcedb_lsn
                    , RECORD_CONTENT:payload.after payload
                    , RECORD_CONTENT:payload.op cdc_operation
                    , RECORD_CONTENT:payload.source cdc_source_info
                    , RECORD_CONTENT:payload.source.ts_ms ts_ms_sourcedb
                    , RECORD_CONTENT:payload.ts_ms ts_ms_cdc                        
                from "DEMO_DB"."PUBLIC"."CDC_POSTGRESDB_INVENTORY_PRODUCT"),
            rank_query as (select *
                    , ROW_NUMBER() over (PARTITION BY id 
                        order by ts_ms_cdc desc, sourcedb_lsn desc) as row_num
                from prequery)
            select * from rank_query where row_num = 1) event_data
        on replica_table.id = to_number(event_data.id)
    when not matched and event_data.cdc_operation <> 'd' 
        then insert 
                (id, sourcedb_lsn, payload, cdc_operation, cdc_source_info, ts_ms_sourcedb
                , ts_ms_cdc, ts_ms_replica_sf)
            values 
                (event_data.id, event_data.sourcedb_lsn, event_data.payload, event_data.cdc_operation
                , event_data.cdc_source_info, event_data.ts_ms_sourcedb, event_data.ts_ms_cdc
                , date_part(epoch_millisecond, CURRENT_TIMESTAMP))
    when matched and event_data.cdc_operation = 'd'
        then delete
    when matched and event_data.cdc_operation <> 'd'
        then update set id=event_data.id
            , sourcedb_lsn=event_data.sourcedb_lsn
            , payload=event_data.payload
            , cdc_operation=event_data.cdc_operation
            , cdc_source_info=event_data.cdc_source_info
            , ts_ms_sourcedb=event_data.ts_ms_sourcedb
            , ts_ms_cdc=event_data.ts_ms_cdc
            , ts_ms_replica_sf=date_part(epoch_millisecond, CURRENT_TIMESTAMP);


-- Create task with previous tested query, but read data from the created stream (not CDC events table).
create or replace task "DEMO_DB"."PUBLIC"."CDC_POSTGRESDB_INVENTORY_PRODUCT_TASK_REPLICATION"
    warehouse = compute_wh
    schedule = '1 minute'
    allow_overlapping_execution = false
    when
        system$stream_has_data('DEMO_DB.PUBLIC.CDC_POSTGRESDB_INVENTORY_PRODUCT_STREAM_REPLICATION')
    as
merge into "DEMO_DB"."PUBLIC"."REPLICA_POSTGRESDB_INVENTORY_PRODUCT" replica_table
    using 
        (with 
            prequery as (select RECORD_METADATA:key.payload.id id
                    , to_number(RECORD_CONTENT:payload.source.lsn) sourcedb_lsn
                    , RECORD_CONTENT:payload.after payload
                    , RECORD_CONTENT:payload.op cdc_operation
                    , RECORD_CONTENT:payload.source cdc_source_info
                    , RECORD_CONTENT:payload.source.ts_ms ts_ms_sourcedb
                    , RECORD_CONTENT:payload.ts_ms ts_ms_cdc                        
                from "DEMO_DB"."PUBLIC"."CDC_POSTGRESDB_INVENTORY_PRODUCT_STREAM_REPLICATION"),
            rank_query as (select *
                    , ROW_NUMBER() over (PARTITION BY id 
                        order by ts_ms_cdc desc, sourcedb_lsn desc) as row_num
                from prequery)
            select * from rank_query where row_num = 1) event_data
        on replica_table.id = to_number(event_data.id)
    when not matched and event_data.cdc_operation <> 'd' 
        then insert 
                (id, sourcedb_lsn, payload, cdc_operation, cdc_source_info, ts_ms_sourcedb
                , ts_ms_cdc, ts_ms_replica_sf)
            values 
                (event_data.id, event_data.sourcedb_lsn, event_data.payload, event_data.cdc_operation
                , event_data.cdc_source_info, event_data.ts_ms_sourcedb, event_data.ts_ms_cdc
                , date_part(epoch_millisecond, CURRENT_TIMESTAMP))
    when matched and event_data.cdc_operation = 'd'
        then delete
    when matched and event_data.cdc_operation <> 'd'
        then update set id=event_data.id
            , sourcedb_lsn=event_data.sourcedb_lsn
            , payload=event_data.payload
            , cdc_operation=event_data.cdc_operation
            , cdc_source_info=event_data.cdc_source_info
            , ts_ms_sourcedb=event_data.ts_ms_sourcedb
            , ts_ms_cdc=event_data.ts_ms_cdc
            , ts_ms_replica_sf=date_part(epoch_millisecond, CURRENT_TIMESTAMP);


-- Enable task
ALTER TASK "DEMO_DB"."PUBLIC"."CDC_POSTGRESDB_INVENTORY_PRODUCT_TASK_REPLICATION" RESUME;

-- Check info about the task executions (STATE and NEXT_SCHEDULED_TIME columns)
-- If you see error "Cannot execute task , EXECUTE TASK privilege must be granted to owner role" 
-- review 00-security.sql script
select *
  from table(demo_db.information_schema.task_history())
  order by scheduled_time desc;


-- Check counts (you don't see the same results in event table against the replica table)
select to_char(RECORD_CONTENT:payload.op) cdc_operation, count(*), 'CDC_POSTGRESDB_INVENTORY_PRODUCT' table_name 
    from "DEMO_DB"."PUBLIC"."CDC_POSTGRESDB_INVENTORY_PRODUCT" group by RECORD_CONTENT:payload.op
union all
select cdc_operation, count(*), 'REPLICA_POSTGRESDB_INVENTORY_PRODUCT' table_name
    from "DEMO_DB"."PUBLIC"."REPLICA_POSTGRESDB_INVENTORY_PRODUCT" group by cdc_operation
order by table_name, cdc_operation;
