#!/bin/bash

CONNECT_URL=http://localhost:8083

CONNECTORS=$(curl -s -k ${CONNECT_URL}/connectors)
echo Connector list:
echo $CONNECTORS
echo 

for row in $(echo "${CONNECTORS}" | jq -c -r '.[]'); do
    status=$(curl -s -k -X DELETE "${CONNECT_URL}/connectors/${row}")
    echo Deleted ${row}
done
