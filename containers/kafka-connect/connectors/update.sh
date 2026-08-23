#!/bin/bash

set -euo pipefail

CONNECT_URL="http://localhost:8083"
CONNECTOR_NAME="snowflake-cdc-sink"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PRIVATE_KEY_PATH="$HOME/tf_key.p8"
CONFIG_FILE="$SCRIPT_DIR/connector.json"
TEMP_CONFIG="$(mktemp)"

trap 'rm -f "$TEMP_CONFIG"' EXIT

if [[ ! -f "$PRIVATE_KEY_PATH" ]]; then
    echo "ERROR: Private key not found at $PRIVATE_KEY_PATH"
    exit 1
fi

PRIVATE_KEY=$(awk '
/-----BEGIN PRIVATE KEY-----/ { inside=1; next }
/-----END PRIVATE KEY-----/   { inside=0; next }
inside { printf "%s", $0 }
' "$PRIVATE_KEY_PATH")

if [[ -z "$PRIVATE_KEY" ]]; then
    echo "ERROR: Private key is empty"
    exit 1
fi

jq \
    --arg private_key "$PRIVATE_KEY" \
    '.config["snowflake.private.key"] = $private_key' \
    "$CONFIG_FILE" > "$TEMP_CONFIG"

echo "Updating $CONNECTOR_NAME..."

curl --fail-with-body \
    -X PUT \
    -H "Content-Type: application/json" \
    --data @"$TEMP_CONFIG" \
    "$CONNECT_URL/connectors/$CONNECTOR_NAME/config"

echo
echo "Connector updated successfully."