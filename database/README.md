# Howto - Database description


![PostgreSQL-logo](../.images/PostgreSQL_logo.3colors.120x120.png)
![MySQL-logo](../.images/logo-mysql-170x115.png)

As part of this howto, I provide:

- SQL scripts to create new tables and data
- Bash scripts to apply the SQL over the dockerized databases

## Access to database shell

You can open the shell of your database and run it your commands:

```sh
# Go to services folder (important)
cd howto-debezium-to-snowflake/services

# Access to MySQL shell
docker-compose exec mysql \
    bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD inventory'

# Access to Postgres shell
docker-compose exec postgres \
    env PGOPTIONS="--search_path=inventory" \
    bash -c 'psql -U $POSTGRES_USER postgres'
```

## Tables

Well, to simplify the howto, we use database images provided by Debezium.
When the service databases are UP, you should perform this script:

```sh
./init_db.sh
```

This script initializes tables in both database instances (MySQL and PostgreSQL)
loaded from `./sql` folder.

The SQL script [`sql/00_mysql_init.sql`](./sql/00_mysql_init.sql) create the
**users table** with five basic fields, common for a lot of databases.

The SQL script [`sql/00_postgres_init.sql`](./sql/00_postgres_init.sql) create the
**product table** with five basic fields, common for a lot of databases.

The `init_db.sh` script uses these SQL files to init database tables (one for each database)
in preconfigured database `inventory`.

Both tables have a `created_on` field with the timestamp of creation. This field
is not necessary for CDC, but can be util to perform some checks in sink destination.

## CRUD operations

Well, as part of the demo, you should do actions over the databases. For each reason,
I provide two scripts:

- `mysql_crud.sh`: trigger several inserts, update, delete and show the final status of the **users** table
- `postgres_crud.sh`: same again, but over PostgreSQL **product** table

You can launch these scripts over and over again to generate new data in the database,
which via CDC will be replicated as events in Kafka.

