# 📊 HƯỚNG DẪN SETUP GOOGLE SHEETS API

## 🎯 MỤC TIÊU

Setup Google Sheets để hệ thống tự động export báo cáo sự cố vào Google Sheets.

---

## 📋 BƯỚC 1: TẠO GOOGLE SHEET

### 1.1. Tạo Sheet mới

1. **Mở trình duyệt**, truy cập:
   ```
   https://sheets.google.com
   ```

2. **Click "Blank"** để tạo sheet mới

3. **Đặt tên sheet:**
   - Click vào "Untitled spreadsheet" ở góc trên
   - Đổi tên thành: **"Incident Report"**
   - Nhấn Enter

### 1.2. Lấy Sheet ID

1. **Xem URL** trong thanh địa chỉ:
   ```
   https://docs.google.com/spreadsheets/d/1ABC123xyz.../edit
   ```

2. **Copy phần Sheet ID** (phần giữa `/d/` và `/edit`):
   ```
   Sheet ID: 1ABC123xyz...
   ```

3. **Lưu Sheet ID này lại** (sẽ dùng ở bước sau)

---

## 📋 BƯỚC 2: TẠO SERVICE ACCOUNT

### 2.1. Truy cập Google Cloud Console

1. **Mở trình duyệt**, truy cập:
   ```
   https://console.cloud.google.com
   ```

2. **Chọn project** của bạn (project đã tạo khi deploy)

### 2.2. Tạo Service Account

1. **Vào menu** (☰) → **IAM & Admin** → **Service Accounts**

   Hoặc truy cập trực tiếp:
   ```
   https://console.cloud.google.com/iam-admin/serviceaccounts
   ```

2. **Click "CREATE SERVICE ACCOUNT"**

3. **Điền thông tin:**
   - Service account name: `sheets-service-account`
   - Service account ID: (tự động tạo)
   - Description: `Service account for Google Sheets API`

4. **Click "CREATE AND CONTINUE"**

5. **Skip bước Grant access** → Click "CONTINUE"

6. **Click "DONE"**

### 2.3. Tạo Key cho Service Account

1. **Click vào Service Account** vừa tạo (`sheets-service-account`)

2. **Vào tab "KEYS"**

3. **Click "ADD KEY"** → **"Create new key"**

4. **Chọn "JSON"** → Click "CREATE"

5. **File JSON sẽ tự động download** về máy
   - Lưu file này ở đâu đó an toàn (ví dụ: `G:\New folder\gcp-key.json`)

---

## 📋 BƯỚC 3: SHARE SHEET VỚI SERVICE ACCOUNT

### 3.1. Lấy Email của Service Account

1. **Quay lại Google Cloud Console**
   - Vào **Service Accounts**
   - Click vào service account vừa tạo
   - **Copy email** (ví dụ: `sheets-service-account@your-project.iam.gserviceaccount.com`)

### 3.2. Share Sheet

1. **Quay lại Google Sheets**
   - Mở sheet "Incident Report"

2. **Click nút "Share"** (góc trên bên phải)

3. **Paste email Service Account** vào ô

4. **Chọn quyền: "Editor"** (quan trọng!)

5. **Bỏ tick "Notify people"** (không cần)

6. **Click "Share"**

---

## 📋 BƯỚC 4: SETUP ENVIRONMENT VARIABLE

### 4.1. Cách 1: Set trong Cloud Function (Khuyến nghị)

Chạy lệnh này trong PowerShell:

```powershell
# Thay YOUR_SHEET_ID bằng Sheet ID bạn đã lấy ở Bước 1.2
$SHEET_ID = "YOUR_SHEET_ID"

gcloud functions deploy incidentReporting `
  --gen2 `
  --region=asia-southeast1 `
  --update-env-vars="GOOGLE_SHEETS_ID=${SHEET_ID}"
```

### 4.2. Cách 2: Set trong file .env (nếu chạy local)

Mở file `.env` và thêm:

```env
GOOGLE_SHEETS_ID=your-sheet-id-here
```

---

## 📋 BƯỚC 5: ENABLE GOOGLE SHEETS API

### 5.1. Enable API

Chạy lệnh trong PowerShell:

```powershell
gcloud services enable sheets.googleapis.com
```

Hoặc truy cập:
```
https://console.cloud.google.com/apis/library/sheets.googleapis.com
```

Click **"ENABLE"**

---

## 📋 BƯỚC 6: TEST

### 6.1. Test Function

Gọi function reporting:

```powershell
# Lấy URL của function
$REPORTING_URL = gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"

# Test
curl $REPORTING_URL
```

### 6.2. Kiểm tra Sheet

1. **Mở Google Sheet** "Incident Report"
2. **Xem có dữ liệu** được ghi vào không

---

## ✅ CHECKLIST

- [ ] Đã tạo Google Sheet "Incident Report"
- [ ] Đã lấy Sheet ID
- [ ] Đã tạo Service Account
- [ ] Đã download JSON key file
- [ ] Đã share Sheet với Service Account email (quyền Editor)
- [ ] Đã enable Google Sheets API
- [ ] Đã set GOOGLE_SHEETS_ID trong Cloud Function
- [ ] Đã test và thấy dữ liệu trong Sheet

---

## 🐛 TROUBLESHOOTING

### Lỗi: "Permission denied"
→ Kiểm tra đã share Sheet với Service Account chưa
→ Kiểm tra quyền là "Editor" (không phải Viewer)

### Lỗi: "API not enabled"
→ Chạy: `gcloud services enable sheets.googleapis.com`

### Lỗi: "Sheet not found"
→ Kiểm tra Sheet ID đúng chưa
→ Kiểm tra Sheet đã được share với Service Account

### Lỗi: "Authentication failed"
→ Kiểm tra Service Account có quyền truy cập Sheet
→ Kiểm tra Application Default Credentials: `gcloud auth application-default login`

---

## 📝 TÓM TẮT NHANH

1. **Tạo Sheet:** https://sheets.google.com → Tạo mới → Lấy Sheet ID
2. **Tạo Service Account:** https://console.cloud.google.com/iam-admin/serviceaccounts
3. **Share Sheet:** Share với email Service Account (quyền Editor)
4. **Set Environment:** `gcloud functions deploy incidentReporting --update-env-vars="GOOGLE_SHEETS_ID=YOUR_SHEET_ID"`
5. **Test:** Gọi function và kiểm tra Sheet

---

**Sẵn sàng bắt đầu? Bắt đầu từ Bước 1!** 🚀

