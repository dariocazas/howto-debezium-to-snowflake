#!/bin/bash

# Based on https://github.com/debezium/debezium-examples/tree/master/tutorial

CONNECT_URL=http://localhost:8083
MYSQL_CONNECT_CONFIG=connect-debezium-mysql.json
POSTGRES_CONNECT_CONFIG=connect-debezium-postgres.json

echo "### Creating MySQL CDC connect ###"
curl -i -X POST $CONNECT_URL/connectors \
    -H "Content-Type:application/json" \
    -d @$MYSQL_CONNECT_CONFIG
echo .

echo "### Creating Postgres CDC connect ###"
curl -i -X POST $CONNECT_URL/connectors \
    -H "Accept:application/json" \
    -H "Content-Type:application/json" \
    -d @$POSTGRES_CONNECT_CONFIG
echo .
