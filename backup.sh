#!/bin/bash
echo "📦 ایجاد بکاپ از نطق مصطلح..."
tar -czf "نطق_مصطلح_بکاپ_$(date +%Y%m%d).tar.gz" .
echo "✅ بکاپ ایجاد شد!"
