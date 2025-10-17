const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes پایه
app.get('/', (req, res) => {
  res.json({ 
    message: 'نطق مصطلح API - سیستم پرداخت بر اساس استفاده',
    status: 'فعال'
  });
});

// سیستم کاربران
app.post('/api/register', (req, res) => {
  // ثبت‌نام کاربر جدید
  res.json({ message: 'ثبت‌نام موفق', userId: '123' });
});

// سیستم اعتبار سنجی
app.post('/api/check-credit', (req, res) => {
  // بررسی اعتبار کاربر
  res.json({ credit: 1000, canUse: true });
});

app.listen(PORT, () => {
  console.log(`🚀 سرور اجرا شد: http://localhost:${PORT}`);
});
