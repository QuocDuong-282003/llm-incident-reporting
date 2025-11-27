# 🚀 HƯỚNG DẪN DEPLOY ĐẦY ĐỦ - TỪNG BƯỚC

## 📋 THÔNG TIN CỦA BẠN

- **Project ID:** `llm-incident-duong-2024`
- **Service Account:** `incident-reporting-sa@llm-incident-duong-2024.iam.gserviceaccount.com`
- **Region:** `asia-southeast1`

---

## 🔵 BƯỚC 1: DEPLOY LÊN GCP

### 1.1. Kiểm tra prerequisites

```powershell
# Kiểm tra gcloud
gcloud --version

# Kiểm tra project
gcloud config get-value project

# Nếu chưa set, chạy:
gcloud config set project llm-incident-duong-2024
```

### 1.2. Enable APIs

```powershell
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable sheets.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### 1.3. Tạo Pub/Sub Topics

```powershell
gcloud pubsub topics create raw-app-logs
gcloud pubsub topics create clean-app-logs
```

### 1.4. Deploy Cloud Functions

#### Function 1: Log Processing

```powershell
cd cloud-functions/log-processing

# Tạm thời ẩn TypeScript files
Rename-Item index.ts index.ts.hidden -ErrorAction SilentlyContinue
Rename-Item tsconfig.json tsconfig.json.hidden -ErrorAction SilentlyContinue

# Deploy
gcloud functions deploy logProcessing `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=logProcessing `
  --trigger-topic=raw-app-logs `
  --set-env-vars="GCP_PROJECT_ID=llm-incident-duong-2024,PUBSUB_CLEAN_LOGS_TOPIC=clean-app-logs"

# Restore
Rename-Item index.ts.hidden index.ts -ErrorAction SilentlyContinue
Rename-Item tsconfig.json.hidden tsconfig.json -ErrorAction SilentlyContinue

cd ../..
```

#### Function 2: LLM Analysis

```powershell
cd cloud-functions/llm-analysis

# Tạm thời ẩn TypeScript files
Rename-Item index.ts index.ts.hidden -ErrorAction SilentlyContinue
Rename-Item tsconfig.json tsconfig.json.hidden -ErrorAction SilentlyContinue

# Deploy
gcloud functions deploy llmAnalysis `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=llmAnalysis `
  --trigger-topic=clean-app-logs `
  --set-env-vars="GCP_PROJECT_ID=llm-incident-duong-2024,BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,LLM_PROVIDER=mock"

# Restore
Rename-Item index.ts.hidden index.ts -ErrorAction SilentlyContinue
Rename-Item tsconfig.json.hidden tsconfig.json -ErrorAction SilentlyContinue

cd ../..
```

#### Function 3: Incident Reporting

```powershell
cd cloud-functions/incident-reporting

# Tạm thời ẩn TypeScript files
Rename-Item index.ts index.ts.hidden -ErrorAction SilentlyContinue
Rename-Item tsconfig.json tsconfig.json.hidden -ErrorAction SilentlyContinue

# Deploy (chưa có Sheet ID, sẽ update sau)
gcloud functions deploy incidentReporting `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=incidentReporting `
  --trigger-http `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=llm-incident-duong-2024,BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed"

# Restore
Rename-Item index.ts.hidden index.ts -ErrorAction SilentlyContinue
Rename-Item tsconfig.json.hidden tsconfig.json -ErrorAction SilentlyContinue

cd ../..
```

#### Function 4: Incident Alerting

```powershell
cd cloud-functions/incident-alerting

# Tạm thời ẩn TypeScript files
Rename-Item index.ts index.ts.hidden -ErrorAction SilentlyContinue
Rename-Item tsconfig.json tsconfig.json.hidden -ErrorAction SilentlyContinue

# Deploy (chưa có Telegram credentials, sẽ update sau)
gcloud functions deploy incidentAlerting `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=incidentAlerting `
  --trigger-http `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=llm-incident-duong-2024,BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,ALERT_THRESHOLD_COUNT=5,ALERT_TIME_WINDOW_MINUTES=15"

# Restore
Rename-Item index.ts.hidden index.ts -ErrorAction SilentlyContinue
Rename-Item tsconfig.json.hidden tsconfig.json -ErrorAction SilentlyContinue

cd ../..
```

### 1.5. Setup Cloud Scheduler

```powershell
# Lấy URLs
$REPORTING_URL = gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
$ALERTING_URL = gcloud functions describe incidentAlerting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"

# Tạo job hourly reporting
gcloud scheduler jobs create http incident-reporting-hourly `
  --location=asia-southeast1 `
  --schedule="0 * * * *" `
  --uri="$REPORTING_URL" `
  --http-method=GET `
  --time-zone="UTC"

# Tạo job 5-minute alerting
gcloud scheduler jobs create http incident-alerting-5min `
  --location=asia-southeast1 `
  --schedule="*/5 * * * *" `
  --uri="$ALERTING_URL" `
  --http-method=GET `
  --time-zone="UTC"
```

---

## 🟡 BƯỚC 2: SETUP GOOGLE SHEETS

### 2.1. Tạo Google Sheet

1. **Mở trình duyệt:** https://sheets.google.com
2. **Tạo sheet mới:** Click "Blank"
3. **Đặt tên:** "Incident Report"
4. **Lấy Sheet ID từ URL:**
   ```
   URL: https://docs.google.com/spreadsheets/d/1ABC123xyz.../edit
   Sheet ID: 1ABC123xyz... (phần giữa /d/ và /edit)
   ```

### 2.2. Share Sheet với Service Account

1. **Trong Google Sheet**, click nút **"Share"** (góc trên bên phải)
2. **Paste email Service Account:**
   ```
   incident-reporting-sa@llm-incident-duong-2024.iam.gserviceaccount.com
   ```
3. **Chọn quyền:** **"Editor"** (quan trọng!)
4. **Bỏ tick "Notify people"**
5. **Click "Share"**

### 2.3. Update Cloud Function với Sheet ID

```powershell
# Thay YOUR_SHEET_ID bằng Sheet ID bạn đã lấy
$SHEET_ID = "YOUR_SHEET_ID"

gcloud functions deploy incidentReporting `
  --gen2 `
  --region=asia-southeast1 `
  --update-env-vars="GOOGLE_SHEETS_ID=${SHEET_ID}"
```

### 2.4. Test Function

```powershell
$REPORTING_URL = gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
curl $REPORTING_URL
```

**Kiểm tra:** Mở Google Sheet và xem có dữ liệu được ghi vào không.

---

## 🟢 BƯỚC 3: SETUP TELEGRAM BOT

### 3.1. Tạo Telegram Bot

1. **Mở Telegram:** https://web.telegram.org hoặc app
2. **Tìm:** `@BotFather`
3. **Gửi lệnh:** `/newbot`
4. **Làm theo hướng dẫn:**
   - Tên bot: `Incident Alert Bot`
   - Username: `incident_alert_bot` (phải kết thúc bằng `bot`)
5. **Lưu Bot Token** (dạng: `123456789:ABCdef...`)

### 3.2. Lấy Chat ID

1. **Tìm:** `@userinfobot` trong Telegram
2. **Click "Start"**
3. **Copy Chat ID** (số trong dòng `Id:`)

### 3.3. Test Bot

```powershell
$BOT_TOKEN = "YOUR_BOT_TOKEN"
$CHAT_ID = "YOUR_CHAT_ID"

curl "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=Test message"
```

Nếu thành công, bạn sẽ nhận được message trong Telegram.

### 3.4. Update Cloud Function với Telegram Credentials

```powershell
$BOT_TOKEN = "YOUR_BOT_TOKEN"
$CHAT_ID = "YOUR_CHAT_ID"

gcloud functions deploy incidentAlerting `
  --gen2 `
  --region=asia-southeast1 `
  --update-env-vars="TELEGRAM_BOT_TOKEN=${BOT_TOKEN},TELEGRAM_CHAT_ID=${CHAT_ID}"
```

### 3.5. Test Function

```powershell
$ALERTING_URL = gcloud functions describe incidentAlerting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
curl $ALERTING_URL
```

**Kiểm tra:** Xem Telegram có nhận được alert không (nếu có sự cố vượt ngưỡng).

---

## ✅ BƯỚC 4: TEST END-TO-END

### 4.1. Test API (nếu deploy API lên Cloud Run)

```powershell
# Nếu có API URL
$API_URL = "https://your-api-url.run.app"

curl -X POST "${API_URL}/log/ingest" `
  -H "Content-Type: application/json" `
  -d '{\"service_name\":\"test-service\",\"severity\":\"error\",\"log_message\":\"Database connection timeout\"}'
```

### 4.2. Kiểm tra Flow

1. **Gửi log** → API nhận → Pub/Sub `raw-app-logs`
2. **Log Processing** → Chuẩn hóa → Pub/Sub `clean-app-logs`
3. **LLM Analysis** → Phân tích → BigQuery
4. **Reporting** (hàng giờ) → Google Sheets
5. **Alerting** (mỗi 5 phút) → Telegram (nếu vượt ngưỡng)

### 4.3. Kiểm tra Logs

```powershell
# Log Processing
gcloud functions logs read logProcessing --gen2 --region=asia-southeast1 --limit=10

# LLM Analysis
gcloud functions logs read llmAnalysis --gen2 --region=asia-southeast1 --limit=10

# Reporting
gcloud functions logs read incidentReporting --gen2 --region=asia-southeast1 --limit=10

# Alerting
gcloud functions logs read incidentAlerting --gen2 --region=asia-southeast1 --limit=10
```

### 4.4. Kiểm tra BigQuery

```powershell
bq query --use_legacy_sql=false "SELECT * FROM \`llm-incident-duong-2024.incident_reporting.Incidents_Analyzed\` LIMIT 10"
```

---

## 📋 CHECKLIST HOÀN THÀNH

### Deploy GCP
- [ ] Enable APIs
- [ ] Tạo Pub/Sub topics
- [ ] Deploy 4 Cloud Functions
- [ ] Setup Cloud Scheduler

### Google Sheets
- [ ] Tạo Google Sheet
- [ ] Lấy Sheet ID
- [ ] Share với Service Account (Editor)
- [ ] Update function với Sheet ID
- [ ] Test function

### Telegram Bot
- [ ] Tạo Bot với BotFather
- [ ] Lấy Bot Token
- [ ] Lấy Chat ID
- [ ] Test gửi message
- [ ] Update function với credentials
- [ ] Test function

### Test End-to-End
- [ ] Gửi log qua API
- [ ] Kiểm tra Pub/Sub
- [ ] Kiểm tra BigQuery
- [ ] Kiểm tra Google Sheets
- [ ] Kiểm tra Telegram alerts

---

## 🐛 TROUBLESHOOTING

### Lỗi: "Permission denied"
→ Kiểm tra Service Account có đủ roles:
```powershell
gcloud projects get-iam-policy llm-incident-duong-2024 --flatten="bindings[].members" --filter="bindings.members:incident-reporting-sa@llm-incident-duong-2024.iam.gserviceaccount.com"
```

### Lỗi: "Topic not found"
→ Tạo topics:
```powershell
gcloud pubsub topics create raw-app-logs clean-app-logs
```

### Lỗi: "Sheet not found" hoặc "Permission denied"
→ Kiểm tra đã share Sheet với Service Account chưa
→ Kiểm tra quyền là "Editor"

### Lỗi: "Telegram unauthorized"
→ Kiểm tra Bot Token đúng chưa
→ Kiểm tra Chat ID đúng chưa
→ Đảm bảo đã gửi `/start` cho bot

---

## 📝 TÓM TẮT NHANH

1. **Deploy Functions:** Chạy 4 lệnh deploy (ẩn .ts files trước)
2. **Setup Sheets:** Tạo Sheet → Share với SA → Update function
3. **Setup Telegram:** Tạo Bot → Lấy Token & Chat ID → Update function
4. **Test:** Gửi log → Kiểm tra flow

---

**Sẵn sàng bắt đầu? Bắt đầu từ Bước 1!** 🚀

