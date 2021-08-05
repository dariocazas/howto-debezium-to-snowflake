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

### Snowflake CDC Debeizum table

[TODO]

### Snowflake replica table

[TODO]

### Snowflake task to automatic replication

[TODO]

### Snowflake MySQL replica

[TODO]

### Snowflake PostgreSQL replica

[TODO]


[docker/credentials]: ../docker/credentials
[KIP-297]: https://cwiki.apache.org/confluence/display/KAFKA/KIP-297%3A+Externalizing+Secrets+for+Connect+Configurations