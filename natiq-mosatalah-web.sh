#!/bin/bash

# اسکریپت توسعه نطق مصطلح - نسخه ساده و بدون خطا
LOG_FILE="natiq_dev.log"
BACKUP_DIR="natiq_backups"

# تابع لاگ ساده
log_msg() {
    echo "[$(date +'%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

echo ""
echo "========================================="
echo "  توسعه نطق مصطلح - نسخه ساده"
echo "========================================="
echo ""

echo "شروع: $(date)" > "$LOG_FILE"

# چک کردن اینکه داخل پوشه پروژه هستیم
if [ ! -f "index.html" ]; then
    echo "خطا: فایل index.html پیدا نشد. لطفاً داخل پوشه پروژه اجرا کنید."
    exit 1
fi

log_msg "پوشه پروژه تایید شد"

# مرحله ۱: پشتیبان‌گیری
log_msg "ایجاد پشتیبان..."
mkdir -p "../$BACKUP_DIR"
BACKUP_NAME="natiq_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "../$BACKUP_DIR/$BACKUP_NAME" . --exclude="node_modules" --exclude=".git" 2>/dev/null
log_msg "پشتیبان ایجاد شد: $BACKUP_NAME"

# مرحله ۲: استخراج کدهای تمیز
log_msg "استخراج کدهای تمیز..."
OUTPUT_FILE="../natiq_clean_code_$(date +%Y%m%d).txt"

echo "کدهای پروژه نطق مصطلح - $(date)" > "$OUTPUT_FILE"
echo "=========================================" >> "$OUTPUT_FILE"

# لیست فایل‌ها برای استخراج
for file in \
    "index.html" \
    "js/payment.js" \
    "backend/server.js" \
    "backend/package.json" \
    "server.py" \
    "config.json" \
    "functions/api.js" \
    "frontend/src/App.vue" \
    "frontend/src/main.js" \
    "frontend/index.html" \
    "frontend/package.json" \
    "frontend/vite.config.js" \
    "نطق_مصطلح_کامل.html" \
    "راهنمای_نصب.md" \
    "DEPLOY.md"
do
    if [ -f "$file" ]; then
        echo "" >> "$OUTPUT_FILE"
        echo "========================================" >> "$OUTPUT_FILE"
        echo "فایل: $file" >> "$OUTPUT_FILE"
        echo "========================================" >> "$OUTPUT_FILE"
        cat "$file" >> "$OUTPUT_FILE"
        log_msg "استخراج: $file"
    fi
done

log_msg "کدهای تمیز در $OUTPUT_FILE ذخیره شد"

# مرحله ۳: ایجاد فایل‌های جدید با echo
log_msg "ایجاد فایل‌های جدید..."

# manifest.json
echo '{
  "name": "نطق مصطلح",
  "short_name": "نطق مصطلح",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#667eea",
  "theme_color": "#667eea",
  "lang": "fa",
  "dir": "rtl"
}' > manifest.json
log_msg "manifest.json ایجاد شد"

# sw.js
echo 'const CACHE_NAME = "natiq-v1";
const ASSETS = ["/", "/index.html", "/js/payment.js"];

self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(ASSETS))
  );
});

self.addEventListener("fetch", event => {
  event.respondWith(
    caches.match(event.request).then(cached => cached || fetch(event.request))
  );
});' > sw.js
log_msg "sw.js ایجاد شد"

# اضافه کردن PWA به index.html
if [ -f "index.html" ]; then
    if ! grep -q "manifest.json" index.html; then
        sed -i 's|<head>|<head>\n    <link rel="manifest" href="/manifest.json">\n    <meta name="theme-color" content="#667eea">|' index.html
        log_msg "PWA به index.html اضافه شد"
    fi
    
    if ! grep -q "serviceWorker" index.html; then
        sed -i 's|</body>|<script>if("serviceWorker" in navigator){navigator.serviceWorker.register("/sw.js")}</script>\n</body>|' index.html
        log_msg "Service Worker به index.html اضافه شد"
    fi
fi

# مرحله ۴: تحلیل پروژه
log_msg "ایجاد تحلیل پروژه..."
ANALYSIS_FILE="../natiq_analysis_$(date +%Y%m%d).md"

echo "# تحلیل پروژه نطق مصطلح" > "$ANALYSIS_FILE"
echo "" >> "$ANALYSIS_FILE"
echo "## آمار فایل‌ها" >> "$ANALYSIS_FILE"
echo "- فایل‌های HTML: $(find . -name "*.html" ! -path "*/node_modules/*" | wc -l)" >> "$ANALYSIS_FILE"
echo "- فایل‌های JavaScript: $(find . -name "*.js" ! -path "*/node_modules/*" | wc -l)" >> "$ANALYSIS_FILE"
echo "- فایل‌های Python: $(find . -name "*.py" ! -path "*/node_modules/*" | wc -l)" >> "$ANALYSIS_FILE"
echo "- فایل‌های Vue: $(find . -name "*.vue" ! -path "*/node_modules/*" | wc -l)" >> "$ANALYSIS_FILE"
echo "" >> "$ANALYSIS_FILE"
echo "## ویژگی‌های فعلی" >> "$ANALYSIS_FILE"
echo "- جستجوی اصطلاحات فارسی" >> "$ANALYSIS_FILE"
echo "- سیستم پرداخت و اعتبار" >> "$ANALYSIS_FILE"
echo "- پشتیبانی از PWA (اضافه شده)" >> "$ANALYSIS_FILE"
echo "- رابط کاربری واکنش‌گرا" >> "$ANALYSIS_FILE"

log_msg "تحلیل در $ANALYSIS_FILE ذخیره شد"

# پایان
echo ""
echo "========================================="
echo "  عملیات با موفقیت انجام شد!"
echo "========================================="
echo ""
echo "فایل‌های تولید شده:"
echo "  1. کد تمیز: ../natiq_clean_code_*.txt"
echo "  2. تحلیل: ../natiq_analysis_*.md"
echo "  3. لاگ: $LOG_FILE"
echo "  4. پشتیبان: ../$BACKUP_DIR/$BACKUP_NAME"
echo ""
echo "فایل‌های جدید در پروژه:"
echo "  - manifest.json (PWA)"
echo "  - sw.js (Service Worker)"
echo ""
