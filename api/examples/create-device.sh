#!/bin/bash

# Script to create a device in ThingsBoard

if [ -z "$1" ]; then
    echo "Usage: $0 <device_name>"
    echo "Example: $0 'Water Meter 01'"
    exit 1
fi

DEVICE_NAME=$1
TB_URL="http://localhost:8080"
TENANT_EMAIL="tenant@thingsboard.org"
TENANT_PASSWORD="tenant"

echo "Logging in as $TENANT_EMAIL..."
TOKEN=$(curl -s -X POST $TB_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$TENANT_EMAIL\",\"password\":\"$TENANT_PASSWORD\"}" \
  | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "Login failed"
    exit 1
fi

echo "Creating device: $DEVICE_NAME"
DEVICE=$(curl -s -X POST $TB_URL/api/tenant/devices \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"$DEVICE_NAME\",
    \"type\": \"waterMeter\",
    \"label\": \"Water Meter\"
  }")

echo "Device created:"
echo "$DEVICE" | jq .

DEVICE_ID=$(echo $DEVICE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$DEVICE_ID" ]; then
    echo ""
    echo "Getting device credentials..."
    CREDS=$(curl -s -X GET $TB_URL/api/tenant/devices/$DEVICE_ID/credentials \
      -H "Authorization: Bearer $TOKEN")
    
    echo "$CREDS" | jq .
fi
