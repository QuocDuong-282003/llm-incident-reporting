# Script test nhanh Telegram va Google Sheets

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST NHANH CREDENTIALS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test Telegram
Write-Host "[1/2] Testing Telegram Bot..." -ForegroundColor Yellow
$BOT_TOKEN = "8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA"
$CHAT_ID = "5804844515"

$telegramUrl = "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"
$body = @{
    chat_id = $CHAT_ID
    text = "Test message from PowerShell script - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $telegramUrl -Method Post -Body $body -ContentType "application/json"
    if ($response.ok) {
        Write-Host "Success! Telegram bot is working" -ForegroundColor Green
        Write-Host "Check your Telegram to see the test message" -ForegroundColor Gray
        Write-Host "Message ID: $($response.result.message_id)" -ForegroundColor Gray
    } else {
        Write-Host "Warning: Telegram API returned ok=false" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error testing Telegram: $_" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host ""

# Test Google Sheets (chi check URL)
Write-Host "[2/2] Google Sheets Info..." -ForegroundColor Yellow
$SHEET_ID = "1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc"
Write-Host "Sheet ID: $SHEET_ID" -ForegroundColor White
Write-Host "Sheet URL: https://docs.google.com/spreadsheets/d/${SHEET_ID}/edit" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: Sheet se duoc update boi Cloud Function khi co incident" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST HOAN TAT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Chay UPDATE_CREDENTIALS.ps1 de update Cloud Functions" -ForegroundColor White
Write-Host "  2. Test Cloud Functions sau khi update" -ForegroundColor White
Write-Host ""

