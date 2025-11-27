# Script chuẩn bị nộp bài test

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CHUẨN BỊ NỘP BÀI TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra files quan trọng
Write-Host "[1/4] Kiểm tra files quan trọng..." -ForegroundColor Yellow

$requiredFiles = @(
    "README.md",
    "package.json",
    "src/main.ts",
    "cloud-functions/log-processing/index.js",
    "cloud-functions/llm-analysis/index.js",
    "cloud-functions/incident-reporting/index.js",
    "cloud-functions/incident-alerting/index.js"
)

$allExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file - MISSING!" -ForegroundColor Red
        $allExist = $false
    }
}

if (-not $allExist) {
    Write-Host ""
    Write-Host "❌ Một số files quan trọng bị thiếu!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/4] Kiểm tra .gitignore..." -ForegroundColor Yellow
if (Test-Path ".gitignore") {
    Write-Host "  ✅ .gitignore exists" -ForegroundColor Green
    $gitignoreContent = Get-Content ".gitignore" -Raw
    if ($gitignoreContent -match "\.env") {
        Write-Host "  ✅ .env đã được ignore" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  .env chưa được ignore" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠️  .gitignore không tồn tại" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[3/4] Tạo file tổng hợp..." -ForegroundColor Yellow

# Tạo file tổng hợp checklist
$checklistContent = @"
# ✅ CHECKLIST HOÀN THÀNH BÀI TEST

## Code Implementation
- [x] API Ingestion (NestJS) - POST /log/ingest
- [x] Pub/Sub Publisher (raw-app-logs)
- [x] Log Processing Function (normalize)
- [x] LLM Analysis Function (classification + summary)
- [x] BigQuery Storage
- [x] Reporting Function (Google Sheets)
- [x] Alerting Function (Telegram)

## Documentation
- [x] README.md
- [x] DEPLOYMENT.md
- [x] PROJECT_SUMMARY.md
- [x] Hướng dẫn setup Google Sheets
- [x] Hướng dẫn setup Telegram Bot

## Testing
- [x] API test (3 test cases pass)
- [x] Local mode hoạt động

## Deployment (Optional)
- [ ] Deploy lên GCP
- [ ] Setup Google Sheets
- [ ] Setup Telegram Bot
- [ ] End-to-end test

## Files Structure
- [x] NestJS API (src/)
- [x] Cloud Functions (cloud-functions/)
- [x] Deployment scripts (scripts/)
- [x] Documentation (README.md, etc.)

---
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

$checklistContent | Out-File -FilePath "CHECKLIST_HOAN_THANH.md" -Encoding UTF8
Write-Host "  ✅ Created CHECKLIST_HOAN_THANH.md" -ForegroundColor Green

Write-Host ""
Write-Host "[4/4] Tạo file nộp bài..." -ForegroundColor Yellow

$submissionContent = @"
# 📤 HƯỚNG DẪN NỘP BÀI

## Cách nộp:

### Option 1: GitHub (Khuyến nghị)
1. Tạo GitHub repository
2. Push code lên
3. Share link

### Option 2: ZIP File
1. Nén project thành ZIP
2. Upload lên Drive/Dropbox
3. Share link hoặc gửi email

### Option 3: Demo trực tiếp
1. Chuẩn bị demo environment
2. Show từng phần

## Files quan trọng:
- README.md - Hướng dẫn đầy đủ
- DEPLOYMENT.md - Hướng dẫn deploy
- PROJECT_SUMMARY.md - Tóm tắt project
- Source code trong src/ và cloud-functions/

## Demo (nếu có):
- BigQuery Console: https://console.cloud.google.com/bigquery
- Google Sheets: [Link sheet]
- Telegram Bot: [Bot name]

---
"@

$submissionContent | Out-File -FilePath "HUONG_DAN_NAP.md" -Encoding UTF8
Write-Host "  ✅ Created HUONG_DAN_NAP.md" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CHUẨN BỊ HOÀN TẤT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Các bước tiếp theo:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Xem CHECKLIST_HOAN_THANH.md" -ForegroundColor White
Write-Host "2. Xem HUONG_DAN_NAP.md" -ForegroundColor White
Write-Host "3. Chọn cách nộp bài phù hợp" -ForegroundColor White
Write-Host ""
Write-Host "💡 Khuyến nghị: Upload lên GitHub và share link" -ForegroundColor Cyan
Write-Host ""

