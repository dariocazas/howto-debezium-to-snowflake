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

[[TODO]]

### PostgreSQL connector

You can see all the documentation about this Kafka connector plugin in 
the [Debezium connector for PostgreSQL] page.

[[TODO]]


[database readme]: ../database/README.md
[docker readme]: ../docker/README.md
[Debezium connector for MySQL]: https://debezium.io/documentation/reference/connectors/mysql.html
[Debezium connector for PostgreSQL]: https://debezium.io/documentation/reference/connectors/postgresql.html
[the official doc about kafka connect configuring]: https://kafka.apache.org/documentation.html#connect_configuring