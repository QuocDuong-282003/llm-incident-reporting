# LLM-Driven Incident Reporting System

Hệ thống báo cáo sự cố tự động sử dụng LLM, được xây dựng với Node.js/TypeScript và Google Cloud Platform (GCP).

## 📋 Tổng quan

Hệ thống này tự động:
1. **Thu thập Log**: API endpoint nhận log thô và publish lên Pub/Sub
2. **Xử lý & Chuẩn hóa**: Cloud Function chuẩn hóa log thành format cố định
3. **Phân tích AI**: Sử dụng LLM (Mock/Gemini/OpenAI) để phân loại và tóm tắt sự cố
4. **Lưu trữ**: Lưu kết quả phân tích vào BigQuery
5. **Báo cáo Tự động**: Tự động export báo cáo hàng giờ vào Google Sheets
6. **Cảnh báo Khẩn cấp**: Gửi cảnh báo Telegram khi phát hiện sự cố nghiêm trọng

## 🏗️ Kiến trúc

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ POST /log/ingest
       ▼
┌─────────────────────┐
│  NestJS API Server  │
│  (Log Ingestion)    │
└──────┬──────────────┘
       │ Publish
       ▼
┌─────────────────────┐
│  Pub/Sub Topic      │
│  (raw-app-logs)     │
└──────┬──────────────┘
       │ Trigger
       ▼
┌─────────────────────┐
│  Cloud Function     │
│  (Log Processing)   │
│  - Normalize logs   │
└──────┬──────────────┘
       │ Publish
       ▼
┌─────────────────────┐
│  Pub/Sub Topic      │
│  (clean-app-logs)   │
└──────┬──────────────┘
       │ Trigger
       ▼
┌─────────────────────┐
│  Cloud Function     │
│  (LLM Analysis)     │
│  - Classify         │
│  - Summarize        │
└──────┬──────────────┘
       │ Insert
       ▼
┌─────────────────────┐
│  BigQuery           │
│  (Incidents_Analyzed)│
└──────┬──────────────┘
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌─────────────┐  ┌─────────────┐
│  Cloud      │  │  Cloud      │
│  Function   │  │  Function   │
│  (Reporting)│  │  (Alerting) │
└──────┬──────┘  └──────┬───────┘
       │                │
       ▼                ▼
┌─────────────┐  ┌─────────────┐
│ Google      │  │  Telegram   │
│ Sheets      │  │  Bot API    │
└─────────────┘  └─────────────┘
```

## 🚀 Cài đặt

### Yêu cầu

- Node.js 18+ và npm
- Google Cloud SDK (gcloud CLI)
- GCP Project với billing enabled
- Quyền truy cập: Cloud Functions, Pub/Sub, BigQuery, Cloud Scheduler

### Bước 1: Clone và cài đặt dependencies

```bash
# Cài đặt dependencies cho API server
npm install

# Cài đặt dependencies cho từng Cloud Function
cd cloud-functions/log-processing && npm install && cd ../..
cd cloud-functions/llm-analysis && npm install && cd ../..
cd cloud-functions/incident-reporting && npm install && cd ../..
cd cloud-functions/incident-alerting && npm install && cd ../..
```

### Bước 2: Cấu hình môi trường

Tạo file `.env` từ `.env.example`:

```bash
cp .env.example .env
```

Cập nhật các giá trị trong `.env`:

```env
GCP_PROJECT_ID=your-project-id
GCP_REGION=asia-southeast1
PUBSUB_RAW_LOGS_TOPIC=raw-app-logs
PUBSUB_CLEAN_LOGS_TOPIC=clean-app-logs
BIGQUERY_DATASET=incident_reporting
BIGQUERY_TABLE=Incidents_Analyzed
LLM_PROVIDER=mock  # hoặc 'openai' hoặc 'gemini'
OPENAI_API_KEY=your-openai-key  # nếu dùng OpenAI
GEMINI_API_KEY=your-gemini-key  # nếu dùng Gemini
GOOGLE_SHEETS_ID=your-sheet-id
GOOGLE_SHEETS_RANGE=Incident Report!A1
TELEGRAM_BOT_TOKEN=your-telegram-bot-token
TELEGRAM_CHAT_ID=your-chat-id
ALERT_THRESHOLD_COUNT=5
ALERT_TIME_WINDOW_MINUTES=15
```

### Bước 3: Xác thực GCP

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
```

### Bước 4: Deploy lên GCP

```bash
# Chạy script deploy tự động
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# Hoặc deploy thủ công từng function
cd cloud-functions/log-processing
gcloud functions deploy logProcessing --gen2 --runtime=nodejs18 --region=asia-southeast1 --source=. --entry-point=logProcessing --trigger-topic=raw-app-logs
```

### Bước 5: Setup Cloud Scheduler

```bash
chmod +x scripts/setup-scheduler.sh
./scripts/setup-scheduler.sh
```

## 🧪 Testing

### Chạy API server locally

```bash
npm run dev
```

### Test API endpoint

```bash
chmod +x scripts/test-api.sh
./scripts/test-api.sh
```

Hoặc test thủ công:

```bash
curl -X POST http://localhost:3000/log/ingest \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "auth-service",
    "severity": "error",
    "log_message": "Failed to authenticate user: Invalid token",
    "metadata": {
      "user_id": "12345"
    }
  }'
```

## 📁 Cấu trúc Project

```
.
├── src/                          # NestJS API Server
│   ├── main.ts                   # Entry point
│   ├── app.module.ts             # App module
│   ├── log/                      # Log ingestion module
│   │   ├── log.controller.ts
│   │   ├── log.service.ts
│   │   └── dto/
│   └── common/
│       └── pubsub.service.ts     # Pub/Sub service
│
├── cloud-functions/              # Cloud Functions
│   ├── log-processing/           # Normalize logs
│   │   ├── index.ts
│   │   └── package.json
│   ├── llm-analysis/            # LLM analysis
│   │   ├── index.ts
│   │   └── package.json
│   ├── incident-reporting/      # Google Sheets export
│   │   ├── index.ts
│   │   └── package.json
│   └── incident-alerting/       # Telegram alerts
│       ├── index.ts
│       └── package.json
│
├── scripts/                      # Deployment scripts
│   ├── deploy.sh
│   ├── setup-scheduler.sh
│   └── test-api.sh
│
├── package.json
├── tsconfig.json
└── README.md
```

## 🔧 Cấu hình chi tiết

### LLM Provider

Hệ thống hỗ trợ 3 LLM providers:

1. **Mock** (mặc định): Phân tích dựa trên keywords, không cần API key
2. **OpenAI**: Sử dụng GPT-3.5-turbo, cần `OPENAI_API_KEY`
3. **Gemini**: Sử dụng Google Gemini, cần `GEMINI_API_KEY`

Để đổi provider, set `LLM_PROVIDER` trong environment variables.

### Google Sheets Setup

1. Tạo Google Sheet mới
2. Lấy Sheet ID từ URL: `https://docs.google.com/spreadsheets/d/{SHEET_ID}/edit`
3. Set `GOOGLE_SHEETS_ID` trong `.env`
4. Đảm bảo Service Account có quyền edit sheet

### Telegram Bot Setup

1. Tạo bot với [@BotFather](https://t.me/botfather)
2. Lấy Bot Token
3. Lấy Chat ID (có thể dùng [@userinfobot](https://t.me/userinfobot))
4. Set `TELEGRAM_BOT_TOKEN` và `TELEGRAM_CHAT_ID` trong `.env`

## 📊 BigQuery Schema

Table `Incidents_Analyzed` có schema:

| Field | Type | Description |
|-------|------|-------------|
| timestamp | TIMESTAMP | Thời gian log gốc |
| service_name | STRING | Tên service |
| severity | STRING | Mức độ nghiêm trọng |
| full_log_text | STRING | Nội dung log đầy đủ |
| incident_type | STRING | Loại sự cố (AI phân loại) |
| incident_summary | STRING | Tóm tắt sự cố (AI tạo) |
| analyzed_at | TIMESTAMP | Thời gian phân tích |

## 🚨 Alerting Logic

Hệ thống cảnh báo tự động kiểm tra:
- **Điều kiện**: Số lượng sự cố loại "Database Connectivity Issue" >= threshold
- **Time Window**: 15 phút (có thể cấu hình)
- **Threshold**: 5 incidents (có thể cấu hình)
- **Action**: Gửi Telegram alert

## 🔍 Monitoring

### Xem logs Cloud Functions

```bash
gcloud functions logs read logProcessing --gen2 --region=asia-southeast1
gcloud functions logs read llmAnalysis --gen2 --region=asia-southeast1
```

### Query BigQuery

```sql
SELECT 
  incident_type,
  COUNT(*) as count,
  MAX(analyzed_at) as latest
FROM `your-project.incident_reporting.Incidents_Analyzed`
WHERE analyzed_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
GROUP BY incident_type
ORDER BY count DESC
```

## 🛠️ Development

### Build

```bash
npm run build
```

### Run locally

```bash
npm run dev
```

### Test Cloud Functions locally

```bash
# Install Functions Framework
npm install -g @google-cloud/functions-framework

# Run function locally
cd cloud-functions/log-processing
functions-framework --target=logProcessing --port=8080
```

## 📝 API Documentation

### POST /log/ingest

Nhận log thô và publish lên Pub/Sub.

**Request Body:**
```json
{
  "service_name": "string",
  "severity": "string",
  "log_message": "string",
  "metadata": {},
  "timestamp": "string (optional)"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Log ingested successfully",
  "messageId": "pubsub-message-id",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## 🎯 Các tính năng chính

✅ **Log Ingestion API** - NestJS endpoint nhận log  
✅ **Log Normalization** - Cloud Function chuẩn hóa log  
✅ **LLM Analysis** - Phân loại và tóm tắt sự cố bằng AI  
✅ **BigQuery Storage** - Lưu trữ kết quả phân tích  
✅ **Automated Reporting** - Export báo cáo vào Google Sheets  
✅ **Real-time Alerting** - Cảnh báo Telegram khi có sự cố nghiêm trọng  
✅ **Cloud Scheduler Integration** - Tự động hóa báo cáo và cảnh báo  

## 📚 Tài liệu tham khảo

- [Google Cloud Functions](https://cloud.google.com/functions/docs)
- [Google Cloud Pub/Sub](https://cloud.google.com/pubsub/docs)
- [Google BigQuery](https://cloud.google.com/bigquery/docs)
- [NestJS Documentation](https://docs.nestjs.com/)
- [Google Sheets API](https://developers.google.com/sheets/api)
- [Telegram Bot API](https://core.telegram.org/bots/api)

## 📄 License

MIT

---

**Lưu ý**: Đây là project test cho internship. Đảm bảo cấu hình đúng các credentials và permissions trước khi deploy production.

