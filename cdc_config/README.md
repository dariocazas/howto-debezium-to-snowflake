# Howto - CDC part

As part of this howto, I provide:

- Kafka connect configurations to capture changes from MySQL and PosgreSQL databases
- Scripts to create, destroy and check status of this connectors

Kafka connect enable the ability to push/poll events to Kafka from/to 
other system using only a configuration file, without develop a source/sink application.

The Kafka connector plugin need to be deployed into the Kafka connect nodes (called
worker nodes), and after do this you can call a REST API with a configuration to
enable the connector to push data from external source to Kafka (like CDC connector do for you) 
or pull data from Kafka to other sink destination.

## Preconditions

Review [docker readme] about the databases available, and run the docker-compose
to start services to run CDC.

It isn't necessary run the described process in [database readme]: when the 
cdc_connect service and database services are UP, you can init the CDC.
Obviously, topics will not be created or changes will be captured until 
the different steps described in [database readme].

## Change Events

In Kafka, a topic can have one or more partitions. This enable parallel read from consumers in the same 
consumer group. A consumer group is a group of consumers that see the topic as a queue, and each consumer
can pull events from several partitions but one partition cannot have more than one consumer for each consumer group.
This is a main point to understand one part of the event: the key.

An event has three parts:
- Key: 
    - By default, all events with the same key are pushed to the same partition. 
    - This can be null, in this case a round robin between partitions on push is performed.
- Value: the event data
- Headers: a collection of pair key-value that can be setted

Compared to the native CDC of each database, Debezium provides a decoupling between the
database engine and the events it emits, standardizing them and making them common as far as possible.

As a key, Debezium (and other change data capture tools) include the key fields of the table 

As value, Debezium sends this common fields:
- source: a metadata document about the connector and the source database
- op: the operation code, can be `r` (read, snapshot), `c`(create, insert), `u` (update), `d` (delete)
- after: a document with the data state after database operation
- before: a document with the data state before database operation

<details>
<summary>Example of key seralized as JSON</summary>

```JSON
{
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
```

</details>

<details>
<summary>Example of value seralized as JSON</summary>

```JSON
{
  "payload": {
    "after": {
      "created_on": "2021-07-28T16:32:45Z",
      "email": "lara7012@email.com",
      "id": 1,
      "name": "Lara",
      "password": "701280aa-efc1-11eb-a7c9-0"
    },
    "before": null,
    "op": "c",
    "source": {
      "connector": "mysql",
      "db": "inventory",
      "file": "mysql-bin.000003",
      "gtid": null,
      "name": "mysqldb",
      "pos": 703,
      "query": null,
      "row": 0,
      "sequence": null,
      "server_id": 223344,
      "snapshot": "false",
      "table": "users",
      "thread": null,
      "ts_ms": 1627489965000,
      "version": "1.6.1.Final"
    },
    "transaction": null,
    "ts_ms": 1627489965300
  },
  "schema": {
    "fields": [
      {
        "field": "before",
        "fields": [
          {
            "field": "id",
            "optional": false,
            "type": "int32"
          },
          {
            "field": "name",
            "optional": true,
            "type": "string"
          },
          {
            "field": "email",
            "optional": true,
            "type": "string"
          },
          {
            "field": "password",
            "optional": true,
            "type": "string"
          },
          {
            "field": "created_on",
            "name": "io.debezium.time.ZonedTimestamp",
            "optional": true,
            "type": "string",
            "version": 1
          }
        ],
        "name": "mysqldb.inventory.users.Value",
        "optional": true,
        "type": "struct"
      },
      {
        "field": "after",
        "fields": [
          {
            "field": "id",
            "optional": false,
            "type": "int32"
          },
          {
            "field": "name",
            "optional": true,
            "type": "string"
          },
          {
            "field": "email",
            "optional": true,
            "type": "string"
          },
          {
            "field": "password",
            "optional": true,
            "type": "string"
          },
          {
            "field": "created_on",
            "name": "io.debezium.time.ZonedTimestamp",
            "optional": true,
            "type": "string",
            "version": 1
          }
        ],
        "name": "mysqldb.inventory.users.Value",
        "optional": true,
        "type": "struct"
      },
      {
        "field": "source",
        "fields": [
          {
            "field": "version",
            "optional": false,
            "type": "string"
          },
          {
            "field": "connector",
            "optional": false,
            "type": "string"
          },
          {
            "field": "name",
            "optional": false,
            "type": "string"
          },
          {
            "field": "ts_ms",
            "optional": false,
            "type": "int64"
          },
          {
            "default": "false",
            "field": "snapshot",
            "name": "io.debezium.data.Enum",
            "optional": true,
            "parameters": {
              "allowed": "true,last,false"
            },
            "type": "string",
            "version": 1
          },
          {
            "field": "db",
            "optional": false,
            "type": "string"
          },
          {
            "field": "sequence",
            "optional": true,
            "type": "string"
          },
          {
            "field": "table",
            "optional": true,
            "type": "string"
          },
          {
            "field": "server_id",
            "optional": false,
            "type": "int64"
          },
          {
            "field": "gtid",
            "optional": true,
            "type": "string"
          },
          {
            "field": "file",
            "optional": false,
            "type": "string"
          },
          {
            "field": "pos",
            "optional": false,
            "type": "int64"
          },
          {
            "field": "row",
            "optional": false,
            "type": "int32"
          },
          {
            "field": "thread",
            "optional": true,
            "type": "int64"
          },
          {
            "field": "query",
            "optional": true,
            "type": "string"
          }
        ],
        "name": "io.debezium.connector.mysql.Source",
        "optional": false,
        "type": "struct"
      },
      {
        "field": "op",
        "optional": false,
        "type": "string"
      },
      {
        "field": "ts_ms",
        "optional": true,
        "type": "int64"
      },
      {
        "field": "transaction",
        "fields": [
          {
            "field": "id",
            "optional": false,
            "type": "string"
          },
          {
            "field": "total_order",
            "optional": false,
            "type": "int64"
          },
          {
            "field": "data_collection_order",
            "optional": false,
            "type": "int64"
          }
        ],
        "optional": true,
        "type": "struct"
      }
    ],
    "name": "mysqldb.inventory.users.Envelope",
    "optional": false,
    "type": "struct"
  }
}
```

</details>

To mantain simple this demo, it works with JSON events with your own schema included in the event. 
In a non-test environment, we recoment use a Schema Registry to store the schemas, and other serialization
format like Avro to store it. 

## Connector actions

When connectors perform a first run, you can see an initial snapshot of the database (is a configurable option).
After do this, every change applied to the tables that these connectors listen, will be track to Kafka. This include:
- When you add new rows, one event per row will be inserted
- When you update rows,
    - One event per row will be updated
    - If update affects the key of the table, Debezium throw like a delete action and new insert of data
- When you delete rows, two events per row will be deleted (configurable option):
    - One event with info about the operation DELETE
    - Other event with null value (events in Kafka have key, value and headers, and any can be null)

Each event has as key the key of the table, that enable guarantees of order. The topics of Kafka
have properties to identify data retention and clean policies:
- Retention by time
- Retention by size
- Retention by compaction

When using compaction hold, when Kafka triggers the cleanup process, it keeps the last event for 
each key on the topic. If last event for a key has a null as value, Kafka remove all events for 
this key. With this approach, when a new consumer begins to read the topic, he does not have 
to download the changes from the origin of the replica: he first obtains the state of the table 
from the moment of the last compaction, and then continues reading the changes captured since then.

## Scripts

This folder include three scripts, that perform actions agains the docker service `cdc_connector`:

- `init_cdc.sh`: take the configurations available in `./connect` folder, and call 
    the Kafka connect REST API to create the connector that capture the changes 
    in the databases
- `status_cdc.sh`: call the Kafka connect REST API, get the list of configured 
    connectors, and foreach connector call to show you the status
- `delete_cdc.sh`: similar to status, but delete all the connectors in this 
    Kafka connect service

With these scripts, you can perform your test as you wish:

- Create connectors after or before the tables exists or have data
- Destroy connectors, insert new data, and create again to check data loss
- Wherever test that you can do

## Connectors config

The Kafka connectors have a common configuration properties and other that it depends of 
the Kafka connector plugin that you use. A FileStreamSource connector needs 
the configuration of the file to read, and a CDC connector need info about the 
database that should be read: evidently the configuration is not the same, but 
some parts are common:
- name: all connectors should have a name to reference it
- connector.class: the class that implements the connector, that maybe a 
    source (push external data to Kafka) or sink (pull data from Kafka to other system)
- tasks.max: the maximun number of task that perform the source/sink action

To review other common configurations, you can review [the official doc about kafka connect configuring].

Other main point of the Kafka connector is the ability to do some basic transformations (called SMT)
of the event, like add some field or change the event key. We don't perform this 
in this howto, but can be interested in some use cases.

### MySQL connector

You can see all the documentation about this Kafka connector plugin in 
the [Debezium connector for MySQL] page.

This connector support several MySQL topologies, but in this demo will track
changes for a standalone MysQL server.

When you start the connector, you can see three new topics:

- `mysqldb`: schema change topic, with schema change events that include all DDL 
    statements applied to databases in the MySQL server. The name of this topic is 
    the same described in property `database.server.name`
- `mysqldb.schema-changes.inventory`: track DDL changes in the database, and it
    is necessary by internal management of the CDC connector. You can configure the 
    topic name in `database.history.kafka.topic`
- `mysqldb.inventory.users`: 
    - If you was run the steps in [database readme], you should have a topic for this table
    - This topic manage the change events for table users
    
Well, you can see the connector config in [`connect/debezium-mysql-inventory-connector.json`](./connector/debezium-mysql-inventory-connector.json)

- Connection properties:
    - `database.hostname`: IP address or host name of the MySQL database server.
    - `database.port`: integer port number of the MySQL database server.
    - `database.user`: name of the MySQL user to use when connecting to the MySQL database server.
    - `database.password`: password to use when connecting to the MySQL database server.
    - `database.server.id`: a numeric ID of this database client, which must be unique across all 
        currently-running database processes in the MySQL cluster. If not set, a random number will be use.
    - `database.server.name`: logical name that identifies and provides a namespace for the particular 
        MySQL database server/cluster in which Debezium is capturing changes.
- CDC properties:
    - `database.history.kafka.bootstrap.servers`: a list of host/port pairs that the connector uses for 
        establishing an initial connection to the Kafka cluster. Each pair should point to the same Kafka 
        cluster used by the Kafka Connect process.
    - `database.history.kafka.topic`: the full name of the Kafka topic where the connector stores the 
        database schema history.
    - `database.include`: name of the database for which to capture changes. The connector does not capture 
        changes in any database whose name is not in this property or `database.include.list`
    - `table.include.list`: an optional, comma-separated list of regular expressions that match 
        fully-qualified table identifiers of tables whose changes you want to capture. 
        The connector does not capture changes in any table not included in table.include.list.
    - Exists properties to configure the exclude instead of include databases/tables, and a lot of
        parametrized options. Review the [official doc](https://debezium.io/documentation/reference/connectors/mysql.html#mysql-connector-properties).

### PostgreSQL connector

You can see all the documentation about this Kafka connector plugin in 
the [Debezium connector for PostgreSQL] page.

In this case, when you start the connector you only see one topic:
- `postgres.inventory.product`: 
    - If you was run the steps in [database readme], you should have a topic for this table
    - This topic manage the change events for table product

If you review the properties used, is very similar to the MySQL connector, and no new description is needed.




[database readme]: ../database/README.md
[docker readme]: ../docker/README.md
[Debezium connector for MySQL]: https://debezium.io/documentation/reference/connectors/mysql.html
[Debezium connector for PostgreSQL]: https://debezium.io/documentation/reference/connectors/postgresql.html
[the official doc about kafka connect configuring]: https://kafka.apache.org/documentation.html#connect_configuring