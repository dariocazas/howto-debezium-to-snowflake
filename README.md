# Howto - Debezium to Snowflake

This repo is a demo of how to use Debezium to capture changes over tables in MySQL and PostgreSQL 
to generate a replica in near-real-time in Snowflake. This is extensible to other databases and
describe several common points about CDC, Kafka, Kafka connect or Snowflake tools. 

[Miguel García](https://dzone.com/users/4531976/miguelglor.html) and I work together on an article
using this repo as the demo: [[DZONE] Data Platform: Building an Enterprise CDC Solution](https://dzone.com/articles/data-platform-building-an-enterprise-cdc-solution)

![solution.png](./.images/solution.png)

## Repo organization

Well, this demo has several parts. To simplify this, it has been split into several folders in this repo.
For each folder you can found a README file with explanations:

- [docker folder]: it has a docker-compose as a base to run it
- [database folder]: it has several scripts to initialize and modify data in databases
- [cdc_config folder]: it has scripts to initialize and check status of the CDC (capture data changes)
    over the dockerized databases
- [snowflake_config folder]: it has two parts:
    - Bash scripts to initialize and check the status of the connector that sink Kafka events to Snowflake
    - SQL scripts that you need to run in Snowflake to create a near-real-time replica of the original tables

## Order to run it

You need as an external resource an account in Snowflake. Review [docker/credentials/README.md]
for how to create this account and how to prepare configuration to enable the dockerize images to sink
data to Snowflake.

The next step should be done the steps in [docker folder] to start your local environment.

After it, I recommend following this order (it is not strictly necessary, but is logical order):
- [database folder]
- [cdc_config folder]
- [snowflake_config folder]

Enjoy it!


[docker folder]:_./docker
[database folder]: ./database/
[cdc_config folder]: ./cdc_config/
[snowflake_config folder]: ./snowflake_config/
[docker/credentials/README.md]: ./docker/credentials/README.md
