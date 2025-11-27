# 📁 HƯỚNG DẪN LÀM VIỆC VỚI ĐƯỜNG DẪN THƯ MỤC

## 📍 VỊ TRÍ HIỆN TẠI

Bạn đang ở:
```
PS G:\New folder\cloud-functions\incident-reporting>
```

Đây là thư mục của function `incident-reporting`.

---

## 🔄 CÁC LỆNH DI CHUYỂN

### Quay về thư mục gốc (G:\New folder)

```powershell
cd ..\..
```

Hoặc:

```powershell
cd "G:\New folder"
```

### Quay về thư mục cloud-functions

```powershell
cd ..
```

### Di chuyển đến thư mục khác

```powershell
# Vào thư mục incident-alerting
cd ..\incident-alerting

# Vào thư mục log-processing
cd ..\log-processing

# Vào thư mục llm-analysis
cd ..\llm-analysis
```

---

## 🚀 DEPLOY TỪ THƯ MỤC HIỆN TẠI

### Nếu bạn đang ở: `G:\New folder\cloud-functions\incident-reporting`

Chạy lệnh deploy trực tiếp (không cần `cd`):

```powershell
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
```

**Lưu ý:** `--source=.` nghĩa là deploy từ thư mục hiện tại.

---

## 🚀 DEPLOY TỪ THƯ MỤC GỐC

### Nếu bạn đang ở: `G:\New folder`

Chạy lệnh deploy với đường dẫn đầy đủ:

```powershell
$SHEET_ID = "1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc"
$PROJECT_ID = gcloud config get-value project

gcloud functions deploy incidentReporting `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=cloud-functions/incident-reporting `
  --entry-point=incidentReporting `
  --trigger-http `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,GOOGLE_SHEETS_ID=${SHEET_ID}"
```

**Lưu ý:** `--source=cloud-functions/incident-reporting` là đường dẫn từ thư mục gốc.

---

## 📋 CẤU TRÚC THƯ MỤC

```
G:\New folder\                          ← Thư mục gốc
├── src\                                 ← NestJS API
├── cloud-functions\                     ← Cloud Functions
│   ├── log-processing\                  ← Function 1
│   │   ├── index.js
│   │   └── package.json
│   ├── llm-analysis\                    ← Function 2
│   │   ├── index.js
│   │   └── package.json
│   ├── incident-reporting\              ← Function 3 (BẠN ĐANG Ở ĐÂY)
│   │   ├── index.js
│   │   └── package.json
│   └── incident-alerting\               ← Function 4
│       ├── index.js
│       └── package.json
└── scripts\                             ← Deployment scripts
```

---

## 🎯 CÁC TÌNH HUỐNG THƯỜNG GẶP

### Tình huống 1: Deploy function từ thư mục của nó

```powershell
# Bạn đang ở: G:\New folder\cloud-functions\incident-reporting
# Chạy:
gcloud functions deploy incidentReporting --source=. ...
```

### Tình huống 2: Deploy function từ thư mục gốc

```powershell
# Bạn đang ở: G:\New folder
# Chạy:
gcloud functions deploy incidentReporting --source=cloud-functions/incident-reporting ...
```

### Tình huống 3: Deploy tất cả functions từ thư mục gốc

```powershell
# Bạn đang ở: G:\New folder
# Chạy script:
.\deploy-gcp.ps1
```

---

## 💡 MẸO

### Xem thư mục hiện tại

```powershell
pwd
```

Hoặc:

```powershell
Get-Location
```

### Xem danh sách files trong thư mục

```powershell
ls
```

Hoặc:

```powershell
dir
```

### Kiểm tra file có tồn tại không

```powershell
Test-Path index.js
```

---

## ✅ TÓM TẮT

- **Đang ở:** `G:\New folder\cloud-functions\incident-reporting`
- **Deploy từ đây:** Dùng `--source=.`
- **Quay về gốc:** `cd ..\..`
- **Deploy từ gốc:** Dùng `--source=cloud-functions/incident-reporting`

---

**Bạn muốn deploy từ đâu?** 🤔

