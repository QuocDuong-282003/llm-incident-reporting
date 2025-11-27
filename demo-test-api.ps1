# PowerShell script de demo test API

$API_ENDPOINT = $env:API_ENDPOINT
if ([string]::IsNullOrWhiteSpace($API_ENDPOINT)) {
    $API_ENDPOINT = Read-Host "Nhap API Endpoint (hoac Enter de dung http://localhost:3001)"
    if ([string]::IsNullOrWhiteSpace($API_ENDPOINT)) {
        $API_ENDPOINT = "http://localhost:3001"
    }
}

$API_ENDPOINT = "$API_ENDPOINT/log/ingest"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEMO: LLM INCIDENT REPORTING SYSTEM" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "API Endpoint: $API_ENDPOINT" -ForegroundColor Yellow
Write-Host ""

# Test 1: Authentication Error
Write-Host "[1/4] Test 1: Authentication Error" -ForegroundColor Yellow
$body1 = @{
    service_name = "auth-service"
    severity = "error"
    log_message = "User login failed due to invalid credentials"
    metadata = @{
        user_id = "12345"
        ip_address = "192.168.1.1"
    }
} | ConvertTo-Json -Depth 10

try {
    $response1 = Invoke-RestMethod -Uri $API_ENDPOINT -Method Post -Body $body1 -ContentType "application/json"
    Write-Host "Success! Message ID: $($response1.messageId)" -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 2

# Test 2: Database Error (Critical)
Write-Host ""
Write-Host "[2/4] Test 2: Database Connectivity Issue" -ForegroundColor Yellow
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
    $response2 = Invoke-RestMethod -Uri $API_ENDPOINT -Method Post -Body $body2 -ContentType "application/json"
    Write-Host "Success! Message ID: $($response2.messageId)" -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 2

# Test 3: Database Error (Critical) - Them de test alert
Write-Host ""
Write-Host "[3/4] Test 3: Database Connectivity Issue - Part 2" -ForegroundColor Yellow
$body3 = @{
    service_name = "database-service"
    severity = "critical"
    log_message = "Database connection failed. Cannot establish connection"
    metadata = @{
        db_host = "db.example.com"
        retry_count = 5
    }
} | ConvertTo-Json -Depth 10

try {
    $response3 = Invoke-RestMethod -Uri $API_ENDPOINT -Method Post -Body $body3 -ContentType "application/json"
    Write-Host "Success! Message ID: $($response3.messageId)" -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 2

# Test 4: Performance Issue
Write-Host ""
Write-Host "[4/4] Test 4: Performance Issue" -ForegroundColor Yellow
$body4 = @{
    service_name = "api-gateway"
    severity = "warning"
    log_message = "Request processing time exceeded 5 seconds"
    metadata = @{
        endpoint = "/api/users"
        response_time_ms = 5234
    }
} | ConvertTo-Json -Depth 10

try {
    $response4 = Invoke-RestMethod -Uri $API_ENDPOINT -Method Post -Body $body4 -ContentType "application/json"
    Write-Host "Success! Message ID: $($response4.messageId)" -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEMO HOAN TAT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Cac buoc tiep theo de xem ket qua:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. BigQuery Console:" -ForegroundColor White
Write-Host "   https://console.cloud.google.com/bigquery?project=llm-incident-duong-2024" -ForegroundColor Cyan
Write-Host "   Query: SELECT * FROM \`llm-incident-duong-2024.incident_reporting.Incidents_Analyzed\` ORDER BY analyzed_at DESC LIMIT 10" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Google Sheets (neu da setup):" -ForegroundColor White
Write-Host "   https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit" -ForegroundColor Cyan
Write-Host "   Mo sheet 'Incident Report' de xem bao cao" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Telegram (neu da setup):" -ForegroundColor White
Write-Host "   https://api.telegram.org/bot8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA/getUpdates" -ForegroundColor Cyan
Write-Host "   Kiem tra bot de xem alerts" -ForegroundColor Gray
Write-Host ""
