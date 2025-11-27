# 🔧 FIX: Deploy incidentReporting Function

## ❌ VẤN ĐỀ

GCP vẫn tìm `dist/index.js` mặc dù đã có file `index.js` ở root.

## ✅ GIẢI PHÁP

### Bước 1: Đảm bảo file index.js là JavaScript thuần

File `index.js` đã được tạo lại thành JavaScript thuần (không phải compiled từ TypeScript).

### Bước 2: Tạm thời đổi tên tsconfig.json

Khi deploy, tạm thời đổi tên file `tsconfig.json` để GCP không detect TypeScript:

```powershell
cd cloud-functions/incident-reporting

# Backup tsconfig.json
Copy-Item tsconfig.json tsconfig.json.bak

# Đổi tên (GCP sẽ không thấy)
Rename-Item tsconfig.json tsconfig.json.hidden

# Deploy
$SHEET_ID = "1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc"
$PROJECT_ID = gcloud config get-value project

gcloud functions deploy incidentReporting `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=incidentReporting `
  --trigger-http `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,GOOGLE_SHEETS_ID=${SHEET_ID}"

# Restore sau khi deploy
Rename-Item tsconfig.json.hidden tsconfig.json
```

### Bước 3: Hoặc xóa file .ts tạm thời

```powershell
cd cloud-functions/incident-reporting

# Backup
Copy-Item index.ts index.ts.bak

# Xóa
Remove-Item index.ts

# Deploy
# ... (deploy command)

# Restore
Copy-Item index.ts.bak index.ts
```

---

## 🚀 DEPLOY LỆNH ĐẦY ĐỦ

```powershell
cd cloud-functions/incident-reporting

# Tạm thời ẩn tsconfig.json
Rename-Item tsconfig.json tsconfig.json.hidden -ErrorAction SilentlyContinue

# Deploy
$SHEET_ID = "1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc"
$PROJECT_ID = gcloud config get-value project

gcloud functions deploy incidentReporting `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=incidentReporting `
  --trigger-http `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,GOOGLE_SHEETS_ID=${SHEET_ID}"

# Restore
Rename-Item tsconfig.json.hidden tsconfig.json -ErrorAction SilentlyContinue
```

---

## ✅ KIỂM TRA

Sau khi deploy thành công:

```powershell
# Kiểm tra function
gcloud functions describe incidentReporting --gen2 --region=asia-southeast1

# Test function
$URL = gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
curl $URL
```

