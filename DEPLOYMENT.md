# 📦 Deployment Guide

Hướng dẫn chi tiết để deploy hệ thống lên Google Cloud Platform.

## Prerequisites

1. **GCP Project** với billing enabled
2. **gcloud CLI** đã cài đặt và authenticated
3. **Node.js 18+** và npm
4. **Quyền truy cập** các GCP services:
   - Cloud Functions
   - Pub/Sub
   - BigQuery
   - Cloud Scheduler
   - Google Sheets API

## Bước 1: Enable GCP APIs

```bash
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable sheets.googleapis.com
gcloud services enable run.googleapis.com
```

## Bước 2: Tạo Pub/Sub Topics

```bash
gcloud pubsub topics create raw-app-logs
gcloud pubsub topics create clean-app-logs
```

## Bước 3: Deploy Cloud Functions

### Option A: Deploy tự động (Recommended)

```bash
chmod +x scripts/deploy.sh
export GCP_PROJECT_ID=your-project-id
export GCP_REGION=asia-southeast1
./scripts/deploy.sh
```

### Option B: Deploy thủ công từng function

#### 3.1. Log Processing Function

```bash
cd cloud-functions/log-processing
npm install
gcloud functions deploy logProcessing \
  --gen2 \
  --runtime=nodejs18 \
  --region=asia-southeast1 \
  --source=. \
  --entry-point=logProcessing \
  --trigger-topic=raw-app-logs \
  --set-env-vars="GCP_PROJECT_ID=your-project-id,PUBSUB_CLEAN_LOGS_TOPIC=clean-app-logs"
cd ../..
```

#### 3.2. LLM Analysis Function

```bash
cd cloud-functions/llm-analysis
npm install
gcloud functions deploy llmAnalysis \
  --gen2 \
  --runtime=nodejs18 \
  --region=asia-southeast1 \
  --source=. \
  --entry-point=llmAnalysis \
  --trigger-topic=clean-app-logs \
  --set-env-vars="GCP_PROJECT_ID=your-project-id,BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,LLM_PROVIDER=mock"
cd ../..
```

#### 3.3. Incident Reporting Function

```bash
cd cloud-functions/incident-reporting
npm install
gcloud functions deploy incidentReporting \
  --gen2 \
  --runtime=nodejs18 \
  --region=asia-southeast1 \
  --source=. \
  --entry-point=incidentReporting \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars="GCP_PROJECT_ID=your-project-id,BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,GOOGLE_SHEETS_ID=your-sheet-id"
cd ../..
```

#### 3.4. Incident Alerting Function

```bash
cd cloud-functions/incident-alerting
npm install
gcloud functions deploy incidentAlerting \
  --gen2 \
  --runtime=nodejs18 \
  --region=asia-southeast1 \
  --source=. \
  --entry-point=incidentAlerting \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars="GCP_PROJECT_ID=your-project-id,BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,ALERT_THRESHOLD_COUNT=5,ALERT_TIME_WINDOW_MINUTES=15,TELEGRAM_BOT_TOKEN=your-token,TELEGRAM_CHAT_ID=your-chat-id"
cd ../..
```

## Bước 4: Deploy API Server (NestJS)

### Option A: Deploy lên Cloud Run (Recommended)

```bash
# Build Docker image
docker build -t gcr.io/YOUR_PROJECT_ID/log-ingestion-api .

# Push to GCR
docker push gcr.io/YOUR_PROJECT_ID/log-ingestion-api

# Deploy to Cloud Run
gcloud run deploy log-ingestion-api \
  --image gcr.io/YOUR_PROJECT_ID/log-ingestion-api \
  --platform managed \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --set-env-vars="GCP_PROJECT_ID=your-project-id,PUBSUB_RAW_LOGS_TOPIC=raw-app-logs"
```

### Option B: Chạy locally hoặc trên VM

```bash
npm install
npm run build
npm start
```

## Bước 5: Setup Cloud Scheduler

```bash
chmod +x scripts/setup-scheduler.sh
export GCP_PROJECT_ID=your-project-id
export GCP_REGION=asia-southeast1
./scripts/setup-scheduler.sh
```

Hoặc tạo thủ công:

```bash
# Get function URLs
REPORTING_URL=$(gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)")
ALERTING_URL=$(gcloud functions describe incidentAlerting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)")

# Create hourly reporting job
gcloud scheduler jobs create http incident-reporting-hourly \
  --location=asia-southeast1 \
  --schedule="0 * * * *" \
  --uri="$REPORTING_URL" \
  --http-method=GET \
  --time-zone="UTC"

# Create 5-minute alerting job
gcloud scheduler jobs create http incident-alerting-5min \
  --location=asia-southeast1 \
  --schedule="*/5 * * * *" \
  --uri="$ALERTING_URL" \
  --http-method=GET \
  --time-zone="UTC"
```

## Bước 6: Cấu hình Service Account Permissions

Đảm bảo Cloud Functions service account có các roles:

```bash
PROJECT_NUMBER=$(gcloud projects describe YOUR_PROJECT_ID --format="value(projectNumber)")
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/pubsub.publisher"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/pubsub.subscriber"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/bigquery.jobUser"
```

## Bước 7: Cấu hình Google Sheets

1. Tạo Google Sheet mới
2. Lấy Sheet ID từ URL
3. Tạo Service Account và download key JSON
4. Share sheet với Service Account email
5. Set `GOOGLE_SHEETS_ID` trong function environment variables

## Bước 8: Cấu hình Telegram Bot

1. Tạo bot với [@BotFather](https://t.me/botfather)
2. Lấy Bot Token
3. Lấy Chat ID (dùng [@userinfobot](https://t.me/userinfobot))
4. Set `TELEGRAM_BOT_TOKEN` và `TELEGRAM_CHAT_ID` trong function environment variables

## Verification

### Test Log Ingestion

```bash
curl -X POST https://YOUR_API_URL/log/ingest \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "test-service",
    "severity": "error",
    "log_message": "Test log message"
  }'
```

### Check Function Logs

```bash
gcloud functions logs read logProcessing --gen2 --region=asia-southeast1 --limit=10
gcloud functions logs read llmAnalysis --gen2 --region=asia-southeast1 --limit=10
```

### Check BigQuery

```bash
bq query --use_legacy_sql=false \
  "SELECT * FROM \`your-project.incident_reporting.Incidents_Analyzed\` LIMIT 10"
```

### Test Reporting Function

```bash
REPORTING_URL=$(gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)")
curl $REPORTING_URL
```

### Test Alerting Function

```bash
ALERTING_URL=$(gcloud functions describe incidentAlerting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)")
curl $ALERTING_URL
```

## Troubleshooting

### Function không trigger từ Pub/Sub

- Kiểm tra topic name đúng
- Kiểm tra function có subscription tới topic
- Xem logs: `gcloud functions logs read FUNCTION_NAME --gen2 --region=REGION`

### BigQuery permission errors

- Đảm bảo service account có role `roles/bigquery.dataEditor`
- Kiểm tra dataset và table đã được tạo

### Google Sheets không ghi được

- Kiểm tra Service Account đã được share quyền edit sheet
- Kiểm tra Sheet ID đúng
- Xem logs của function để biết lỗi cụ thể

### Telegram không gửi được

- Kiểm tra Bot Token đúng
- Kiểm tra Chat ID đúng
- Test bot với curl trực tiếp

## Cost Estimation

- **Cloud Functions**: ~$0.40 per million invocations
- **Pub/Sub**: ~$40 per million messages
- **BigQuery**: ~$5 per TB queried
- **Cloud Scheduler**: Free (3 jobs free per month)

Ước tính chi phí cho 1000 logs/ngày: ~$5-10/tháng

