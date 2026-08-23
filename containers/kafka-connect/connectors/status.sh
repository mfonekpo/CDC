#!/bin/bash

set -euo pipefail

CONNECT_URL="http://localhost:8083"
CONNECTOR_NAME="snowflake-cdc-sink"

curl --fail-with-body \
    -s \
    "$CONNECT_URL/connectors/$CONNECTOR_NAME/status" | jq