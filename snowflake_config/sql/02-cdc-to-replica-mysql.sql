-- Based on: 
-- https://docs.snowflake.com/en/user-guide/data-pipelines-examples.html#transforming-loaded-json-data-on-a-schedule
-- https://docs.snowflake.com/en/sql-reference/sql/merge.html


-- To simplify the howto, we only use role sysadmin. Remember review/apply 00-security.sql script
use role sysadmin;


-- Create the replica table, including extra columns to support replica logic and process trazability
create or replace 
    table "DEMO_DB"."PUBLIC"."REPLICA_MYSQL_INVENTORY_PET" 
    ( id number PRIMARY KEY comment 'primary key of the source table'
    , sourcedb_binlog_gtid string comment 'database log position, gtid used in HA MySQL (null in other cases), used for ordering events (RECORD_CONTENT:payload.source.gtid)'
    , sourcedb_binlog_file string comment 'database log position, file log name, used for ordering events (RECORD_CONTENT:payload.source.file)'
    , sourcedb_binlog_pos string comment 'database log position, position in log file, used for ordering events (RECORD_CONTENT:payload.source.pos)'
    , payload variant comment 'data after operation (RECORD_CONTENT:payload.after)'
    , cdc_operation char comment 'CDC registered operation in source DB (RECORD_CONTENT:payload.op)'
    , cdc_source_info variant comment 'Debezium source field, for trazability (RECORD_CONTENT:payload.source)'
    , ts_ms_sourcedb number comment 'the timestamp when database register the event, not available on database snapshot (RECORD_CONTENT:payload.source.ts_ms)'
    , ts_ms_cdc number comment 'the timestamp when the CDC connector capture the event (RECORD_CONTENT:payload.ts_ms)'
    , ts_ms_replica_sf number comment 'the timestamp when snowflake task fills the record')
comment = 'Replica from CDC over Mysql Inventory Pet';

-- Create final view with same columns as MySQL database to use like the same table
create or replace view "DEMO_DB"."PUBLIC"."MYSQL_INVENTORY_PET"
as 
    select payload:id id, payload:name name, payload:owner owner, payload:sex sex, payload:species species
    from "DEMO_DB"."PUBLIC"."REPLICA_MYSQL_INVENTORY_PET";

-- Create a stream from CDC events table, to process new events into replica table
create or replace 
    stream "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET_STREAM_REPLICATION" 
    on table "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET";


-- After create stream (avoid loss events), process all events available in CDC events table
merge into "DEMO_DB"."PUBLIC"."REPLICA_MYSQL_INVENTORY_PET" replica_table
    using 
        (with 
            prequery as (select RECORD_METADATA:key.payload.id id
                    , COALESCE(RECORD_CONTENT:payload.source.gtid, '') sourcedb_binlog_gtid
                    , COALESCE(RECORD_CONTENT:payload.source.file, '') sourcedb_binlog_file
                    , to_number(RECORD_CONTENT:payload.source.pos) sourcedb_binlog_pos
                    , RECORD_CONTENT:payload.after payload
                    , RECORD_CONTENT:payload.op cdc_operation
                    , RECORD_CONTENT:payload.source cdc_source_info
                    , RECORD_CONTENT:payload.source.ts_ms ts_ms_sourcedb
                    , RECORD_CONTENT:payload.ts_ms ts_ms_cdc                        
                from "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET"),
            rank_query as (select *
                    , ROW_NUMBER() over (PARTITION BY id 
                        order by ts_ms_cdc desc, sourcedb_binlog_gtid desc, sourcedb_binlog_file desc
                        , sourcedb_binlog_pos desc) as row_num
                from prequery)
            select * from rank_query where row_num = 1) event_data
        on replica_table.id = to_number(event_data.id)
    when not matched and event_data.cdc_operation <> 'd' 
        then insert 
                (id, sourcedb_binlog_gtid, sourcedb_binlog_file, sourcedb_binlog_pos, payload
                , cdc_operation, cdc_source_info, ts_ms_sourcedb, ts_ms_cdc, ts_ms_replica_sf)
            values 
                (event_data.id, event_data.sourcedb_binlog_gtid, event_data.sourcedb_binlog_file
                , event_data.sourcedb_binlog_pos, event_data.payload, event_data.cdc_operation
                , event_data.cdc_source_info, event_data.ts_ms_sourcedb, event_data.ts_ms_cdc
                , date_part(epoch_millisecond, CURRENT_TIMESTAMP))
    when matched and event_data.cdc_operation = 'd'
        then delete
    when matched and event_data.cdc_operation <> 'd'
        then update set id=event_data.id
            , sourcedb_binlog_gtid=event_data.sourcedb_binlog_gtid
            , sourcedb_binlog_file=event_data.sourcedb_binlog_file
            , sourcedb_binlog_pos=event_data.sourcedb_binlog_pos
            , payload=event_data.payload
            , cdc_operation=event_data.cdc_operation
            , cdc_source_info=event_data.cdc_source_info
            , ts_ms_sourcedb=event_data.ts_ms_sourcedb
            , ts_ms_cdc=event_data.ts_ms_cdc
            , ts_ms_replica_sf=date_part(epoch_millisecond, CURRENT_TIMESTAMP);


-- Create task with previous tested query, but read data from the created stream (not CDC events table).
create or replace task "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET_TASK_REPLICATION"
    warehouse = compute_wh
    schedule = '1 minute'
    allow_overlapping_execution = false
    when
        system$stream_has_data('DEMO_DB.PUBLIC.CDC_MYSQL_INVENTORY_PET_STREAM_REPLICATION')
    as
merge into "DEMO_DB"."PUBLIC"."REPLICA_MYSQL_INVENTORY_PET" replica_table
    using 
        (with 
            prequery as (select RECORD_METADATA:key.payload.id id
                    , COALESCE(RECORD_CONTENT:payload.source.gtid, '') sourcedb_binlog_gtid
                    , COALESCE(RECORD_CONTENT:payload.source.file, '') sourcedb_binlog_file
                    , to_number(RECORD_CONTENT:payload.source.pos) sourcedb_binlog_pos
                    , RECORD_CONTENT:payload.after payload
                    , RECORD_CONTENT:payload.op cdc_operation
                    , RECORD_CONTENT:payload.source cdc_source_info
                    , RECORD_CONTENT:payload.source.ts_ms ts_ms_sourcedb
                    , RECORD_CONTENT:payload.ts_ms ts_ms_cdc                        
                from "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET_STREAM_REPLICATION"),
            rank_query as (select *
                    , ROW_NUMBER() over (PARTITION BY id 
                        order by ts_ms_cdc desc, sourcedb_binlog_gtid desc, sourcedb_binlog_file desc
                        , sourcedb_binlog_pos desc) as row_num
                from prequery)
            select * from rank_query where row_num = 1) event_data
        on replica_table.id = to_number(event_data.id)
    when not matched and event_data.cdc_operation <> 'd' 
        then insert 
                (id, sourcedb_binlog_gtid, sourcedb_binlog_file, sourcedb_binlog_pos, payload
                , cdc_operation, cdc_source_info, ts_ms_sourcedb, ts_ms_cdc, ts_ms_replica_sf)
            values 
                (event_data.id, event_data.sourcedb_binlog_gtid, event_data.sourcedb_binlog_file
                , event_data.sourcedb_binlog_pos, event_data.payload, event_data.cdc_operation
                , event_data.cdc_source_info, event_data.ts_ms_sourcedb, event_data.ts_ms_cdc
                , date_part(epoch_millisecond, CURRENT_TIMESTAMP))
    when matched and event_data.cdc_operation = 'd'
        then delete
    when matched and event_data.cdc_operation <> 'd'
        then update set id=event_data.id
            , sourcedb_binlog_gtid=event_data.sourcedb_binlog_gtid
            , sourcedb_binlog_file=event_data.sourcedb_binlog_file
            , sourcedb_binlog_pos=event_data.sourcedb_binlog_pos
            , payload=event_data.payload
            , cdc_operation=event_data.cdc_operation
            , cdc_source_info=event_data.cdc_source_info
            , ts_ms_sourcedb=event_data.ts_ms_sourcedb
            , ts_ms_cdc=event_data.ts_ms_cdc
            , ts_ms_replica_sf=date_part(epoch_millisecond, CURRENT_TIMESTAMP);


-- Enable task
ALTER TASK "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET_TASK_REPLICATION" RESUME;

-- Check info about the task executions (STATE and NEXT_SCHEDULED_TIME columns)
-- If you see error "Cannot execute task , EXECUTE TASK privilege must be granted to owner role" 
-- review 00-security.sql script
select *
  from table(demo_db.information_schema.task_history())
  order by scheduled_time;


-- Check counts (you don't see the same results in event table against the replica table)
select to_char(RECORD_CONTENT:payload.op) cdc_operation, count(*), 'CDC_MYSQL_INVENTORY_PET' table_name 
    from "DEMO_DB"."PUBLIC"."CDC_MYSQL_INVENTORY_PET" group by RECORD_CONTENT:payload.op
union all
select cdc_operation, count(*), 'REPLICA_MYSQL_INVENTORY_PET' table_name
    from "DEMO_DB"."PUBLIC"."REPLICA_MYSQL_INVENTORY_PET" group by cdc_operation
order by table_name, cdc_operation;
