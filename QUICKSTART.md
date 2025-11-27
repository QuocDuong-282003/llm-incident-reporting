# 🚀 Quick Start Guide

Hướng dẫn nhanh để chạy hệ thống LLM-Driven Incident Reporting.

## Bước 1: Cài đặt Dependencies

```bash
# Root project
npm install

# Cloud Functions
cd cloud-functions/log-processing && npm install && cd ../..
cd cloud-functions/llm-analysis && npm install && cd ../..
cd cloud-functions/incident-reporting && npm install && cd ../..
cd cloud-functions/incident-alerting && npm install && cd ../..
```

## Bước 2: Cấu hình Environment Variables

Tạo file `.env`:

```env
GCP_PROJECT_ID=your-project-id
GCP_REGION=asia-southeast1
PUBSUB_RAW_LOGS_TOPIC=raw-app-logs
PUBSUB_CLEAN_LOGS_TOPIC=clean-app-logs
BIGQUERY_DATASET=incident_reporting
BIGQUERY_TABLE=Incidents_Analyzed
LLM_PROVIDER=mock
GOOGLE_SHEETS_ID=your-sheet-id
TELEGRAM_BOT_TOKEN=your-bot-token
TELEGRAM_CHAT_ID=your-chat-id
ALERT_THRESHOLD_COUNT=5
ALERT_TIME_WINDOW_MINUTES=15
```

## Bước 3: Xác thực GCP

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
```

## Bước 4: Chạy API Server Locally

```bash
npm run dev
```

API sẽ chạy tại `http://localhost:3000`

## Bước 5: Test API

```bash
curl -X POST http://localhost:3000/log/ingest \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "auth-service",
    "severity": "error",
    "log_message": "Failed to authenticate user: Invalid token"
  }'
```

## Bước 6: Deploy lên GCP

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

## Bước 7: Setup Cloud Scheduler

```bash
chmod +x scripts/setup-scheduler.sh
./scripts/setup-scheduler.sh
```

## 📝 Lưu ý

- Đảm bảo đã enable các GCP APIs cần thiết
- Cấu hình đúng Google Sheets và Telegram credentials
- Kiểm tra logs của Cloud Functions sau khi deploy

## 🔍 Kiểm tra Logs

```bash
# Xem logs của function
gcloud functions logs read logProcessing --gen2 --region=asia-southeast1 --limit=50

# Xem logs của API (nếu deploy lên Cloud Run)
gcloud run services logs read log-ingestion-api --region=asia-southeast1
```

## 🐛 Troubleshooting

### Lỗi Pub/Sub: Topic không tồn tại
```bash
gcloud pubsub topics create raw-app-logs
gcloud pubsub topics create clean-app-logs
```

### Lỗi BigQuery: Dataset không tồn tại
BigQuery dataset sẽ được tạo tự động khi function chạy lần đầu.

### Lỗi Permission
Đảm bảo Service Account có các roles:
- `roles/pubsub.publisher`
- `roles/pubsub.subscriber`
- `roles/bigquery.dataEditor`
- `roles/bigquery.jobUser`

