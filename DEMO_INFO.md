# THONG TIN QUAN TRONG - DEMO SAN PHAM

## GCP PROJECT

- **Project ID:** `llm-incident-duong-2024`
- **Region:** `asia-southeast1`

---

## API ENDPOINT

### Local Development:
- **URL:** `http://localhost:3001/log/ingest`
- **Method:** `POST`
- **Content-Type:** `application/json`

### Example Request:
```json
{
  "service_name": "auth-service",
  "severity": "error",
  "log_message": "User login failed",
  "metadata": {
    "user_id": "12345"
  }
}
```

---

## BIGQUERY

### Console:
https://console.cloud.google.com/bigquery?project=llm-incident-duong-2024

### Dataset & Table:
- **Dataset:** `incident_reporting`
- **Table:** `Incidents_Analyzed`

### Query Example:
```sql
SELECT * 
FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed` 
ORDER BY analyzed_at DESC 
LIMIT 10
```

---

## GOOGLE SHEETS

### Sheet URL:
https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit

### Sheet ID:
`1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc`

### Sheet Name:
`Incident Report`

### Columns:
- Timestamp
- Project
- Severity
- Description

---

## TELEGRAM BOT

### Bot Token:
`8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA`

### Chat ID:
`5804844515`

### Test URL:
https://api.telegram.org/bot8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA/getUpdates

### Send Message URL:
https://api.telegram.org/bot8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA/sendMessage

---

## CLOUD FUNCTIONS

### 1. logProcessing
- **Trigger:** Pub/Sub topic `raw-app-logs`
- **Output:** Pub/Sub topic `clean-app-logs`
- **Function:** Normalize raw logs

### 2. llmAnalysis
- **Trigger:** Pub/Sub topic `clean-app-logs`
- **Output:** BigQuery table `Incidents_Analyzed`
- **Function:** LLM analysis and classification

### 3. incidentReporting
- **Trigger:** Cloud Scheduler (hourly)
- **Output:** Google Sheets
- **Function:** Export incidents to Google Sheets

### 4. incidentAlerting
- **Trigger:** Cloud Scheduler (every 15 minutes)
- **Output:** Telegram Bot
- **Function:** Send alerts when threshold exceeded

---

## PUB/SUB TOPICS

- **raw-app-logs:** Raw logs from API
- **clean-app-logs:** Normalized logs

---

## CLOUD SCHEDULER JOBS

### 1. Hourly Reporting
- **Name:** `hourly-incident-reporting`
- **Schedule:** `0 * * * *` (every hour)
- **Target:** `incidentReporting` function

### 2. Alerting Check
- **Name:** `incident-alerting-check`
- **Schedule:** `*/15 * * * *` (every 15 minutes)
- **Target:** `incidentAlerting` function

---

## ALERT THRESHOLD

- **Incident Type:** `Database Connectivity Issue`
- **Threshold Count:** `5` incidents
- **Time Window:** `15` minutes

---

## SERVICE ACCOUNTS

### incident-reporting-sa
- **Email:** `incident-reporting-sa@llm-incident-duong-2024.iam.gserviceaccount.com`
- **Roles:**
  - BigQuery Data Editor
  - BigQuery Job User
  - Service Account User

---

## DEMO FLOW

1. **Send Log** → `POST /log/ingest`
2. **Log Processing** → Normalize log
3. **LLM Analysis** → Classify and summarize
4. **BigQuery** → Store analyzed incident
5. **Reporting** → Export to Google Sheets (hourly)
6. **Alerting** → Send Telegram alert (if threshold exceeded)

---

## TEST COMMANDS

### Test API (Local):
```powershell
.\demo-test-api.ps1
```

### Test Telegram:
```powershell
curl "https://api.telegram.org/bot8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA/sendMessage?chat_id=5804844515&text=Test message"
```

### Get Function URLs:
```powershell
gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
gcloud functions describe incidentAlerting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
```

---

## QUICK LINKS

- **BigQuery Console:** https://console.cloud.google.com/bigquery?project=llm-incident-duong-2024
- **Google Sheets:** https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit
- **Telegram Test:** https://api.telegram.org/bot8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA/getUpdates
- **GCP Console:** https://console.cloud.google.com/home/dashboard?project=llm-incident-duong-2024

---

**Luu y:** File nay chua tat ca thong tin quan trong de demo san pham. Luu lai de tham khao khi demo!

