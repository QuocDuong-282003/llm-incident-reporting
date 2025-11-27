#!/bin/bash

# Test script for the Log Ingestion API

API_URL=${API_URL:-"http://localhost:3000"}

echo "🧪 Testing Log Ingestion API at $API_URL"
echo ""

# Test 1: Authentication Error
echo "Test 1: Authentication Error"
curl -X POST "$API_URL/log/ingest" \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "auth-service",
    "severity": "error",
    "log_message": "Failed to authenticate user: Invalid token",
    "metadata": {
      "user_id": "12345",
      "ip_address": "192.168.1.1"
    }
  }'
echo -e "\n"

# Test 2: Database Connectivity Issue
echo "Test 2: Database Connectivity Issue"
curl -X POST "$API_URL/log/ingest" \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "database-service",
    "severity": "critical",
    "log_message": "Database connection timeout after 30 seconds",
    "metadata": {
      "db_host": "db.example.com",
      "retry_count": 3
    }
  }'
echo -e "\n"

# Test 3: Performance Issue
echo "Test 3: Performance Issue"
curl -X POST "$API_URL/log/ingest" \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "api-gateway",
    "severity": "warning",
    "log_message": "Request processing time exceeded 5 seconds",
    "metadata": {
      "endpoint": "/api/users",
      "response_time_ms": 5234
    }
  }'
echo -e "\n"

# Test 4: Resource Exhaustion
echo "Test 4: Resource Exhaustion"
curl -X POST "$API_URL/log/ingest" \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "compute-service",
    "severity": "error",
    "log_message": "Out of memory: Cannot allocate additional heap space",
    "metadata": {
      "memory_usage_mb": 8192,
      "max_memory_mb": 8192
    }
  }'
echo -e "\n"

echo "✅ Test completed!"

