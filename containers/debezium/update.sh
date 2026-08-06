#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Updating Debezium Postgres connector..."
echo

if jq '.config' "${SCRIPT_DIR}/connectors.json" | \
curl --fail -X PUT \
    http://localhost:8083/connectors/postgres-cdc/config \
    -H "Content-Type: application/json" \
    --data @-; then

    echo
    echo "✓ Postgres connector updated successfully."

else

    echo
    echo "✗ Failed to update Postgres connector."
    exit 1

fi