# Howto - Debezium to Snowflake

This repo is a demo of how to use Debezium to capture changes over tables in MySQL and PosgreSQL 
to generate a replica in near real time in Snowflake. This is extensible to other databases and
describe serveral common points about CDC, Kafka, Kafka connect or Snowflake tools. 

[Miguel García](https://dzone.com/users/4531976/miguelglor.html) and me work together in an article
using this repo as demo: [[DZONE] Data Platform: Building an Enterprise CDC Solution](https://dzone.com/articles/data-platform-building-an-enterprise-cdc-solution)

![solution.png](./.images/solution.png)

## Repo organization

Well, this demo have several parts. To simplify this, it has splitted in several folders in this repo.
For each folder you can found a README file with explanations:

- [docker folder]: it has a docker-compose as a base to run it
- [database folder]: it has several scripts to initialize and modify data in databases
- [cdc_config folder]: it has scripts to initalize and check status of the CDC (capture data changes) over the dockerized databases
- [snowflake_config folder]: it has two parts:
    - Bash scripts to initalize and check statos of the connecto that sink Kafka events to Snowflake
    - SQL scripts that you need to run in Snowflake to create a near real time replica of the original tables

## Order to run it

You need as external resource an account in Snowflake. Review [docker/credentials/README.md]
for how to create this account and how to prepare configuration to enable the dockerize images sink
data to Snowflake.

Next step, should be do the steps in [docker folder] to start your local enviroment.

After it, I recommend follow this order (it is not extrictly necessary, but is logical order):
- [database folder]
- [cdc_config folder]
- [snowflake_config folder]

Enjoy it!


[docker folder]:_./docker/
[database folder]: ./database/
[cdc_config folder]: ./cdc_config/
[snowflake_config folder]: ./snowflake_config/
[docker/credentials/README.md]: ./docker/credentials/README.md
