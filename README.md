# 🗣️ نطق مصطلح - سامانه هوشمند پایگاه داده عبارات فارسی

![Version](https://img.shields.io/badge/version-3.0.0-blue)
![Status](https://img.shields.io/badge/status-active-success)
![Platform](https://img.shields.io/badge/platform-Vercel-black)
![AI](https://img.shields.io/badge/AI%20Core-active-purple)

**پایگاه داده جامع اصطلاحات، ضرب‌المثل‌ها و اشعار مردمی فارسی با هسته هوش مصنوعی خودیادگیر**

---

## چکیده

پروژه «نطق مصطلح» یک سامانه تحت وب برای گردآوری و مدیریت هوشمند عبارات فارسی است با معماری چندلایه (Frontend + Backend + AI Core) و هسته AI خودیادگیر.

**کلمات کلیدی**: فارسی، پایگاه داده، هوش مصنوعی، PWA، Vercel، خودیادگیر

---

## تاریخچه توسعه و چالش‌ها

### فاز ۱: راه‌اندازی اولیه
- **چالش**: خطای `df -BG` در Termux
- **راه‌حل**: جایگزینی با `df -m`

### فاز ۲: استخراج کدها
- **چالش**: خطای `division by zero`
- **راه‌حل**: مقادیر پیش‌فرض برای متغیرها

### فاز ۳: PWA و Service Worker
- **چالش**: `syntax error: unexpected end of file`
- **راه‌حل**: استفاده از echo به جای here-document

### فاز ۴: پایگاه داده هوشمند
- **چالش**: JSON ناقص و عبارات تکراری
- **راه‌حل**: بازنویسی با Python و regex دقیق

### فاز ۵: هسته AI خودیادگیر
- **چالش**: استخراج ناقص عبارات
- **راه‌حل**: الگوی regex بهبود یافته

### فاز ۶: استقرار روی Vercel
- **چالش**: عدم تطابق شاخه git
- **راه‌حل**: تنظیم خودکار git init و remote

---

## معماری سیستم

```

Vercel Edge
├── PWA Frontend (HTML5, Vue.js, Service Worker)
├── AI Core (Serverless - api/ai_core.js)
└── Database (JSON + IndexedDB + Cache)

```

---

## ساختار پروژه

```

natiq-mosatalah-web/
├── index.html              # صفحه اصلی
├── js/payment.js           # سیستم پرداخت
├── api/ai_core.js          # هسته AI روی Vercel
├── backend/server.js       # بک‌اند Node.js
├── server.py               # بک‌اند Python
├── natiq_database/         # پایگاه داده
├── deploy.sh               # استقرار خودکار
├── natiq_db_manager.sh     # مدیریت دیتابیس
└── natiq_ai_core.sh        # هسته AI محلی

```

---

## نصب و اجرا

```bash
git clone https://github.com/tetrashop/natiq-mosatalah-web.git
cd natiq-mosatalah-web
./natiq_db_manager.sh
./natiq_ai_core.sh start
```

استقرار روی Vercel

```bash
./deploy.sh "پیام کامیت"
```

API

مسیر توضیح
/api/ai-core وضعیت هسته AI
/api/register ثبت‌نام
/api/check-credit بررسی اعتبار

---

آمار

· عبارات: ۱۴+
· فایل‌ها: ۱۸+
· اسکریپت‌ها: ۷
· زمان استقرار: <۶۰ ثانیه

---

نقشه راه

· احراز هویت JWT
· درگاه پرداخت واقعی
· API عمومی
· اپلیکیشن موبایل

---

ساخته شده با ❤️ توسط تتراشاپ | ما شاء الله

*آخرین بروزرسانی: '"$(date +'%Y-%m-%d %H:%M')"'
