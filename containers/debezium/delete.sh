!#/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Deleting Debezium Postgres connector..."

if curl -X DELETE \
    http://localhost:8083/connectors/postgres-cdc; then

    echo
    echo "✓ Postgres connector deleted successfully."

else

    echo
    echo "✗ Failed to delete Postgres connector."
    exit 1

fi