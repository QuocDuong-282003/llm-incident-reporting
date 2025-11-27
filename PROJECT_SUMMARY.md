# 📋 Project Summary - LLM-Driven Incident Reporting

## Tổng quan

Hệ thống báo cáo sự cố tự động sử dụng LLM, được xây dựng hoàn toàn bằng **Node.js/TypeScript** và các dịch vụ **Google Cloud Platform**.

## ✅ Các tính năng đã hoàn thành

### 1. Data Ingestion & Endpoint ✅
- ✅ **NestJS API Server** với endpoint `POST /log/ingest`
- ✅ **Pub/Sub Integration** - Publish logs lên topic `raw-app-logs`
- ✅ **Validation** - Sử dụng class-validator cho input validation
- ✅ **Error Handling** - Xử lý lỗi đầy đủ

### 2. Serverless Log Processing ✅
- ✅ **Cloud Function** - Triggered by Pub/Sub `raw-app-logs`
- ✅ **Log Normalization** - Chuẩn hóa thành format cố định:
  - `timestamp`
  - `service_name`
  - `severity`
  - `full_log_text`
- ✅ **Pub/Sub Publishing** - Publish normalized logs lên `clean-app-logs`

### 3. LLM Incident Analysis ✅
- ✅ **Cloud Function** - Triggered by Pub/Sub `clean-app-logs`
- ✅ **LLM Integration** - Hỗ trợ 3 providers:
  - **Mock** (default) - Phân tích dựa trên keywords
  - **OpenAI** - Sử dụng GPT-3.5-turbo
  - **Gemini** - Sử dụng Google Gemini
- ✅ **Incident Classification** - Phân loại sự cố:
  - Authentication Error
  - Database Connectivity Issue
  - Performance Issue
  - Resource Exhaustion
  - General Error
- ✅ **Incident Summary** - Tạo tóm tắt 1-2 câu
- ✅ **BigQuery Storage** - Lưu kết quả vào table `Incidents_Analyzed`

### 4. Automated Reporting ✅
- ✅ **Cloud Function** - HTTP trigger (cho Cloud Scheduler)
- ✅ **BigQuery Query** - Lấy incidents trong 1 giờ gần nhất
- ✅ **Google Sheets Integration** - Tự động export vào Google Sheets
- ✅ **Cloud Scheduler** - Chạy hàng giờ tự động

### 5. Alerting System ✅
- ✅ **Cloud Function** - HTTP trigger (cho Cloud Scheduler)
- ✅ **Threshold Monitoring** - Kiểm tra số lượng sự cố
- ✅ **Telegram Integration** - Gửi cảnh báo khẩn cấp
- ✅ **Cloud Scheduler** - Chạy mỗi 5 phút
- ✅ **Configurable Thresholds** - Có thể cấu hình ngưỡng và time window

## 📁 Cấu trúc Project

```
.
├── src/                          # NestJS API Server
│   ├── main.ts
│   ├── app.module.ts
│   ├── log/
│   │   ├── log.controller.ts
│   │   ├── log.service.ts
│   │   └── dto/log-ingest.dto.ts
│   └── common/
│       └── pubsub.service.ts
│
├── cloud-functions/              # 4 Cloud Functions
│   ├── log-processing/          # Normalize logs
│   ├── llm-analysis/            # AI analysis
│   ├── incident-reporting/      # Google Sheets export
│   └── incident-alerting/       # Telegram alerts
│
├── scripts/                      # Deployment scripts
│   ├── deploy.sh
│   ├── setup-scheduler.sh
│   └── test-api.sh
│
├── examples/                     # Test examples
│   ├── test-logs.json
│   └── send-test-logs.sh
│
├── package.json
├── tsconfig.json
├── Dockerfile
├── README.md
├── QUICKSTART.md
├── DEPLOYMENT.md
└── PROJECT_SUMMARY.md
```

## 🔄 Data Flow

```
1. Client → POST /log/ingest
   ↓
2. NestJS API → Pub/Sub (raw-app-logs)
   ↓
3. Cloud Function (log-processing) → Normalize
   ↓
4. Pub/Sub (clean-app-logs)
   ↓
5. Cloud Function (llm-analysis) → AI Analysis
   ↓
6. BigQuery (Incidents_Analyzed)
   ↓
7a. Cloud Function (incident-reporting) → Google Sheets (hourly)
7b. Cloud Function (incident-alerting) → Telegram (every 5 min)
```

## 🛠️ Technologies Used

- **Backend Framework**: NestJS (Node.js/TypeScript)
- **Cloud Functions**: Google Cloud Functions (Gen2)
- **Message Queue**: Google Cloud Pub/Sub
- **Data Warehouse**: Google BigQuery
- **LLM Providers**: Mock/OpenAI/Gemini
- **Reporting**: Google Sheets API
- **Alerting**: Telegram Bot API
- **Orchestration**: Google Cloud Scheduler

## 📊 BigQuery Schema

Table: `Incidents_Analyzed`

| Column | Type | Description |
|--------|------|-------------|
| timestamp | TIMESTAMP | Thời gian log gốc |
| service_name | STRING | Tên service |
| severity | STRING | Mức độ (error/warning/critical) |
| full_log_text | STRING | Nội dung log đầy đủ |
| incident_type | STRING | Loại sự cố (AI phân loại) |
| incident_summary | STRING | Tóm tắt sự cố (AI tạo) |
| analyzed_at | TIMESTAMP | Thời gian phân tích |

## 🎯 Key Features

1. **Scalable Architecture** - Serverless, auto-scaling
2. **Real-time Processing** - Pub/Sub event-driven
3. **AI-Powered Analysis** - LLM classification và summarization
4. **Automated Reporting** - Tự động export hàng giờ
5. **Proactive Alerting** - Cảnh báo real-time qua Telegram
6. **Flexible LLM** - Hỗ trợ nhiều providers
7. **Production Ready** - Error handling, logging, validation

## 📝 API Endpoints

### POST /log/ingest

**Request:**
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

## 🚀 Deployment

### Quick Deploy

```bash
# 1. Install dependencies
npm install

# 2. Configure .env
cp .env.example .env
# Edit .env with your credentials

# 3. Deploy
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# 4. Setup Scheduler
chmod +x scripts/setup-scheduler.sh
./scripts/setup-scheduler.sh
```

### Manual Steps

1. Enable GCP APIs
2. Create Pub/Sub topics
3. Deploy 4 Cloud Functions
4. Deploy NestJS API (Cloud Run hoặc VM)
5. Setup Cloud Scheduler jobs
6. Configure Google Sheets & Telegram

Xem chi tiết trong `DEPLOYMENT.md`

## 🧪 Testing

```bash
# Run API locally
npm run dev

# Test API
chmod +x scripts/test-api.sh
./scripts/test-api.sh

# Or use examples
cd examples
chmod +x send-test-logs.sh
./send-test-logs.sh
```

## 📈 Monitoring

- **Cloud Functions Logs**: `gcloud functions logs read FUNCTION_NAME --gen2`
- **BigQuery**: Query table `Incidents_Analyzed`
- **Pub/Sub**: Monitor message throughput
- **Cloud Scheduler**: Check job execution history

## 🔒 Security

- ✅ Input validation với class-validator
- ✅ Environment variables cho sensitive data
- ✅ Service Account permissions
- ✅ HTTPS only (Cloud Run)
- ✅ IAM roles và policies

## 💰 Cost Estimation

Với 1000 logs/ngày:
- Cloud Functions: ~$0.50/tháng
- Pub/Sub: ~$1.20/tháng
- BigQuery: ~$2-5/tháng
- **Total: ~$5-10/tháng**

## 🎓 Learning Outcomes

Project này thể hiện:

1. ✅ Kiến trúc microservices/serverless
2. ✅ Event-driven architecture với Pub/Sub
3. ✅ LLM integration và prompt engineering
4. ✅ BigQuery data warehousing
5. ✅ Automation với Cloud Scheduler
6. ✅ API integration (Google Sheets, Telegram)
7. ✅ TypeScript/Node.js best practices
8. ✅ GCP services integration
9. ✅ Error handling và logging
10. ✅ Deployment và DevOps

## 📚 Documentation

- `README.md` - Tổng quan và hướng dẫn đầy đủ
- `QUICKSTART.md` - Hướng dẫn nhanh
- `DEPLOYMENT.md` - Hướng dẫn deploy chi tiết
- `PROJECT_SUMMARY.md` - Tóm tắt project (file này)

## 🎯 Next Steps (Optional Enhancements)

- [ ] Add authentication/authorization
- [ ] Add rate limiting
- [ ] Add metrics và monitoring (Cloud Monitoring)
- [ ] Add unit tests và integration tests
- [ ] Add CI/CD pipeline
- [ ] Add dashboard (Data Studio hoặc custom)
- [ ] Support multiple LLM providers simultaneously
- [ ] Add incident deduplication
- [ ] Add webhook notifications
- [ ] Add incident resolution tracking

---

**Status**: ✅ **COMPLETE** - Tất cả requirements đã được implement đầy đủ!

**Ready for**: Demo, Testing, Production deployment

