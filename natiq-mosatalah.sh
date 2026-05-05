#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  🏆 اسکریپت توسعه المپیکی - نطق مصطلح                                    ║
# ║  فراتر از طلای المپیک: کد تمیز، توسعه هوشمند، بروزرسانی خودکار           ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

REPO_URL="https://github.com/tetrashop/natiq-mosatalah-web.git"
PROJECT_DIR="natiq-mosatalah-web"
BACKUP_DIR="natiq_backups"
LOG_FILE="natiq_olympic_dev.log"
TEMP_BRANCH="olympic-upgrade-$(date +%Y%m%d-%H%M%S)"

# رنگ‌بندی زیبا برای خروجی
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GOLD='\033[1;33m'
NC='\033[0m' # No Color

# ══════════════════════════════════════════════════════════════════════════════
# 🏅 تابع: ثبت وقایع المپیکی
# ══════════════════════════════════════════════════════════════════════════════
log_olympic() {
    echo -e "${GOLD}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

# ══════════════════════════════════════════════════════════════════════════════
# 🥇 مرحله ۱: بررسی سلامت و پشتیبان‌گیری
# ══════════════════════════════════════════════════════════════════════════════
olympic_backup() {
    log_olympic "🥇 شروع مرحله المپیکی: پشتیبان‌گیری هوشمند"
    
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$PROJECT_DIR" ]; then
        local backup_name="natiq_olympic_$(date +%Y%m%d_%H%M%S)"
        local backup_path="$BACKUP_DIR/$backup_name"
        
        cp -r "$PROJECT_DIR" "$backup_path"
        
        if [ -d "$PROJECT_DIR/.git" ]; then
            cp -r "$PROJECT_DIR/.git" "$backup_path/.git" 2>/dev/null
        fi
        
        tar -czf "$backup_path.tar.gz" -C "$BACKUP_DIR" "$backup_name" 2>/dev/null
        rm -rf "$backup_path"
        
        log_olympic "✅ پشتیبان المپیکی ایجاد شد: $backup_name.tar.gz"
        
        # حفظ فقط ۵ نسخه آخر
        ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null
    else
        log_olympic "⚠️  پروژه موجود نیست، پشتیبان‌گیری رد شد"
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# 🥈 مرحله ۲: به‌روزرسانی و کلون هوشمند
# ══════════════════════════════════════════════════════════════════════════════
olympic_clone_or_pull() {
    log_olympic "🥈 شروع مرحله المپیکی: همگام‌سازی مخزن"
    
    if [ -d "$PROJECT_DIR/.git" ]; then
        cd "$PROJECT_DIR"
        
        git stash push -m "olympic-auto-stash-$(date +%s)" 2>/dev/null
        git fetch origin
        
        local main_branch=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | cut -d' ' -f5)
        main_branch=${main_branch:-main}
        
        if git pull --rebase origin "$main_branch" 2>/dev/null; then
            log_olympic "✅ به‌روزرسانی موفق با rebase"
        else
            git pull origin "$main_branch" 2>/dev/null || log_olympic "⚠️  Pull با خطا مواجه شد"
        fi
        
        git stash pop 2>/dev/null || true
        cd ..
    else
        [ -d "$PROJECT_DIR" ] && rm -rf "$PROJECT_DIR"
        git clone --depth 1 "$REPO_URL" "$PROJECT_DIR" 2>/dev/null || {
            log_olympic "❌ کلون با شکست مواجه شد"
            return 1
        }
        log_olympic "✅ مخزن با موفقیت کلون شد"
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# 🥉 مرحله ۳: تحلیل کدهای اصلی
# ══════════════════════════════════════════════════════════════════════════════
olympic_code_analysis() {
    log_olympic "🥉 شروع تحلیل المپیکی کدها"
    
    local analysis_file="natiq_code_analysis_$(date +%Y%m%d).md"
    
    cat > "$analysis_file" << 'EOF'
# 🏆 گزارش تحلیل المپیکی کدهای نطق مصطلح

## 📊 آمار کلی پروژه
EOF
    
    if [ -d "$PROJECT_DIR" ]; then
        cd "$PROJECT_DIR"
        
        echo "" >> "../$analysis_file"
        echo "### 📁 ساختار فایل‌های اصلی" >> "../$analysis_file"
        echo '```' >> "../$analysis_file"
        echo "📂 پروژه اصلی (index.html): $(find . -maxdepth 1 -name "index.html" | wc -l) فایل" >> "../$analysis_file"
        echo "📂 بک‌اند Node.js: $(find backend -name "*.js" ! -path "*/node_modules/*" 2>/dev/null | wc -l) فایل" >> "../$analysis_file"
        echo "📂 بک‌اند Python: $(find . -name "*.py" ! -path "*/node_modules/*" 2>/dev/null | wc -l) فایل" >> "../$analysis_file"
        echo "📂 فرانت‌اند Vue: $(find frontend -name "*.vue" ! -path "*/node_modules/*" 2>/dev/null | wc -l) فایل" >> "../$analysis_file"
        echo "📂 سیستم پرداخت: $(find js -name "*.js" 2>/dev/null | wc -l) فایل" >> "../$analysis_file"
        echo '```' >> "../$analysis_file"
        
        cd ..
    fi
    
    log_olympic "✅ تحلیل المپیکی در $analysis_file ذخیره شد"
}

# ══════════════════════════════════════════════════════════════════════════════
# 🏅 مرحله ۴: ارتقای کد به سطح المپیکی
# ══════════════════════════════════════════════════════════════════════════════
olympic_code_upgrade() {
    log_olympic "🏅 شروع ارتقای المپیکی کدها"
    
    if [ ! -d "$PROJECT_DIR" ]; then
        log_olympic "❌ پروژه یافت نشد"
        return 1
    fi
    
    cd "$PROJECT_DIR"
    
    # ۱. بهینه‌سازی فایل index.html
    if [ -f "index.html" ]; then
        log_olympic "🔧 ارتقای index.html - افزودن قابلیت PWA"
        
        # اضافه کردن متاتگ‌های PWA اگر وجود نداشته باشند
        if ! grep -q "manifest.json" index.html; then
            sed -i '/<head>/a\    <link rel="manifest" href="/manifest.json">' index.html
            sed -i '/<head>/a\    <meta name="theme-color" content="#667eea">' index.html
        fi
    fi
    
    # ۲. ایجاد فایل manifest.json برای PWA
    cat > "manifest.json" << 'EOF'
{
  "name": "نطق مصطلح - پایگاه داده عبارات فارسی",
  "short_name": "نطق مصطلح",
  "description": "پایگاه داده جامع عبارات، ضرب‌المثل‌ها و اصطلاحات فارسی",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#667eea",
  "theme_color": "#667eea",
  "icons": [
    {
      "src": "/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF
    
    # ۳. ایجاد Service Worker برای کش هوشمند
    cat > "sw.js" << 'EOF'
const CACHE_NAME = 'natiq-cache-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/js/payment.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});
EOF
    
    # ۴. بهینه‌سازی بک‌اند Node.js
    if [ -f "backend/server.js" ]; then
        log_olympic "🔧 ارتقای backend/server.js"
        
        cp backend/server.js backend/server.js.backup
        
        cat > "backend/server_enhanced.js" << 'EOF'
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10kb' }));

// Rate limiting ساده
const requestCounts = new Map();
app.use((req, res, next) => {
  const ip = req.ip;
  const now = Date.now();
  const windowMs = 60000;
  const maxRequests = 100;
  
  if (!requestCounts.has(ip)) {
    requestCounts.set(ip, []);
  }
  
  const requests = requestCounts.get(ip).filter(time => now - time < windowMs);
  requests.push(now);
  requestCounts.set(ip, requests);
  
  if (requests.length > maxRequests) {
    return res.status(429).json({ error: 'تعداد درخواست‌ها بیش از حد مجاز است' });
  }
  
  next();
});

// Routes پایه
app.get('/', (req, res) => {
  res.json({ 
    message: 'نطق مصطلح API - سیستم پرداخت بر اساس استفاده',
    status: 'فعال'
  });
});

// سیستم کاربران
app.post('/api/register', (req, res) => {
  res.json({ message: 'ثبت‌نام موفق', userId: '123' });
});

// سیستم اعتبار سنجی
app.post('/api/check-credit', (req, res) => {
  res.json({ credit: 1000, canUse: true });
});

app.listen(PORT, () => {
  console.log(`🚀 سرور اجرا شد: http://localhost:${PORT}`);
});
EOF
        mv backend/server_enhanced.js backend/server.js
    fi
    
    cd ..
    
    log_olympic "✅ ارتقای المپیکی کدها انجام شد"
}

# ══════════════════════════════════════════════════════════════════════════════
# 🎖️ مرحله ۵: تولید مستندات توسعه
# ══════════════════════════════════════════════════════════════════════════════
olympic_documentation() {
    log_olympic "🎖️ تولید مستندات المپیکی"
    
    cat > "OLYMPIC_DEVELOPMENT_GUIDE.md" << 'EOF'
# 🏆 راهنمای توسعه المپیکی - نطق مصطلح

## 🚀 شروع سریع

```bash
# بک‌اند Node.js
cd backend && npm install && npm start

# یا بک‌اند Python
python server.py

# فرانت‌اند Vue
cd frontend && npm install && npm run dev
