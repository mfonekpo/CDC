#!/bin/bash

CONNECT_URL=http://localhost:8083
CONNECTOR_NAME=postgres-cdc

echo "Checking Debezium Postgres connector status..."
echo

curl ${CONNECT_URL}/connectors/${CONNECTOR_NAME}/status
echo