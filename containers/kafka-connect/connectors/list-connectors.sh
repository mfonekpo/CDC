#!/bin/bash

set -euo pipefail

CONNECT_URL="http://localhost:8083"

curl --fail-with-body \
    -s \
    "$CONNECT_URL/connectors" | jq