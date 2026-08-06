#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Registering Debezium Postgres connector..."

if curl -X POST \
    http://localhost:8083/connectors \
    -H "Content-Type: application/json" \
    --data @"${SCRIPT_DIR}/connectors.json"; then

    echo
    echo "✓ Postgres connector registered successfully."

else

    echo
    echo "✗ Failed to register Postgres connector."
    exit 1

fi