# Howto - Database description

As part of this howto, I provide:

- SQL scripts to create new tables and data
- Bash scripts to apply the SQL over the dockerized databases

## Prerequisites

Well, to simplify the howto, we use database images provided by debezium.
Review [docker readme] about the databases available, and run the docker-compose
to start the instances.

When the instances are UP, you should perform this script:

```sh
./init_db.sh
```

This script initialize tables in both database instances (MySQL and PostgreSQL)
loaded from `./sql` folder.

For accessing to MySQL shell or PostgreSQL shell, review the [docker readme]. 

The SQL script [`sql/00_mysql_init.sql`](./sql/00_mysql_init.sql) create the
**users table** with five basic fields, common for a lot of databases.

The SQL script [`sql/00_postgres_init.sql`](./sql/00_postgres_init.sql) create the
**product table** with five basic fields, common for a lot of databases.

The `init_db.sh` script use these SQL files to init database tables (one for each database)
in preconfigured database `inventory`.

Both tables have a `created_on` field with the timestamp of creation. This field
is not necessary for CDC, but can be util to perform some checks in sink destination.

## CRUD operations for howto

Well, as part of the demo, you should do actions over the databases. For each reason,
I provide two scripts:

- `mysql_crud.sh`: trigger several inserts, update, delete and show the final status of the **users** table
- `postgres_crud.sh`: same again, but over PostgreSQL **product** table

You can launch these scripts over and over again to generate new data in the database,
which via CDC will be replicated as events in Kafka.

Return to global [README](../README.md) to check next steps.

[docker readme]: ../docker/README.md