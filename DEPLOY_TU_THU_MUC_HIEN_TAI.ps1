# Script để deploy từ thư mục hiện tại

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOY TỪ THƯ MỤC HIỆN TẠI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra đang ở đâu
$currentDir = Get-Location
Write-Host "📍 Thư mục hiện tại: $currentDir" -ForegroundColor Yellow
Write-Host ""

# Kiểm tra file index.js có tồn tại không
if (-not (Test-Path "index.js")) {
    Write-Host "❌ Không tìm thấy file index.js!" -ForegroundColor Red
    Write-Host "   Đảm bảo bạn đang ở trong thư mục của Cloud Function" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Tìm thấy file index.js" -ForegroundColor Green
Write-Host ""

# Xác định function name từ thư mục
$functionName = Split-Path -Leaf $currentDir
Write-Host "🔍 Function name: $functionName" -ForegroundColor Yellow
Write-Host ""

# Nhập Sheet ID (nếu là incident-reporting)
if ($functionName -eq "incident-reporting") {
    $SHEET_ID = Read-Host "Nhập Google Sheet ID (hoặc Enter để dùng giá trị cũ)"
    if ([string]::IsNullOrWhiteSpace($SHEET_ID)) {
        $SHEET_ID = "1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc"
    }
}

# Nhập Telegram credentials (nếu là incident-alerting)
if ($functionName -eq "incident-alerting") {
    $BOT_TOKEN = Read-Host "Nhập Telegram Bot Token"
    $CHAT_ID = Read-Host "Nhập Telegram Chat ID"
}

$PROJECT_ID = gcloud config get-value project
Write-Host "✅ Project ID: $PROJECT_ID" -ForegroundColor Green
Write-Host ""

# Deploy dựa trên function name
Write-Host "🚀 Deploying $functionName..." -ForegroundColor Yellow
Write-Host ""

switch ($functionName) {
    "log-processing" {
        gcloud functions deploy logProcessing `
          --gen2 `
          --runtime=nodejs18 `
          --region=asia-southeast1 `
          --source=. `
          --entry-point=logProcessing `
          --trigger-topic=raw-app-logs `
          --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},PUBSUB_CLEAN_LOGS_TOPIC=clean-app-logs"
    }
    "llm-analysis" {
        gcloud functions deploy llmAnalysis `
          --gen2 `
          --runtime=nodejs18 `
          --region=asia-southeast1 `
          --source=. `
          --entry-point=llmAnalysis `
          --trigger-topic=clean-app-logs `
          --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,LLM_PROVIDER=mock"
    }
    "incident-reporting" {
        gcloud functions deploy incidentReporting `
          --gen2 `
          --runtime=nodejs18 `
          --region=asia-southeast1 `
          --source=. `
          --entry-point=incidentReporting `
          --trigger-http `
          --allow-unauthenticated `
          --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,GOOGLE_SHEETS_ID=${SHEET_ID}"
    }
    "incident-alerting" {
        gcloud functions deploy incidentAlerting `
          --gen2 `
          --runtime=nodejs18 `
          --region=asia-southeast1 `
          --source=. `
          --entry-point=incidentAlerting `
          --trigger-http `
          --allow-unauthenticated `
          --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,ALERT_THRESHOLD_COUNT=5,ALERT_TIME_WINDOW_MINUTES=15,TELEGRAM_BOT_TOKEN=${BOT_TOKEN},TELEGRAM_CHAT_ID=${CHAT_ID}"
    }
    default {
        Write-Host "❌ Không nhận diện được function name!" -ForegroundColor Red
        exit 1
    }
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  DEPLOY THÀNH CÔNG!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Deploy thất bại!" -ForegroundColor Red
}

