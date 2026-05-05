#!/bin/bash
set -euo pipefail 2>/dev/null || true

echo "🔧 بازسازی کامل دیتابیس..."

# پاک کردن دیتابیس قبلی
rm -f natiq_database/natiq_phrases.json

# استخراج مستقیم عبارات از HTML با awk
python3 << 'PYTHON'
import re
import json

phrases = {}

# خوندن فایل index.html
with open('index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# پیدا کردن همه عبارات و اطلاعاتشون
# الگو: "عبارت": { "mani": "...", "mesal": "...", "ehsas": "..." }
pattern = r'"([^"]+)":\s*\{[^}]*"mani":\s*"([^"]*)"[^}]*"mesal":\s*"([^"]*)"[^}]*"ehsas":\s*"([^"]*)"[^}]*\}'

matches = re.findall(pattern, content)

for match in matches:
    phrase = match[0]
    # فیلتر کردن کلیدهای دسته‌بندی
    if phrase in ['estelahat', 'zarbolmasalha', 'ashare_mardomi', 'kenayeha', 'tabirat']:
        continue
    
    if phrase not in phrases:
        phrases[phrase] = {
            "mani": match[1],
            "mesal": match[2],
            "ehsas": match[3]
        }

# ذخیره در فایل
import os
os.makedirs('natiq_database', exist_ok=True)

with open('natiq_database/natiq_phrases.json', 'w', encoding='utf-8') as f:
    json.dump(phrases, f, ensure_ascii=False, indent=2)

print(f"✅ {len(phrases)} عبارت استخراج و ذخیره شد:")
for i, phrase in enumerate(phrases.keys(), 1):
    print(f"  {i}. {phrase}")

PYTHON

echo ""
echo "📊 وضعیت دیتابیس:"
wc -c natiq_database/natiq_phrases.json
grep -c '": {' natiq_database/natiq_phrases.json
