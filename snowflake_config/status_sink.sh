#!/bin/bash

CONNECT_URL=http://localhost:9093

CONNECTORS=$(curl -s -k ${CONNECT_URL}/connectors)
echo Connector list:
echo $CONNECTORS
echo 

echo Connector status:
echo

for row in $(echo "${CONNECTORS}" | jq -c -r '.[]'); do
    status=$(curl -s -k -X GET "${CONNECT_URL}/connectors/${row}/status")
    echo $status
    echo 
done

