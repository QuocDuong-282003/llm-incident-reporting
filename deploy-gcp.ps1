# PowerShell script để deploy lên GCP tự động

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOY LLM INCIDENT REPORTING TO GCP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Bước 0: Kiểm tra prerequisites
Write-Host "[BƯỚC 0] Kiểm tra prerequisites..." -ForegroundColor Yellow

# Kiểm tra gcloud
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "❌ gcloud CLI chưa được cài đặt!" -ForegroundColor Red
    Write-Host "   Download tại: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ gcloud CLI đã cài đặt" -ForegroundColor Green

# Kiểm tra Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js chưa được cài đặt!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Node.js đã cài đặt" -ForegroundColor Green

# Kiểm tra đã login chưa
$authList = gcloud auth list --format="value(account)" 2>&1
if ($authList -match "No credentialed accounts") {
    Write-Host "⚠️  Chưa đăng nhập GCP!" -ForegroundColor Yellow
    Write-Host "   Đang mở trình duyệt để đăng nhập..." -ForegroundColor Yellow
    gcloud auth login
}
Write-Host "✅ Đã đăng nhập GCP" -ForegroundColor Green
Write-Host ""

# Bước 1: Nhập Project ID
Write-Host "[BƯỚC 1] Setup GCP Project" -ForegroundColor Yellow
$PROJECT_ID = Read-Host "Nhập GCP Project ID (hoặc Enter để tạo mới)"

if ([string]::IsNullOrWhiteSpace($PROJECT_ID)) {
    $PROJECT_ID = "llm-incident-" + (Get-Date -Format "yyyyMMddHHmmss")
    Write-Host "Tạo project mới: $PROJECT_ID" -ForegroundColor Yellow
    gcloud projects create $PROJECT_ID --name="LLM Incident Reporting"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Không thể tạo project. Có thể Project ID đã tồn tại." -ForegroundColor Red
        $PROJECT_ID = Read-Host "Nhập Project ID khác"
    }
}

gcloud config set project $PROJECT_ID
Write-Host "✅ Project ID: $PROJECT_ID" -ForegroundColor Green
Write-Host ""

# Bước 2: Enable APIs
Write-Host "[BƯỚC 2] Enable GCP APIs..." -ForegroundColor Yellow
$apis = @(
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "bigquery.googleapis.com",
    "cloudscheduler.googleapis.com",
    "sheets.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com"
)

foreach ($api in $apis) {
    Write-Host "  Enabling $api..." -ForegroundColor Gray
    gcloud services enable $api --quiet
}
Write-Host "✅ Tất cả APIs đã được enable" -ForegroundColor Green
Write-Host ""

# Bước 3: Tạo Pub/Sub Topics
Write-Host "[BƯỚC 3] Tạo Pub/Sub Topics..." -ForegroundColor Yellow
$topics = @("raw-app-logs", "clean-app-logs")
foreach ($topic in $topics) {
    Write-Host "  Creating topic: $topic..." -ForegroundColor Gray
    gcloud pubsub topics create $topic 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Topic $topic created" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Topic $topic có thể đã tồn tại" -ForegroundColor Yellow
    }
}
Write-Host ""

# Bước 4: Tạo Service Account
Write-Host "[BƯỚC 4] Tạo Service Account..." -ForegroundColor Yellow
$SA_NAME = "incident-reporting-sa"
$SA_EMAIL = "${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud iam service-accounts create $SA_NAME --display-name="Incident Reporting SA" 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Service Account created" -ForegroundColor Green
} else {
    Write-Host "⚠️  Service Account có thể đã tồn tại" -ForegroundColor Yellow
}

# Gán roles
Write-Host "  Gán roles cho Service Account..." -ForegroundColor Gray
$roles = @(
    "roles/pubsub.publisher",
    "roles/pubsub.subscriber",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
)

foreach ($role in $roles) {
    gcloud projects add-iam-policy-binding $PROJECT_ID `
        --member="serviceAccount:${SA_EMAIL}" `
        --role=$role `
        --quiet | Out-Null
}
Write-Host "✅ Roles đã được gán" -ForegroundColor Green
Write-Host ""

# Bước 5: Deploy Cloud Functions
Write-Host "[BƯỚC 5] Deploy Cloud Functions..." -ForegroundColor Yellow
$REGION = "asia-southeast1"

# 5.1. Log Processing
Write-Host "  [5.1] Deploying logProcessing..." -ForegroundColor Cyan
Set-Location "cloud-functions/log-processing"
npm install --silent
gcloud functions deploy logProcessing `
    --gen2 `
    --runtime=nodejs18 `
    --region=$REGION `
    --source=. `
    --entry-point=logProcessing `
    --trigger-topic=raw-app-logs `
    --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},PUBSUB_CLEAN_LOGS_TOPIC=clean-app-logs" `
    --quiet
Set-Location "../.."
Write-Host "  ✅ logProcessing deployed" -ForegroundColor Green

# 5.2. LLM Analysis
Write-Host "  [5.2] Deploying llmAnalysis..." -ForegroundColor Cyan
Set-Location "cloud-functions/llm-analysis"
npm install --silent
gcloud functions deploy llmAnalysis `
    --gen2 `
    --runtime=nodejs18 `
    --region=$REGION `
    --source=. `
    --entry-point=llmAnalysis `
    --trigger-topic=clean-app-logs `
    --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,LLM_PROVIDER=mock" `
    --quiet
Set-Location "../.."
Write-Host "  ✅ llmAnalysis deployed" -ForegroundColor Green

# 5.3. Incident Reporting
Write-Host "  [5.3] Deploying incidentReporting..." -ForegroundColor Cyan
Set-Location "cloud-functions/incident-reporting"
npm install --silent
gcloud functions deploy incidentReporting `
    --gen2 `
    --runtime=nodejs18 `
    --region=$REGION `
    --source=. `
    --entry-point=incidentReporting `
    --trigger-http `
    --allow-unauthenticated `
    --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed" `
    --quiet
$REPORTING_URL = gcloud functions describe incidentReporting --gen2 --region=$REGION --format="value(serviceConfig.uri)"
Set-Location "../.."
Write-Host "  ✅ incidentReporting deployed: $REPORTING_URL" -ForegroundColor Green

# 5.4. Incident Alerting
Write-Host "  [5.4] Deploying incidentAlerting..." -ForegroundColor Cyan
Set-Location "cloud-functions/incident-alerting"
npm install --silent
gcloud functions deploy incidentAlerting `
    --gen2 `
    --runtime=nodejs18 `
    --region=$REGION `
    --source=. `
    --entry-point=incidentAlerting `
    --trigger-http `
    --allow-unauthenticated `
    --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,ALERT_THRESHOLD_COUNT=5,ALERT_TIME_WINDOW_MINUTES=15" `
    --quiet
$ALERTING_URL = gcloud functions describe incidentAlerting --gen2 --region=$REGION --format="value(serviceConfig.uri)"
Set-Location "../.."
Write-Host "  ✅ incidentAlerting deployed: $ALERTING_URL" -ForegroundColor Green
Write-Host ""

# Bước 6: Setup Cloud Scheduler
Write-Host "[BƯỚC 6] Setup Cloud Scheduler..." -ForegroundColor Yellow

# Hourly reporting
Write-Host "  Creating hourly reporting job..." -ForegroundColor Gray
gcloud scheduler jobs create http incident-reporting-hourly `
    --location=$REGION `
    --schedule="0 * * * *" `
    --uri="$REPORTING_URL" `
    --http-method=GET `
    --time-zone="UTC" `
    --quiet 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Hourly reporting job created" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Job có thể đã tồn tại" -ForegroundColor Yellow
}

# 5-minute alerting
Write-Host "  Creating 5-minute alerting job..." -ForegroundColor Gray
gcloud scheduler jobs create http incident-alerting-5min `
    --location=$REGION `
    --schedule="*/5 * * * *" `
    --uri="$ALERTING_URL" `
    --http-method=GET `
    --time-zone="UTC" `
    --quiet 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ 5-minute alerting job created" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Job có thể đã tồn tại" -ForegroundColor Yellow
}
Write-Host ""

# Tóm tắt
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT HOÀN TẤT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Thông tin quan trọng:" -ForegroundColor Yellow
Write-Host "  Project ID: $PROJECT_ID" -ForegroundColor White
Write-Host "  Region: $REGION" -ForegroundColor White
Write-Host "  Reporting URL: $REPORTING_URL" -ForegroundColor White
Write-Host "  Alerting URL: $ALERTING_URL" -ForegroundColor White
Write-Host ""
Write-Host "📝 Các bước tiếp theo:" -ForegroundColor Yellow
Write-Host "  1. Setup Google Sheets (xem HUONG_DAN_DEPLOY_GCP.md)" -ForegroundColor White
Write-Host "  2. Setup Telegram Bot (xem HUONG_DAN_DEPLOY_GCP.md)" -ForegroundColor White
Write-Host "  3. Test API với Cloud Run URL" -ForegroundColor White
Write-Host ""
Write-Host "💾 Lưu thông tin vào file gcp-config.txt" -ForegroundColor Yellow

$configContent = @"
PROJECT_ID=$PROJECT_ID
REGION=$REGION
REPORTING_URL=$REPORTING_URL
ALERTING_URL=$ALERTING_URL
SHEET_ID=
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
"@

$configContent | Out-File -FilePath "gcp-config.txt" -Encoding UTF8
Write-Host "✅ Đã lưu vào gcp-config.txt" -ForegroundColor Green

