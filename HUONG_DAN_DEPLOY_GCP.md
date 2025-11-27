# 🚀 HƯỚNG DẪN DEPLOY LÊN GCP - TỪNG BƯỚC

## 📋 BƯỚC 0: KIỂM TRA PREREQUISITES

### 1. Kiểm tra gcloud CLI

```powershell
gcloud --version
```

**Nếu chưa có:**
- Download: https://cloud.google.com/sdk/docs/install
- Hoặc: `winget install Google.CloudSDK`

### 2. Kiểm tra Node.js

```powershell
node --version
npm --version
```

### 3. Kiểm tra GCP Account

```powershell
gcloud auth list
```

**Nếu chưa login:**
```powershell
gcloud auth login
```

---

## 📋 BƯỚC 1: TẠO/SETUP GCP PROJECT

### 1.1. Tạo Project mới (nếu chưa có)

```powershell
gcloud projects create YOUR_PROJECT_ID --name="LLM Incident Reporting"
```

**Lưu ý:** `YOUR_PROJECT_ID` phải unique (ví dụ: `llm-incident-2024`)

### 1.2. Set project hiện tại

```powershell
gcloud config set project YOUR_PROJECT_ID
```

### 1.3. Enable Billing

- Vào: https://console.cloud.google.com/billing
- Link billing account với project

### 1.4. Enable các APIs cần thiết

```powershell
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable sheets.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

**Kiểm tra:**
```powershell
gcloud services list --enabled
```

---

## 📋 BƯỚC 2: SETUP AUTHENTICATION

### 2.1. Application Default Credentials

```powershell
gcloud auth application-default login
```

### 2.2. Tạo Service Account (cho Cloud Functions)

```powershell
gcloud iam service-accounts create incident-reporting-sa --display-name="Incident Reporting Service Account"
```

### 2.3. Gán roles cho Service Account

```powershell
PROJECT_ID=$(gcloud config get-value project)
SA_EMAIL="incident-reporting-sa@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:${SA_EMAIL}" --role="roles/pubsub.publisher"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:${SA_EMAIL}" --role="roles/pubsub.subscriber"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:${SA_EMAIL}" --role="roles/bigquery.dataEditor"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:${SA_EMAIL}" --role="roles/bigquery.jobUser"
```

---

## 📋 BƯỚC 3: TẠO PUB/SUB TOPICS

```powershell
gcloud pubsub topics create raw-app-logs
gcloud pubsub topics create clean-app-logs
```

**Kiểm tra:**
```powershell
gcloud pubsub topics list
```

---

## 📋 BƯỚC 4: DEPLOY API LÊN CLOUD RUN

### 4.1. Build Docker image

```powershell
PROJECT_ID=$(gcloud config get-value project)
docker build -t gcr.io/${PROJECT_ID}/log-ingestion-api .
```

### 4.2. Push lên Google Container Registry

```powershell
docker push gcr.io/${PROJECT_ID}/log-ingestion-api
```

### 4.3. Deploy lên Cloud Run

```powershell
gcloud run deploy log-ingestion-api `
  --image gcr.io/${PROJECT_ID}/log-ingestion-api `
  --platform managed `
  --region asia-southeast1 `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},PUBSUB_RAW_LOGS_TOPIC=raw-app-logs"
```

**Lưu URL trả về** (ví dụ: `https://log-ingestion-api-xxx.run.app`)

---

## 📋 BƯỚC 5: DEPLOY CLOUD FUNCTIONS

### 5.1. Log Processing Function

```powershell
cd cloud-functions/log-processing
npm install

gcloud functions deploy logProcessing `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=logProcessing `
  --trigger-topic=raw-app-logs `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},PUBSUB_CLEAN_LOGS_TOPIC=clean-app-logs"
cd ../..
```

### 5.2. LLM Analysis Function

```powershell
cd cloud-functions/llm-analysis
npm install

gcloud functions deploy llmAnalysis `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=llmAnalysis `
  --trigger-topic=clean-app-logs `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,LLM_PROVIDER=mock"
cd ../..
```

### 5.3. Incident Reporting Function

```powershell
cd cloud-functions/incident-reporting
npm install

gcloud functions deploy incidentReporting `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=incidentReporting `
  --trigger-http `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed"
cd ../..
```

**Lưu URL** (ví dụ: `https://incidentreporting-xxx.run.app`)

### 5.4. Incident Alerting Function

```powershell
cd cloud-functions/incident-alerting
npm install

gcloud functions deploy incidentAlerting `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=incidentAlerting `
  --trigger-http `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,ALERT_THRESHOLD_COUNT=5,ALERT_TIME_WINDOW_MINUTES=15"
cd ../..
```

**Lưu URL** (ví dụ: `https://incidentalerting-xxx.run.app`)

---

## 📋 BƯỚC 6: SETUP BIGQUERY

BigQuery dataset và table sẽ được tạo tự động khi function `llmAnalysis` chạy lần đầu.

**Hoặc tạo thủ công:**

```powershell
bq mk --dataset ${PROJECT_ID}:incident_reporting

bq mk --table ${PROJECT_ID}:incident_reporting.Incidents_Analyzed `
  timestamp:TIMESTAMP,service_name:STRING,severity:STRING,full_log_text:STRING,incident_type:STRING,incident_summary:STRING,analyzed_at:TIMESTAMP
```

---

## 📋 BƯỚC 7: SETUP GOOGLE SHEETS

### 7.1. Tạo Google Sheet

1. Tạo sheet mới: https://sheets.google.com
2. Đặt tên: "Incident Report"
3. Lấy Sheet ID từ URL: `https://docs.google.com/spreadsheets/d/{SHEET_ID}/edit`

### 7.2. Share với Service Account

```powershell
SHEET_ID="your-sheet-id"
SA_EMAIL="incident-reporting-sa@${PROJECT_ID}.iam.gserviceaccount.com"
```

- Vào Sheet → Share → Thêm email Service Account với quyền Editor

### 7.3. Update Function Environment

```powershell
gcloud functions deploy incidentReporting `
  --gen2 `
  --region=asia-southeast1 `
  --update-env-vars="GOOGLE_SHEETS_ID=${SHEET_ID}"
```

---

## 📋 BƯỚC 8: SETUP TELEGRAM BOT

### 8.1. Tạo Bot

1. Mở Telegram, tìm [@BotFather](https://t.me/botfather)
2. Gửi `/newbot`
3. Làm theo hướng dẫn, lấy Bot Token

### 8.2. Lấy Chat ID

1. Tìm [@userinfobot](https://t.me/userinfobot)
2. Gửi `/start`
3. Lấy Chat ID

### 8.3. Update Function Environment

```powershell
TELEGRAM_BOT_TOKEN="your-bot-token"
TELEGRAM_CHAT_ID="your-chat-id"

gcloud functions deploy incidentAlerting `
  --gen2 `
  --region=asia-southeast1 `
  --update-env-vars="TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN},TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID}"
```

---

## 📋 BƯỚC 9: SETUP CLOUD SCHEDULER

### 9.1. Get Function URLs

```powershell
REPORTING_URL=$(gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)")
ALERTING_URL=$(gcloud functions describe incidentAlerting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)")
```

### 9.2. Create Scheduler Jobs

```powershell
# Hourly reporting
gcloud scheduler jobs create http incident-reporting-hourly `
  --location=asia-southeast1 `
  --schedule="0 * * * *" `
  --uri="${REPORTING_URL}" `
  --http-method=GET `
  --time-zone="UTC"

# 5-minute alerting
gcloud scheduler jobs create http incident-alerting-5min `
  --location=asia-southeast1 `
  --schedule="*/5 * * * *" `
  --uri="${ALERTING_URL}" `
  --http-method=GET `
  --time-zone="UTC"
```

---

## 📋 BƯỚC 10: TEST END-TO-END

### 10.1. Test API

```powershell
API_URL="https://log-ingestion-api-xxx.run.app"

curl -X POST "${API_URL}/log/ingest" `
  -H "Content-Type: application/json" `
  -d '{\"service_name\":\"test-service\",\"severity\":\"error\",\"log_message\":\"Test log message\"}'
```

### 10.2. Kiểm tra Pub/Sub

```powershell
gcloud pubsub subscriptions list
```

### 10.3. Kiểm tra BigQuery

```powershell
bq query --use_legacy_sql=false "SELECT * FROM \`${PROJECT_ID}.incident_reporting.Incidents_Analyzed\` LIMIT 10"
```

### 10.4. Kiểm tra Function Logs

```powershell
gcloud functions logs read logProcessing --gen2 --region=asia-southeast1 --limit=10
gcloud functions logs read llmAnalysis --gen2 --region=asia-southeast1 --limit=10
```

---

## ✅ CHECKLIST HOÀN THÀNH

- [ ] GCP Project created
- [ ] APIs enabled
- [ ] Service Account created
- [ ] Pub/Sub topics created
- [ ] API deployed to Cloud Run
- [ ] 4 Cloud Functions deployed
- [ ] BigQuery dataset/table created
- [ ] Google Sheets configured
- [ ] Telegram Bot configured
- [ ] Cloud Scheduler jobs created
- [ ] End-to-end test passed

---

## 🐛 TROUBLESHOOTING

### Lỗi: "Permission denied"
→ Kiểm tra Service Account roles

### Lỗi: "Topic not found"
→ Tạo topics: `gcloud pubsub topics create raw-app-logs clean-app-logs`

### Lỗi: "Function not found"
→ Kiểm tra region và project ID

### Lỗi: "Billing not enabled"
→ Enable billing trong GCP Console

---

## 📝 LƯU CÁC THÔNG TIN QUAN TRỌNG

Tạo file `gcp-config.txt`:

```
PROJECT_ID=your-project-id
REGION=asia-southeast1
API_URL=https://log-ingestion-api-xxx.run.app
REPORTING_URL=https://incidentreporting-xxx.run.app
ALERTING_URL=https://incidentalerting-xxx.run.app
SHEET_ID=your-sheet-id
TELEGRAM_BOT_TOKEN=your-bot-token
TELEGRAM_CHAT_ID=your-chat-id
```

---

**Sẵn sàng bắt đầu? Bắt đầu từ Bước 0!** 🚀

