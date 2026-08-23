#!/bin/bash

set -euo pipefail

CONNECT_URL="http://localhost:8083"
CONNECTOR_NAME="snowflake-cdc-sink"

echo "Deleting $CONNECTOR_NAME..."

curl --fail-with-body \
    -X DELETE \
    "$CONNECT_URL/connectors/$CONNECTOR_NAME"

echo
echo "Connector deleted."