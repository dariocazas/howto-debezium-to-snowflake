# Howto - the Snowflake part 

![Snowflake-logo](../.images/Snowflake_Logo.svg.png)

As part of this howto, I provide:

- Kafka connect configurations to push event changes from CDC topics to Snowflake
- Scripts to create, destroy and check the status of these connectors
- Snowflake SQL scripts with replica transformation of the change event tables

## Quick steps

### Preconditions

You need a Snowflake account to run it. You should review the guide in [docker/credentials],
including the keys to auth the connectors.

This is the last part of the demo. You should complete all other parts of the demo. 
Review the [global README](../README.md) to check it.

Remmember check if your topics exist and has data, for example consuming the events using the command referenced in 
[docker](../docker/README.md) guide.

### Sink to Snowflake scripts

This folder includes three bash scripts, that perform actions against the docker service `cdc_sink`:

- `init_cdc.sh`: take the configuration available in `./connect/snowflake-sink-connector.json` file, and call
    the Kafka connect REST API to create the connector sink the CDC topics to Snowflake event tables
- `status_cdc.sh`: call the Kafka connect REST API, get the list of configured 
    connectors, and for each connector call to show you the status
- `delete_cdc.sh`: similar to status, but delete all the connectors in this 
    Kafka connect service

**IMPORTANT**: you MUST change several parameter in `./connect/snowflake-sink-connector.json` file:
- `snowflake.url.name`: the entry point for your Snowflake environment
- `snowflake.user.name`: your user name
- `snowflake.private.key`: your pub certificate
- `snowflake.private.key.passphrase`: well, in this demo not include it because the generated certificate isn't encrypted

Is a good practice externalize your secrets outside of connector configs. You can review the [KIP-297] to use
an external provider to reference it.

With these scripts, you can perform your test as you wish:

- Create connector after or before the topics exist or have data
- Destroy connector, insert new data, and create again to check data loss
- Wherever test that you can do

### Snowflake scripts

Configure your Snowflake account replication with:

- `sql/00-security.sql`: you partially include it when you do the [docker/credentials] guide. The script is documented.
- `sql/01-cdc-to-replica-mysql.sql`: create a view similar to original MySQL table, and the necessary to replicate 
    the events uploaded to Snowflake
- `sql/01-cdc-to-replica-postgres.sql`: like the MySQL, but for the PostgreSQL table

## Context

### Sink connector

If you review the detail about the [cdc_config](../cdc_config/README.md), you should have context about the Kafka connect
and how to configure it.

As you can see, [this connector](./connect/snowflake-sink-connector.json) is very similar:
- Common connector parts (name, connector class, ...)
- Snowflake connection properties and destination definition
   - You should configure your Snowflake account (url, user, keys...)
   - Is recommeded apply a topic2table mapping
- Other configs:
   - `key.converter`: 
      - Tell to connector how to understand the key of the events received from the topics. 
      - You can use a generic JsonConverter, but Snowflake offers to you his own implementation, that support some additional options
   - `value.converter`: like the `key.converter`, but with focus on the value of the event
   - `behavior.on.null.values`
      - Specific property of the Snowflake converters (but exist generic alternatives)
      - In [cdc_config](../cdc_config/README.md) explain about how to Debezium transform the DELETE actions 
        into two events (one with the delete operation, and another with `null` value)
      - An `null` value makes sense in Kafka context, but not for a database (like Snowflake), for this reason configure as `IGNORE`: 
        these events will not upload to Snowflake

### Snowflake security

For simplicity, this demo should be runned as SYSADMIN role in Snowflake, grant priviledges to run TASK to this role.

### Snowflake resource naming used

In this demo:
- All resources include the topic name in upper case, replacing the `.` with `_`
- The Debezium events are ingested to tables with prefix `CDC_`
- The tables with the replica of state using prefix `REPLICA_`
- The stream (listeners over change in Snowflake tables) used for batch new events to replication, follow `<source_table>_STREAM_REPLICATION`
- The task in charge of trigger the replica, follow `<source_table>_TASK_REPLICATION`

### Snowflake CDC Debeizum table

As configuration of the sink Kafka connector, you specify in which database, schema, and table populate the events.
The tables have the same format with two columns:
- `RECORD_METADATA`: variant column with a JSON, that include info about the origin topic and the key of the event
- `RECORD_CONTENT`: variant column with a JSON, with the value of the event.

About the key and the value, in this demo works with JSON serialization without schema registry. The events gerenated by 
the CDC include the JSON Schema relative to the events. If you review, the `RECORD_CONTENT` has the same event value that
you see as event value in Kafka topic. The record `RECORD_METADATA` includes:

- CreateTime: when Kafka receive the event
- topic: the name of source topic
- partition: the number of the partition of topic that contains the event
- offset: the position in the partition for the event
- key: the event key

```json
{
  "CreateTime": 1627490826351,
  "topic": "mysqldb.inventory.users",
  "partition": 0,
  "offset": 12,
  "key": {
    "payload": {
      "id": 1
    },
    "schema": {
      "fields": [
        {
          "field": "id",
          "optional": false,
          "type": "int32"
        }
      ],
      "name": "mysqldb.inventory.users.Key",
      "optional": false,
      "type": "struct"
    }
  }
}

```

You can use this table as historic evolution for the source table, that can be util for analytical purposes.

### Snowflake replica table

One of the objectives of this demo is replicate the state of the source databases in Snowflake. It can be done 
not only for Snowflake (you can populate the topic data in other database via JDBC sink connector), but in case
of Snowflake exist several points to consider that enable one plus of complexity.

When you perform a replica using JDBC connector, the order of the operations is directly the order that you read
from topic. But in Snowflake, you need to process a batch of information (or the partial/entire cdc table while you 
haven't a task to do it). In this case, you need sort the events and take the last one for each key.

The script replication do these actions:
- Create replication table
- Create a view over replication table (to see the same structure like original database table)
- Create a stream over event table (in our case, capture new ingested rows)
- Merge the actual table to replication table
- Create a task with the `MERGE INTO` sentence, reading from stream (not from event table)
- Enable the task (that runs every minute)
- And other check sentence util

Well, is important (to avoid lost data) create the stream before run the `MERGE INTO` sentence from event table 
(I asume that you are ingesting data before creating the replication table).

The `MERGE INTO` sentence include:
- Projection of important fields for the process (not from functional data perspective). This include:
  - Fields used for sorting the events (binlog, lsn,...)
  - The functional data (payload of the event)
  - The cdc operation (read, insert, update, delete)
  - Metadata about the CDC process (source field of Debezium change event), util for trazability
  - Some fields util to calc latencies
- Sort the input. This operation depends on your source database engine an his configuration:
  - From MySQL, exist diferent topologies. In our demo, use a standalone and build a binlog sequence 
    with filename and position to sort it
  - From PostgreSQL, the path is use the lsn id
- Take the last operation for each key
  - You should garantiee that the query only result one result for each key
  - If merge operation match several keys to one, the operation is not deterministic, and can apply any.
- Check if the key of the source table match with the target (replica) table
  - If no match and operation is `delete`, the event should be discarted
  - If no match and operation is another, the event should be inserted
  - If match and operation is `delete`, the row in replica table should be deleted
  - If match and operation is another, the event should be applied to the replica table

When your query runs fine over the source table, you should schedule a task that run it for you. If you run
again and again this query over the events table, you proces again and again all the events. To avoid it, 
run the task over the stream created, not for the event table. The stream is cleaned automatically every 
suscessful iteration, and you only process the new events. You can add a condition over the task that only
runs if exist data in the stream.

After create the task, you should enable it using a `ALTER TASK` sentence. You can see the task history execution with 
```sql
select *
  from table(demo_db.information_schema.task_history())
  order by scheduled_time desc;
```

### The final view

The replication table contains columns with info about the CDC and replication process, util for checking. But for your
final consumer this information is not the expected. They want the same table that they have in source database system.

One column has the valuable data: the `PAYLOAD` column. This content the functional data, in JSON format. 
You can create a view over this field, projecting the data like the source databases. 

This have one additional benefict: **evolution**. If your source database evolves (adding columns, removing it, wherever) 
all the process is not affected, all runs fine. The unique change is the view:
- No changes in your data pipeline
- No changes in your data
- Coexistence of old and new data
- The schema of each data is included with the data


[docker/credentials]: ../docker/credentials
[KIP-297]: https://cwiki.apache.org/confluence/display/KAFKA/KIP-297%3A+Externalizing+Secrets+for+Connect+Configurations