#!/bin/bash

DB_FILE="natiq_database/natiq_phrases.json"

# پاکسازی با Python
python3 << 'PYTHON'
import json
import re

with open('natiq_database/natiq_phrases.json', 'r', encoding='utf-8') as f:
    content = f.read()

# درست کردن JSON ناقص
# حذف کاماهای اضافی و بستن آکولاد
content = content.strip()
if not content.endswith('}'):
    content += '\n}'

# تلاش برای پارس کردن
try:
    data = json.loads(content)
except:
    # اگر نشد، دستی درستش می‌کنیم
    lines = content.split('\n')
    clean_lines = []
    for line in lines:
        line = line.strip()
        if line.startswith('"') and '": {' in line:
            clean_lines.append(line)
        elif line.startswith('{') or line.startswith('}'):
            clean_lines.append(line)
    
    content = '\n'.join(clean_lines)
    data = json.loads(content)

# حذف کلیدهای دسته‌بندی
categories = ['estelahat', 'zarbolmasalha', 'ashare_mardomi', 'kenayeha', 'tabirat']
clean_data = {}
for key, value in data.items():
    if key not in categories and value.get('mani') and value['mani'] != '':
        if key not in clean_data:  # حذف تکراری‌ها
            clean_data[key] = value

# ذخیره
with open('natiq_database/natiq_phrases.json', 'w', encoding='utf-8') as f:
    json.dump(clean_data, f, ensure_ascii=False, indent=2)

print(f"✅ پاکسازی شد: {len(clean_data)} عبارت منحصر به فرد")
for phrase in clean_data:
    print(f"  📝 {phrase}")
PYTHON
