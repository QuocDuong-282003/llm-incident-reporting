# Script de test credentials

$PROJECT_ID = "llm-incident-duong-2024"
$REGION = "asia-southeast1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST CREDENTIALS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test Telegram
Write-Host "[1/2] Testing Telegram Bot..." -ForegroundColor Yellow
$BOT_TOKEN = "8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA"
$CHAT_ID = "5804844515"

$telegramUrl = "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=Test message from script"
try {
    $response = Invoke-RestMethod -Uri $telegramUrl -Method Get
    if ($response.ok) {
        Write-Host "Success! Telegram bot is working" -ForegroundColor Green
        Write-Host "Check your Telegram to see the test message" -ForegroundColor Gray
    } else {
        Write-Host "Warning: Telegram API returned ok=false" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error testing Telegram: $_" -ForegroundColor Red
}

Write-Host ""

# Get Function URLs
Write-Host "[2/2] Getting Function URLs..." -ForegroundColor Yellow

$REPORTING_URL = gcloud functions describe incidentReporting --gen2 --region=$REGION --format="value(serviceConfig.uri)" 2>&1
$ALERTING_URL = gcloud functions describe incidentAlerting --gen2 --region=$REGION --format="value(serviceConfig.uri)" 2>&1

Write-Host ""
Write-Host "Function URLs:" -ForegroundColor Yellow
Write-Host "  Reporting: $REPORTING_URL" -ForegroundColor Cyan
Write-Host "  Alerting: $ALERTING_URL" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test commands:" -ForegroundColor Yellow
Write-Host "  curl $REPORTING_URL" -ForegroundColor Gray
Write-Host "  curl $ALERTING_URL" -ForegroundColor Gray
Write-Host ""

