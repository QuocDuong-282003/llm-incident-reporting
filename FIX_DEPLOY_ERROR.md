# 🔧 SỬA LỖI DEPLOY: "dist/index.js does not exist"

## ❌ VẤN ĐỀ

Khi deploy, GCP báo lỗi:
```
ERROR: dist/index.js does not exist
```

**Nguyên nhân:** GCP phát hiện file `tsconfig.json` và cố build TypeScript thành `dist/index.js`, nhưng file thực tế là `index.js` ở root.

---

## ✅ GIẢI PHÁP

Đã tạo file `.gcloudignore` để GCP bỏ qua file TypeScript và chỉ dùng file `.js`.

### File đã tạo:
- ✅ `cloud-functions/incident-reporting/.gcloudignore`
- ✅ `cloud-functions/log-processing/.gcloudignore`
- ✅ `cloud-functions/llm-analysis/.gcloudignore`
- ✅ `cloud-functions/incident-alerting/.gcloudignore`

---

## 🚀 DEPLOY LẠI

### Cách 1: Deploy lại function incidentReporting

```powershell
cd cloud-functions/incident-reporting

$SHEET_ID = "1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc"

gcloud functions deploy incidentReporting `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=incidentReporting `
  --trigger-http `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=$(gcloud config get-value project),BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,GOOGLE_SHEETS_ID=${SHEET_ID}"
```

### Cách 2: Deploy từ root directory

```powershell
# Từ thư mục G:\New folder
$SHEET_ID = "1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc"

gcloud functions deploy incidentReporting `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=cloud-functions/incident-reporting `
  --entry-point=incidentReporting `
  --trigger-http `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=$(gcloud config get-value project),BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,GOOGLE_SHEETS_ID=${SHEET_ID}"
```

---

## 📋 KIỂM TRA TRƯỚC KHI DEPLOY

Đảm bảo file `index.js` tồn tại:

```powershell
cd cloud-functions/incident-reporting
Test-Path index.js
```

Nếu trả về `True` = File tồn tại ✅

---

## 🐛 NẾU VẪN LỖI

### Option 1: Xóa file tsconfig.json tạm thời

```powershell
cd cloud-functions/incident-reporting
# Backup
Copy-Item tsconfig.json tsconfig.json.bak
# Xóa
Remove-Item tsconfig.json
# Deploy
# ... (deploy command)
# Restore sau khi deploy xong
Copy-Item tsconfig.json.bak tsconfig.json
```

### Option 2: Đổi tên file .ts

```powershell
cd cloud-functions/incident-reporting
Rename-Item index.ts index.ts.bak
# Deploy
# ... (deploy command)
# Restore
Rename-Item index.ts.bak index.ts
```

---

## ✅ SAU KHI DEPLOY THÀNH CÔNG

1. **Kiểm tra function:**
   ```powershell
   gcloud functions describe incidentReporting --gen2 --region=asia-southeast1
   ```

2. **Test function:**
   ```powershell
   $URL = gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
   curl $URL
   ```

3. **Kiểm tra Google Sheet:**
   - Mở Sheet: https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit
   - Xem có dữ liệu được ghi vào không

---

## 📝 LƯU Ý

- File `.gcloudignore` sẽ bỏ qua file `.ts` và `tsconfig.json` khi deploy
- GCP sẽ chỉ dùng file `index.js`
- File `.ts` vẫn giữ lại để development

---

**Bây giờ thử deploy lại!** 🚀

