# Script de test Cloud Functions sau khi update credentials

$PROJECT_ID = "llm-incident-duong-2024"
$REGION = "asia-southeast1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST CLOUD FUNCTIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get Function URLs
Write-Host "[1/3] Getting Function URLs..." -ForegroundColor Yellow

$REPORTING_URL = gcloud functions describe incidentReporting --gen2 --region=$REGION --format="value(serviceConfig.uri)" 2>&1
$ALERTING_URL = gcloud functions describe incidentAlerting --gen2 --region=$REGION --format="value(serviceConfig.uri)" 2>&1

if ($REPORTING_URL -match "http") {
    Write-Host "Reporting URL: $REPORTING_URL" -ForegroundColor Green
} else {
    Write-Host "Error getting Reporting URL: $REPORTING_URL" -ForegroundColor Red
    $REPORTING_URL = $null
}

if ($ALERTING_URL -match "http") {
    Write-Host "Alerting URL: $ALERTING_URL" -ForegroundColor Green
} else {
    Write-Host "Error getting Alerting URL: $ALERTING_URL" -ForegroundColor Red
    $ALERTING_URL = $null
}

Write-Host ""

# Test Reporting Function
if ($REPORTING_URL) {
    Write-Host "[2/3] Testing Reporting Function..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri $REPORTING_URL -Method Get -ErrorAction Stop
        Write-Host "Success! Function responded" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Check Google Sheets:" -ForegroundColor Yellow
        Write-Host "  https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit" -ForegroundColor Cyan
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
    }
} else {
    Write-Host "[2/3] Skipping Reporting test (URL not available)" -ForegroundColor Yellow
}

Write-Host ""

# Test Alerting Function
if ($ALERTING_URL) {
    Write-Host "[3/3] Testing Alerting Function..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri $ALERTING_URL -Method Get -ErrorAction Stop
        Write-Host "Success! Function responded" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Check Telegram for alerts (if threshold exceeded)" -ForegroundColor Yellow
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
    }
} else {
    Write-Host "[3/3] Skipping Alerting test (URL not available)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST HOAN TAT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

