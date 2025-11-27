#!/bin/bash

# Script to send test logs to the ingestion API

API_URL=${API_URL:-"http://localhost:3000"}

echo "🧪 Sending test logs to $API_URL/log/ingest"
echo ""

# Read test logs from JSON file
while IFS= read -r line; do
  if [ -n "$line" ]; then
    echo "Sending: $line"
    curl -X POST "$API_URL/log/ingest" \
      -H "Content-Type: application/json" \
      -d "$line" \
      -w "\nStatus: %{http_code}\n\n"
    sleep 1
  fi
done < <(cat test-logs.json | jq -c '.[]')

echo "✅ All test logs sent!"

