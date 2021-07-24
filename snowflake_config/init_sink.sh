#!/bin/bash

CONNECT_URL=http://localhost:9093
SINK_SQL_CONNECT_CONFIG=connect-sql-snowflake.json
SINK_SNOWPIPE_CONNECT_CONFIG=connect-snowpipe.json

#echo "### Creating Snowflake JDBC sink connector ###"
#curl -i -X POST $CONNECT_URL/connectors \
#    -H "Accept:application/json" \
#    -H "Content-Type:application/json" \
#    -d @$SINK_SQL_CONNECT_CONFIG
#echo .

echo "### Creating Snowpipe sink connector ###"
curl -i -X POST $CONNECT_URL/connectors \
    -H "Accept:application/json" \
    -H "Content-Type:application/json" \
    -d @$SINK_SNOWPIPE_CONNECT_CONFIG
echo .
