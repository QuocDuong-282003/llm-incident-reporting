# Script deploy tất cả functions lên GCP

$PROJECT_ID = "llm-incident-duong-2024"
$REGION = "asia-southeast1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOY ALL FUNCTIONS TO GCP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project ID: $PROJECT_ID" -ForegroundColor Yellow
Write-Host "Region: $REGION" -ForegroundColor Yellow
Write-Host ""

# Set project
gcloud config set project $PROJECT_ID

# Enable APIs
Write-Host "[1/6] Enabling APIs..." -ForegroundColor Yellow
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
    gcloud services enable $api --quiet
}
Write-Host "✅ APIs enabled" -ForegroundColor Green
Write-Host ""

# Create Pub/Sub topics
Write-Host "[2/6] Creating Pub/Sub topics..." -ForegroundColor Yellow
$topics = @("raw-app-logs", "clean-app-logs")
foreach ($topic in $topics) {
    gcloud pubsub topics create $topic 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Topic $topic created" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Topic $topic may already exist" -ForegroundColor Yellow
    }
}
Write-Host ""

# Deploy Function 1: Log Processing
Write-Host "[3/6] Deploying logProcessing..." -ForegroundColor Yellow
Set-Location "cloud-functions/log-processing"
Rename-Item index.ts index.ts.hidden -ErrorAction SilentlyContinue
Rename-Item tsconfig.json tsconfig.json.hidden -ErrorAction SilentlyContinue

gcloud functions deploy logProcessing `
  --gen2 `
  --runtime=nodejs18 `
  --region=$REGION `
  --source=. `
  --entry-point=logProcessing `
  --trigger-topic=raw-app-logs `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},PUBSUB_CLEAN_LOGS_TOPIC=clean-app-logs" `
  --quiet

Rename-Item index.ts.hidden index.ts -ErrorAction SilentlyContinue
Rename-Item tsconfig.json.hidden tsconfig.json -ErrorAction SilentlyContinue
Set-Location "../.."
Write-Host "✅ logProcessing deployed" -ForegroundColor Green
Write-Host ""

# Deploy Function 2: LLM Analysis
Write-Host "[4/6] Deploying llmAnalysis..." -ForegroundColor Yellow
Set-Location "cloud-functions/llm-analysis"
Rename-Item index.ts index.ts.hidden -ErrorAction SilentlyContinue
Rename-Item tsconfig.json tsconfig.json.hidden -ErrorAction SilentlyContinue

gcloud functions deploy llmAnalysis `
  --gen2 `
  --runtime=nodejs18 `
  --region=$REGION `
  --source=. `
  --entry-point=llmAnalysis `
  --trigger-topic=clean-app-logs `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,LLM_PROVIDER=mock" `
  --quiet

Rename-Item index.ts.hidden index.ts -ErrorAction SilentlyContinue
Rename-Item tsconfig.json.hidden tsconfig.json -ErrorAction SilentlyContinue
Set-Location "../.."
Write-Host "✅ llmAnalysis deployed" -ForegroundColor Green
Write-Host ""

# Deploy Function 3: Incident Reporting
Write-Host "[5/6] Deploying incidentReporting..." -ForegroundColor Yellow
Set-Location "cloud-functions/incident-reporting"
Rename-Item index.ts index.ts.hidden -ErrorAction SilentlyContinue
Rename-Item tsconfig.json tsconfig.json.hidden -ErrorAction SilentlyContinue

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

Rename-Item index.ts.hidden index.ts -ErrorAction SilentlyContinue
Rename-Item tsconfig.json.hidden tsconfig.json -ErrorAction SilentlyContinue
Set-Location "../.."
Write-Host "✅ incidentReporting deployed" -ForegroundColor Green
Write-Host ""

# Deploy Function 4: Incident Alerting
Write-Host "[6/6] Deploying incidentAlerting..." -ForegroundColor Yellow
Set-Location "cloud-functions/incident-alerting"
Rename-Item index.ts index.ts.hidden -ErrorAction SilentlyContinue
Rename-Item tsconfig.json tsconfig.json.hidden -ErrorAction SilentlyContinue

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

Rename-Item index.ts.hidden index.ts -ErrorAction SilentlyContinue
Rename-Item tsconfig.json.hidden tsconfig.json -ErrorAction SilentlyContinue
Set-Location "../.."
Write-Host "✅ incidentAlerting deployed" -ForegroundColor Green
Write-Host ""

# Setup Cloud Scheduler
Write-Host "[7/6] Setting up Cloud Scheduler..." -ForegroundColor Yellow
$REPORTING_URL = gcloud functions describe incidentReporting --gen2 --region=$REGION --format="value(serviceConfig.uri)"
$ALERTING_URL = gcloud functions describe incidentAlerting --gen2 --region=$REGION --format="value(serviceConfig.uri)"

gcloud scheduler jobs create http incident-reporting-hourly `
  --location=$REGION `
  --schedule="0 * * * *" `
  --uri="$REPORTING_URL" `
  --http-method=GET `
  --time-zone="UTC" `
  --quiet 2>&1 | Out-Null

gcloud scheduler jobs create http incident-alerting-5min `
  --location=$REGION `
  --schedule="*/5 * * * *" `
  --uri="$ALERTING_URL" `
  --http-method=GET `
  --time-zone="UTC" `
  --quiet 2>&1 | Out-Null

Write-Host "✅ Cloud Scheduler jobs created" -ForegroundColor Green
Write-Host ""

# Tóm tắt
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT HOÀN TẤT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Các bước tiếp theo:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Setup Google Sheets:" -ForegroundColor White
Write-Host "   - Tạo Sheet: https://sheets.google.com" -ForegroundColor Gray
Write-Host "   - Share với: incident-reporting-sa@llm-incident-duong-2024.iam.gserviceaccount.com" -ForegroundColor Gray
Write-Host "   - Update function: .\SETUP_GOOGLE_SHEETS.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Setup Telegram Bot:" -ForegroundColor White
Write-Host "   - Tạo Bot: @BotFather trong Telegram" -ForegroundColor Gray
Write-Host "   - Update function: .\SETUP_TELEGRAM_BOT.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Test:" -ForegroundColor White
Write-Host "   - Gửi log qua API" -ForegroundColor Gray
Write-Host "   - Kiểm tra BigQuery" -ForegroundColor Gray
Write-Host "   - Kiểm tra Google Sheets" -ForegroundColor Gray
Write-Host "   - Kiểm tra Telegram alerts" -ForegroundColor Gray
Write-Host ""

