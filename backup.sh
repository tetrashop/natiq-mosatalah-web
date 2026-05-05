#!/bin/bash
set -euo pipefail 2>/dev/null || true
echo "📦 ایجاد بکاپ از نطق مصطلح..."
tar -czf "نطق_مصطلح_بکاپ_$(date +%Y%m%d).tar.gz" .
echo "✅ بکاپ ایجاد شد!"
