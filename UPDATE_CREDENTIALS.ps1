# Script de update Telegram va Google Sheets credentials

$PROJECT_ID = "llm-incident-duong-2024"
$REGION = "asia-southeast1"

# Telegram credentials
$TELEGRAM_BOT_TOKEN = "8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA"
$TELEGRAM_CHAT_ID = "5804844515"

# Google Sheets
$GOOGLE_SHEETS_ID = "1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  UPDATE CREDENTIALS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project: $PROJECT_ID" -ForegroundColor Yellow
Write-Host "Region: $REGION" -ForegroundColor Yellow
Write-Host ""

# Update Incident Reporting (Google Sheets)
Write-Host "[1/2] Updating incidentReporting with Google Sheets ID..." -ForegroundColor Yellow
gcloud functions deploy incidentReporting `
  --gen2 `
  --region=$REGION `
  --update-env-vars="GOOGLE_SHEETS_ID=${GOOGLE_SHEETS_ID}" `
  --quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Google Sheets ID updated" -ForegroundColor Green
} else {
    Write-Host "Warning: Update may have failed" -ForegroundColor Yellow
}

Write-Host ""

# Update Incident Alerting (Telegram)
Write-Host "[2/2] Updating incidentAlerting with Telegram credentials..." -ForegroundColor Yellow
gcloud functions deploy incidentAlerting `
  --gen2 `
  --region=$REGION `
  --update-env-vars="TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN},TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID}" `
  --quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Telegram credentials updated" -ForegroundColor Green
} else {
    Write-Host "Warning: Update may have failed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  UPDATE HOAN TAT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Credentials:" -ForegroundColor Yellow
Write-Host "  Telegram Bot Token: $TELEGRAM_BOT_TOKEN" -ForegroundColor White
Write-Host "  Telegram Chat ID: $TELEGRAM_CHAT_ID" -ForegroundColor White
Write-Host "  Google Sheets ID: $GOOGLE_SHEETS_ID" -ForegroundColor White
Write-Host ""
Write-Host "Test functions:" -ForegroundColor Yellow
Write-Host "  1. Reporting: Get URL and call it" -ForegroundColor Gray
Write-Host "  2. Alerting: Get URL and call it" -ForegroundColor Gray
Write-Host ""

