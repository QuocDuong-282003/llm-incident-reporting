# PowerShell script để setup Telegram Bot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP TELEGRAM BOT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[BƯỚC 1] Tạo Telegram Bot" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Mở Telegram (web: https://web.telegram.org)" -ForegroundColor White
Write-Host "2. Tìm: @BotFather" -ForegroundColor White
Write-Host "3. Gửi lệnh: /newbot" -ForegroundColor White
Write-Host "4. Làm theo hướng dẫn và lấy Bot Token" -ForegroundColor White
Write-Host ""
$BOT_TOKEN = Read-Host "Nhập Bot Token"

if ([string]::IsNullOrWhiteSpace($BOT_TOKEN)) {
    Write-Host "❌ Bot Token không được để trống!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[BƯỚC 2] Lấy Chat ID" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Tìm: @userinfobot trong Telegram" -ForegroundColor White
Write-Host "2. Click 'Start'" -ForegroundColor White
Write-Host "3. Copy Chat ID (số trong dòng 'Id:')" -ForegroundColor White
Write-Host ""
$CHAT_ID = Read-Host "Nhập Chat ID"

if ([string]::IsNullOrWhiteSpace($CHAT_ID)) {
    Write-Host "❌ Chat ID không được để trống!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[BƯỚC 3] Test Bot..." -ForegroundColor Yellow
Write-Host ""

$testUrl = "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=Test message from setup script"
try {
    $response = Invoke-RestMethod -Uri $testUrl -Method Get
    if ($response.ok) {
        Write-Host "✅ Test thành công! Kiểm tra Telegram của bạn." -ForegroundColor Green
    } else {
        Write-Host "⚠️  Test không thành công. Kiểm tra lại Bot Token và Chat ID." -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Không thể test. Tiếp tục với việc update function..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[BƯỚC 4] Update Cloud Function..." -ForegroundColor Yellow
Write-Host ""

gcloud functions deploy incidentAlerting `
  --gen2 `
  --region=asia-southeast1 `
  --update-env-vars="TELEGRAM_BOT_TOKEN=${BOT_TOKEN},TELEGRAM_CHAT_ID=${CHAT_ID}"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SETUP HOÀN TẤT!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 Test function:" -ForegroundColor Yellow
    $URL = gcloud functions describe incidentAlerting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
    Write-Host "   curl $URL" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✅ Nếu có sự cố vượt ngưỡng, bạn sẽ nhận được alert trong Telegram!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ Update function thất bại!" -ForegroundColor Red
}

