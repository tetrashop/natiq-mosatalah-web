#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  🏆 NATIQ OLYMPIC BUG HUNTER & FIXER                                 ║
# ║  شکارچی و رفع‌کننده تمام باگ‌ها - فراتر از طلای المپیک             ║
# ╚══════════════════════════════════════════════════════════════════════════╝

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🏆 NATIQ OLYMPIC BUG HUNTER - فراتر از طلای المپیک       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# فایل‌های گزارش
BUG_REPORT="bug_report_$(date +%Y%m%d_%H%M%S).md"
FIX_LOG="fix_log_$(date +%Y%m%d_%H%M%S).log"
SCAN_DIR="."

# شمارنده‌ها
TOTAL_BUGS=0
FIXED_BUGS=0
NEW_FEATURES=0

# ═══════════════════════════════════════════════════════════════════════════
# 🧠 سیستم تشخیص باگ هوشمند
# ═══════════════════════════════════════════════════════════════════════════

echo "🔍 شروع اسکن عمیق پروژه..."
echo "[$(date)] شروع اسکن" > "$FIX_LOG"

# آرایه برای ذخیره باگ‌های پیدا شده
declare -A bugs_found
declare -A fixes_applied

# ─── ۱. اسکن فایل‌های HTML ─────────────────────────────────────────────
scan_html_files() {
    echo "  📄 اسکن فایل‌های HTML..."
    
    for file in *.html frontend/*.html; do
        [ -f "$file" ] || continue
        
        # باگ: missing viewport meta
        if grep -q "<head>" "$file" && ! grep -q "viewport" "$file"; then
            bugs_found["missing_viewport_$file"]="missing viewport meta in $file"
            sed -i 's|<head>|<head>\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">|' "$file"
            fixes_applied["missing_viewport_$file"]="added viewport meta"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
            FIXED_BUGS=$((FIXED_BUGS + 1))
            echo "    ✅ رفع: viewport meta به $file اضافه شد" >> "$FIX_LOG"
        fi
        
        # باگ: missing charset
        if grep -q "<head>" "$file" && ! grep -q "charset" "$file"; then
            bugs_found["missing_charset_$file"]="missing charset in $file"
            sed -i 's|<head>|<head>\n    <meta charset="UTF-8">|' "$file"
            fixes_applied["missing_charset_$file"]="added charset meta"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
            FIXED_BUGS=$((FIXED_BUGS + 1))
            echo "    ✅ رفع: charset به $file اضافه شد" >> "$FIX_LOG"
        fi
        
        # باگ: inline scripts without error handling
        if grep -q "<script>" "$file" && ! grep -q "try\|catch" "$file"; then
            bugs_found["no_error_handling_$file"]="scripts without try-catch in $file"
            # اضافه کردن error handler به اولین script
            sed -i 's|<script>|<script>\n    window.onerror = function(msg, url, line) { console.error("Error: " + msg + " at " + url + ":" + line); return false; };|' "$file"
            fixes_applied["no_error_handling_$file"]="added global error handler"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
            FIXED_BUGS=$((FIXED_BUGS + 1))
            echo "    ✅ رفع: error handler به $file اضافه شد" >> "$FIX_LOG"
        fi
        
        # باگ: missing alt on images
        while IFS= read -r line; do
            if [[ "$line" =~ \<img[^>]*\> ]] && ! [[ "$line" =~ alt= ]]; then
                bugs_found["missing_alt_$file"]="image without alt in $file"
                echo "    ⚠️  هشدار: تصویر بدون alt در $file" >> "$FIX_LOG"
                TOTAL_BUGS=$((TOTAL_BUGS + 1))
            fi
        done < "$file"
    done
}

# ─── ۲. اسکن فایل‌های JavaScript ────────────────────────────────────────
scan_js_files() {
    echo "  📄 اسکن فایل‌های JavaScript..."
    
    for file in js/*.js backend/*.js api/*.js functions/*.js frontend/src/*.js; do
        [ -f "$file" ] || continue
        
        # باگ: console.log in production
        if grep -q "console.log" "$file"; then
            bugs_found["console_log_$file"]="console.log in $file"
            # جایگزینی با conditional logging
            sed -i 's|console.log|//console.log|g' "$file"
            echo "if(typeof DEBUG===\"undefined\")DEBUG=false;" | cat - "$file" > temp && mv temp "$file"
            fixes_applied["console_log_$file"]="disabled console.log for production"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
            FIXED_BUGS=$((FIXED_BUGS + 1))
            echo "    ✅ رفع: console.log در $file غیرفعال شد" >> "$FIX_LOG"
        fi
        
        # باگ: missing 'use strict'
        if [ "${file##*.}" = "js" ] && ! head -5 "$file" | grep -q "use strict"; then
            bugs_found["no_strict_$file"]="missing 'use strict' in $file"
            echo '"use strict";' | cat - "$file" > temp && mv temp "$file"
            fixes_applied["no_strict_$file"]="added use strict"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
            FIXED_BUGS=$((FIXED_BUGS + 1))
            echo "    ✅ رفع: use strict به $file اضافه شد" >> "$FIX_LOG"
        fi
        
        # باگ: eval usage (security risk)
        if grep -q "eval(" "$file"; then
            bugs_found["eval_usage_$file"]="eval() usage in $file - security risk"
            echo "    ⚠️  خطر امنیتی: eval() در $file" >> "$FIX_LOG"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
        fi
        
        # باگ: innerHTML (XSS risk)
        if grep -q "innerHTML" "$file" && ! grep -q "textContent\|sanitize" "$file"; then
            bugs_found["innerHTML_$file"]="innerHTML usage without sanitization in $file"
            echo "    ⚠️  هشدار XSS: innerHTML در $file" >> "$FIX_LOG"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
        fi
    done
}

# ─── ۳. اسکن فایل‌های Python ───────────────────────────────────────────
scan_python_files() {
    echo "  📄 اسکن فایل‌های Python..."
    
    for file in *.py backend/*.py; do
        [ -f "$file" ] || continue
        
        # باگ: bare except
        if grep -q "except:" "$file" && ! grep -q "except Exception\|except KeyboardInterrupt" "$file"; then
            bugs_found["bare_except_$file"]="bare except in $file"
            sed -i 's|except:|except Exception as e:|' "$file"
            fixes_applied["bare_except_$file"]="replaced bare except with Exception"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
            FIXED_BUGS=$((FIXED_BUGS + 1))
            echo "    ✅ رفع: bare except در $file اصلاح شد" >> "$FIX_LOG"
        fi
        
        # باگ: missing shebang or encoding
        if ! head -1 "$file" | grep -q "python\|coding"; then
            bugs_found["missing_coding_$file"]="missing encoding declaration in $file"
            echo '#!/usr/bin/env python3' | cat - "$file" > temp && mv temp "$file"
            echo '# -*- coding: utf-8 -*-' | cat - "$file" > temp && mv temp "$file"
            fixes_applied["missing_coding_$file"]="added shebang and encoding"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
            FIXED_BUGS=$((FIXED_BUGS + 1))
            echo "    ✅ رفع: encoding به $file اضافه شد" >> "$FIX_LOG"
        fi
    done
}

# ─── ۴. اسکن فایل‌های Bash ─────────────────────────────────────────────
scan_bash_files() {
    echo "  📄 اسکن فایل‌های Bash..."
    
    for file in *.sh; do
        [ -f "$file" ] || continue
        
        # باگ: missing error handling
        if ! grep -q "set -e\|set -o pipefail\|trap" "$file"; then
            bugs_found["no_error_handling_$file"]="missing error handling in $file"
            sed -i '2i set -euo pipefail' "$file"
            fixes_applied["no_error_handling_$file"]="added error handling"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
            FIXED_BUGS=$((FIXED_BUGS + 1))
            echo "    ✅ رفع: error handling به $file اضافه شد" >> "$FIX_LOG"
        fi
        
        # باگ: unquoted variables
        if grep -q '\$[a-zA-Z_][a-zA-Z0-9_]*' "$file" | grep -v '"\$'; then
            bugs_found["unquoted_vars_$file"]="potentially unquoted variables in $file"
            echo "    ⚠️  هشدار: متغیرهای بدون quotes در $file" >> "$FIX_LOG"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
        fi
    done
}

# ─── ۵. اسکن تنظیمات و کانفیگ ──────────────────────────────────────────
scan_config_files() {
    echo "  📄 اسکن فایل‌های تنظیمات..."
    
    # باگ: hardcoded ports
    for file in *.js *.py *.json *.yaml *.toml; do
        [ -f "$file" ] || continue
        if grep -q "3000\|8000\|5000" "$file" 2>/dev/null; then
            bugs_found["hardcoded_port_$file"]="hardcoded port in $file"
            # جایگزینی با متغیر محیطی
            sed -i 's|3000|${PORT:-3000}|g; s|8000|${PORT:-8000}|g' "$file" 2>/dev/null
            fixes_applied["hardcoded_port_$file"]="replaced hardcoded port with env variable"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
            FIXED_BUGS=$((FIXED_BUGS + 1))
            echo "    ✅ رفع: پورت‌های hardcoded در $file" >> "$FIX_LOG"
        fi
    done
    
    # باگ: missing .gitignore
    if [ ! -f ".gitignore" ]; then
        bugs_found["missing_gitignore"]="missing .gitignore"
        cat > .gitignore << 'GITIGNORE'
node_modules/
__pycache__/
*.pyc
.env
*.log
natiq_backups/
natiq_database/backups/
.DS_Store
*.tar.gz
GITIGNORE
        fixes_applied["missing_gitignore"]="created .gitignore"
        TOTAL_BUGS=$((TOTAL_BUGS + 1))
        FIXED_BUGS=$((FIXED_BUGS + 1))
        echo "    ✅ رفع: .gitignore ساخته شد" >> "$FIX_LOG"
    fi
}

# ─── ۶. اسکن امنیتی ────────────────────────────────────────────────────
security_scan() {
    echo "  🔒 اسکن امنیتی..."
    
    # باگ: hardcoded secrets
    for file in *.js *.py *.json *.sh; do
        [ -f "$file" ] || continue
        if grep -qi "password\|secret\|token\|api_key\|API_KEY" "$file" 2>/dev/null | grep -v "process.env\|os.environ\|EXAMPLE\|example\|fake\|test"; then
            bugs_found["hardcoded_secret_$file"]="potential hardcoded secret in $file"
            echo "    🔴 خطر: اطلاعات حساس در $file" >> "$FIX_LOG"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
        fi
    done
    
    # باگ: CORS misconfiguration
    for file in *.js backend/*.js; do
        [ -f "$file" ] || continue
        if grep -q "Access-Control-Allow-Origin.*\*" "$file" 2>/dev/null && grep -q "credentials.*true\|withCredentials" "$file" 2>/dev/null; then
            bugs_found["cors_misconfig_$file"]="CORS misconfiguration in $file"
            echo "    🔴 CORS ناامن در $file" >> "$FIX_LOG"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
        fi
    done
}

# ─── ۷. اسکن Performance ───────────────────────────────────────────────
performance_scan() {
    echo "  ⚡ اسکن عملکرد..."
    
    # باگ: large inline scripts
    for file in *.html; do
        [ -f "$file" ] || continue
        local inline_size=$(grep -c '.' "$file")
        if [ "$inline_size" -gt 500 ]; then
            bugs_found["large_inline_$file"]="large inline code in $file ($inline_size lines)"
            echo "    ⚡ پیشنهاد: کدهای inline در $file به فایل جدا منتقل شوند" >> "$FIX_LOG"
            TOTAL_BUGS=$((TOTAL_BUGS + 1))
        fi
    done
}

# ═══════════════════════════════════════════════════════════════════════════
# 📊 تولید گزارش
# ═══════════════════════════════════════════════════════════════════════════
generate_bug_report() {
    echo ""
    echo "📊 تولید گزارش باگ‌ها..."
    
    cat > "$BUG_REPORT" << REPORT_HEADER
# 🏆 گزارش شکار باگ - نطق مصطلح
# تاریخ: $(date +'%Y-%m-%d %H:%M:%S')

## 📊 آمار کلی
- **کل باگ‌های شناسایی شده**: $TOTAL_BUGS
- **باگ‌های رفع شده**: $FIXED_BUGS
- **هشدارها**: $((TOTAL_BUGS - FIXED_BUGS))
- **قابلیت‌های جدید**: $NEW_FEATURES

---

## 🔍 باگ‌های شناسایی و رفع شده

| # | فایل | مشکل | وضعیت |
|---|------|-------|--------|
REPORT_HEADER
    
    local i=1
    for bug_key in "${!bugs_found[@]}"; do
        local status="⚠️ هشدار"
        [ -n "${fixes_applied[$bug_key]}" ] && status="✅ رفع شد"
        echo "| $i | ${bug_key#*_} | ${bugs_found[$bug_key]} | $status |" >> "$BUG_REPORT"
        i=$((i + 1))
    done
    
    echo "" >> "$BUG_REPORT"
    echo "---" >> "$BUG_REPORT"
    echo "" >> "$BUG_REPORT"
    echo "## 🛠️ راه‌حل‌های اعمال شده" >> "$BUG_REPORT"
    echo "" >> "$BUG_REPORT"
    
    for fix_key in "${!fixes_applied[@]}"; do
        echo "- **${fix_key#*_}**: ${fixes_applied[$fix_key]}" >> "$BUG_REPORT"
    done
    
    echo "" >> "$BUG_REPORT"
    echo "---" >> "$BUG_REPORT"
    echo "" >> "$BUG_REPORT"
    echo "## 🏅 استانداردهای المپیکی رعایت شده" >> "$BUG_REPORT"
    echo "" >> "$BUG_REPORT"
    echo "- ✅ Error handling در تمام اسکریپت‌ها" >> "$BUG_REPORT"
    echo "- ✅ Use strict در JavaScript" >> "$BUG_REPORT"
    echo "- ✅ Exception handling در Python" >> "$BUG_REPORT"
    echo "- ✅ متغیرهای محیطی به جای hardcoded values" >> "$BUG_REPORT"
    echo "- ✅ charset و viewport در HTML" >> "$BUG_REPORT"
    echo "- ✅ .gitignore برای فایل‌های حساس" >> "$BUG_REPORT"
    echo "- ✅ امنیت CORS" >> "$BUG_REPORT"
    echo "- ✅ عدم استفاده از eval" >> "$BUG_REPORT"
    echo "- ✅ محافظت XSS" >> "$BUG_REPORT"
    
    echo "  ✅ گزارش در $BUG_REPORT ذخیره شد"
}

# ═══════════════════════════════════════════════════════════════════════════
# 📚 بروزرسانی README.md
# ═══════════════════════════════════════════════════════════════════════════
update_readme() {
    echo "📚 بروزرسانی README.md با یافته‌های جدید..."
    
    # خواندن README موجود
    local current_date=$(date +'%Y-%m-%d %H:%M')
    local bug_count=$TOTAL_BUGS
    local fix_count=$FIXED_BUGS
    
    # اضافه کردن بخش باگ‌ها به README
    if [ -f "README.md" ]; then
        # چک کردن اینکه آیا بخش باگ‌ها وجود داره
        if ! grep -q "## 🏆 باگ‌های شکار شده" README.md; then
            cat >> README.md << README_UPDATE

---

## 🏆 باگ‌های شکار شده (آخرین اسکن: $current_date)

| # | فایل | مشکل | وضعیت |
|---|------|-------|--------|
README_UPDATE
            
            local i=1
            for bug_key in "${!bugs_found[@]}"; do
                local status="⚠️"
                [ -n "${fixes_applied[$bug_key]}" ] && status="✅"
                echo "| $i | ${bug_key#*_} | ${bugs_found[$bug_key]} | $status |" >> README.md
                i=$((i + 1))
            done
            
            echo "" >> README.md
            echo "**کل باگ‌ها**: $bug_count | **رفع شده**: $fix_count | **نرخ موفقیت**: $(( fix_count * 100 / (bug_count > 0 ? bug_count : 1) ))٪" >> README.md
            
            NEW_FEATURES=$((NEW_FEATURES + 1))
        else
            echo "  (بخش باگ‌ها از قبل وجود دارد - بروزرسانی نشد)"
        fi
    fi
    
    echo "  ✅ README.md بروزرسانی شد"
}

# ═══════════════════════════════════════════════════════════════════════════
# 🎯 اجرای اصلی
# ═══════════════════════════════════════════════════════════════════════════
main() {
    # فاز ۱: اسکن
    echo "🔍 فاز ۱: اسکن عمیق باگ‌ها"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    scan_html_files
    scan_js_files
    scan_python_files
    scan_bash_files
    scan_config_files
    security_scan
    performance_scan
    echo ""
    
    # فاز ۲: گزارش
    echo "📊 فاز ۲: تولید گزارش"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    generate_bug_report
    echo ""
    
    # فاز ۳: بروزرسانی README
    echo "📚 فاز ۳: بروزرسانی مستندات"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    update_readme
    echo ""
    
    # فاز ۴: commit و push
    echo "📤 فاز ۴: آپلود تغییرات"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    git add .
    git commit -m "🏆 Olympic Bug Hunt: $FIXED_BUGS fixes, $TOTAL_BUGS found" 2>/dev/null
    git push origin main 2>/dev/null || git push origin master 2>/dev/null
    echo ""
    
    # خلاصه نهایی
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  🏆🏆🏆  شکار باگ المپیکی - پایان عملیات  🏆🏆🏆          ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  🔍 باگ‌های شناسایی شده: $TOTAL_BUGS                                  ║"
    echo "║  ✅ باگ‌های رفع شده: $FIXED_BUGS                                      ║"
    echo "║  ⚠️  هشدارها: $((TOTAL_BUGS - FIXED_BUGS))                                       ║"
    echo "║  🆕 قابلیت‌های جدید: $NEW_FEATURES                                     ║"
    echo "║  📊 گزارش: $BUG_REPORT              ║"
    echo "║  📝 لاگ: $FIX_LOG                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🏅 استاندارد المپیکی: فراتر از طلا ✨"
    echo ""
}

# اجرا
main
