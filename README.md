# Debezium to Snowflake

- [Debezium to Snowflake](#debezium-to-snowflake)
  - [Requirements](#requirements)
  - [Organization](#organization)
  - [How-to steps](#how-to-steps)
  - [I need more!!](#i-need-more)

This repo is a demo of how to use Debezium to capture changes over tables in MySQL and PostgreSQL 
to generate a replica in near-real-time in Snowflake. This is extensible to other databases and
describes several common points about CDC, Kafka, Kafka connect, or Snowflake tools. 

[Miguel García] and I work together on a DZone article [Data Platform: Building an Enterprise CDC Solution],
and as next step I publish this repo as [HOWTO: Building an Enterprise CDC Solution]

![solution.png](./.images/solution.png)

## Requirements

To facilitate the execution of the howto, the services will be deployed using **[docker-compose]**. 
It has a dependency of **[docker engine]**. For better compatibility, we are using the docker-compose specification 2,
so a **docker engine 1.10.0** or later should work. 

As part of the howto, you will create a Snowflake account, and the howto guide you to create a key pair for authentication.
To perform these actions, you should have an **[OpenSSL toolkit]**. Is commonly available in Linux distributions and
can be installed in Windows or Mac. If you need it, you can run it inside a docker image (will be commented in the howto).

About hardware requirements, review **[docker engine]** requirements.

## Organization

Well, this demo has several parts. To simplify this, it has been split into several folders in this repo.
For each folder you can found a README file with explanations:

- **[services]**: relative to docker images and services
- **[database]**: sentences and scripts to run inside the local databases
- **[debezium]**: configuration and scripts to start and check the status of Debezium connectors
- **[snowflake]**: Snowflake scripts, and configuration of the Snowflake sink connector

## How-to steps

You can see a detailed howto in DZone article [HOWTO: Building an Enterprise CDC Solution] that follows these steps

![howto-flow](.images/howto-flow.png)

In this flow:
- Gray: local services
- Yellow: external resources

## I need more!!

Well, check the README available in each folder. It includes some detail about his components
and some additional scripts or functions that you can use to explore this solution.

I hope this tutorial has been helpful for you and you have enjoyed it.


[Miguel García]: https://dzone.com/users/4531976/miguelglor.html
[Data Platform: Building an Enterprise CDC Solution]: https://dzone.com/articles/data-platform-building-an-enterprise-cdc-solution
[HOWTO: Building an Enterprise CDC Solution]: https://dzone.com/articles/howto_building-an-enterprise-cdc-solution
[docker-compose]: https://docs.docker.com/compose/install/
[docker engine]: https://docs.docker.com/engine/
[OpenSSL toolkit]: https://github.com/openssl/openssl#build-and-install
[services]: services/README.md
[database]: database/README.md
[debezium]: debezium/README.md
[snowflake]: snowflake/README.md
[snowflake/keys README]: snowflake/keys
[snowflake/sql/00-security.sql]: snowflake/sql/00-security.sql
[snowflake/connect/snowflake-sink-connector.json]: snowflake/connect/snowflake-sink-connector.json
[snowflake/sql/01-cdc-to-replica-mysql.sql]: snowflake/sql/01-cdc-to-replica-mysql.sql
[snowflake/sql/01-cdc-to-replica-postgres.sql]: snowflake/sql/01-cdc-to-replica-postgres.sql
