# PowerShell script để test API đơn giản

Write-Host "Testing Log Ingestion API..." -ForegroundColor Green
Write-Host ""

$apiUrl = "http://localhost:3001"

# Test 1: Authentication Error
Write-Host "Test 1: Authentication Error" -ForegroundColor Yellow
$body1 = @{
    service_name = "auth-service"
    severity = "error"
    log_message = "Failed to authenticate user: Invalid token"
    metadata = @{
        user_id = "12345"
        ip_address = "192.168.1.1"
    }
} | ConvertTo-Json -Depth 10

try {
    $response1 = Invoke-RestMethod -Uri "$apiUrl/log/ingest" -Method Post -Body $body1 -ContentType "application/json"
    Write-Host "Success!" -ForegroundColor Green
    $response1 | ConvertTo-Json
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: Database Error
Write-Host "Test 2: Database Connectivity Issue" -ForegroundColor Yellow
$body2 = @{
    service_name = "database-service"
    severity = "critical"
    log_message = "Database connection timeout after 30 seconds"
    metadata = @{
        db_host = "db.example.com"
        retry_count = 3
    }
} | ConvertTo-Json -Depth 10

try {
    $response2 = Invoke-RestMethod -Uri "$apiUrl/log/ingest" -Method Post -Body $body2 -ContentType "application/json"
    Write-Host "Success!" -ForegroundColor Green
    $response2 | ConvertTo-Json
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 3: Performance Issue
Write-Host "Test 3: Performance Issue" -ForegroundColor Yellow
$body3 = @{
    service_name = "api-gateway"
    severity = "warning"
    log_message = "Request processing time exceeded 5 seconds"
    metadata = @{
        endpoint = "/api/users"
        response_time_ms = 5234
    }
} | ConvertTo-Json -Depth 10

try {
    $response3 = Invoke-RestMethod -Uri "$apiUrl/log/ingest" -Method Post -Body $body3 -ContentType "application/json"
    Write-Host "Success!" -ForegroundColor Green
    $response3 | ConvertTo-Json
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Testing completed!" -ForegroundColor Green

