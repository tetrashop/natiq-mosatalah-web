#!/bin/bash
set -euo pipefail 2>/dev/null || true

# ╔══════════════════════════════════════════════════════════════════╗
# ║  🗄️ سامانه هوشمند پایگاه داده - نطق مصطلح                     ║
# ║  نسخه سازگار با تمام سیستم‌ها                                  ║
# ╚══════════════════════════════════════════════════════════════════╝

# رنگ‌ها
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GOLD='\033[1;33m'
NC='\033[0m'

# فایل‌های پایگاه داده
DB_DIR="natiq_database"
DB_FILE="$DB_DIR/natiq_phrases.json"
DB_INDEX="$DB_DIR/natiq_index.json"
DB_BACKUP_DIR="$DB_DIR/backups"
DB_LOG="$DB_DIR/db_operations.log"
DB_CONFIG="$DB_DIR/db_config.json"

# ══════════════════════════════════════════════════════════════════
# 📊 تحلیل منابع سیستم (سازگار با همه سیستم‌ها)
# ══════════════════════════════════════════════════════════════════
analyze_system_resources() {
    echo -e "${BLUE}📊 تحلیل منابع سیستم...${NC}"
    
    # RAM (MB) - روش مطمئن
    if [ -f /proc/meminfo ]; then
        TOTAL_RAM=$(awk '/^MemTotal:/{printf "%d", $2/1024}' /proc/meminfo)
        AVAILABLE_RAM=$(awk '/^MemAvailable:/{printf "%d", $2/1024}' /proc/meminfo)
    else
        TOTAL_RAM=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || echo "1000")
        AVAILABLE_RAM=$(free -m 2>/dev/null | awk '/^Mem:/{print $7}' || echo "500")
    fi
    TOTAL_RAM=${TOTAL_RAM:-1000}
    AVAILABLE_RAM=${AVAILABLE_RAM:-500}
    RAM_PERCENT=$((AVAILABLE_RAM * 100 / TOTAL_RAM))
    
    # CPU
    CPU_CORES=$(nproc 2>/dev/null || echo "1")
    CPU_LOAD=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 || echo "50")
    CPU_LOAD=${CPU_LOAD%.*}
    CPU_LOAD=${CPU_LOAD:-50}
    
    # Disk (MB) - روش سازگار
    DISK_TOTAL=$(df -m / 2>/dev/null | awk 'NR==2 {print $2}' || echo "10000")
    DISK_AVAILABLE=$(df -m / 2>/dev/null | awk 'NR==2 {print $4}' || echo "5000")
    DISK_TOTAL=${DISK_TOTAL:-10000}
    DISK_AVAILABLE=${DISK_AVAILABLE:-5000}
    DISK_AVAILABLE_GB=$((DISK_AVAILABLE / 1024))
    DISK_TOTAL_GB=$((DISK_TOTAL / 1024))
    DISK_PERCENT=$((DISK_AVAILABLE * 100 / DISK_TOTAL))
    
    # تبدیل به GB برای مقایسه
    DISK_AVAILABLE_GB=$((DISK_AVAILABLE / 1024))
    DISK_TOTAL_GB=$((DISK_TOTAL / 1024))
    
    # تعیین سطح سیستم
    if [ $TOTAL_RAM -ge 7000 ] && [ $CPU_CORES -ge 4 ] && [ $DISK_AVAILABLE_GB -ge 50 ]; then
        SYSTEM_LEVEL="HIGH"
        CACHE_SIZE=1000
        MAX_RECORDS=50000
        INDEX_TYPE="b-tree"
        COMPRESSION="gzip"
    elif [ $TOTAL_RAM -ge 3500 ] && [ $CPU_CORES -ge 2 ] && [ $DISK_AVAILABLE_GB -ge 20 ]; then
        SYSTEM_LEVEL="MEDIUM"
        CACHE_SIZE=500
        MAX_RECORDS=10000
        INDEX_TYPE="hash"
        COMPRESSION="gzip"
    else
        SYSTEM_LEVEL="LOW"
        CACHE_SIZE=100
        MAX_RECORDS=5000
        INDEX_TYPE="simple"
        COMPRESSION="none"
    fi
    
    echo -e "${CYAN}💻 مشخصات سیستم:${NC}"
    echo -e "   RAM: ${TOTAL_RAM}MB (${RAM_PERCENT}% آزاد)"
    echo -e "   CPU: ${CPU_CORES} هسته"
    echo -e "   دیسک: ${DISK_AVAILABLE_GB}GB از ${DISK_TOTAL_GB}GB آزاد"
    echo -e "   سطح: ${YELLOW}${SYSTEM_LEVEL}${NC}"
    echo -e "   کش: ${CACHE_SIZE} رکورد | حداکثر: ${MAX_RECORDS}"
}

# ══════════════════════════════════════════════════════════════════
# 🗄️ راه‌اندازی پایگاه داده
# ══════════════════════════════════════════════════════════════════
init_database() {
    echo -e "${BLUE}🗄️ راه‌اندازی پایگاه داده...${NC}"
    
    mkdir -p "$DB_DIR" "$DB_BACKUP_DIR"
    
    # ذخیره تنظیمات
    echo "{" > "$DB_CONFIG"
    echo "  \"version\": \"2.0\"," >> "$DB_CONFIG"
    echo "  \"system_level\": \"$SYSTEM_LEVEL\"," >> "$DB_CONFIG"
    echo "  \"cache_size\": $CACHE_SIZE," >> "$DB_CONFIG"
    echo "  \"max_records\": $MAX_RECORDS," >> "$DB_CONFIG"
    echo "  \"index_type\": \"$INDEX_TYPE\"," >> "$DB_CONFIG"
    echo "  \"compression\": \"$COMPRESSION\"," >> "$DB_CONFIG"
    echo "  \"created\": \"$(date)\"," >> "$DB_CONFIG"
    echo "  \"last_optimized\": \"$(date)\"" >> "$DB_CONFIG"
    echo "}" >> "$DB_CONFIG"
    
    # اگر دیتابیس وجود نداره، از کدهای موجود استخراج کنه
    if [ ! -f "$DB_FILE" ]; then
        echo -e "${YELLOW}📝 ایجاد دیتابیس از کدهای موجود...${NC}"
        extract_phrases_from_code
    fi
    
    # ایجاد ایندکس اگر وجود نداره
    if [ ! -f "$DB_INDEX" ]; then
        build_index
    fi
    
    echo -e "${GREEN}✅ پایگاه داده آماده است${NC}"
}

# ══════════════════════════════════════════════════════════════════
# 📝 استخراج عبارات از کدهای موجود
# ══════════════════════════════════════════════════════════════════
extract_phrases_from_code() {
    echo -e "${BLUE}📝 استخراج عبارات از فایل‌های HTML...${NC}"
    
    # شروع فایل JSON
    echo "{" > "$DB_FILE"
    local first=true
    local count=0
    
    # استخراج از فایل‌های HTML
    for html_file in index.html نطق_مصطلح_کامل.html; do
        if [ -f "$html_file" ]; then
            echo -e "${CYAN}  پردازش: $html_file${NC}"
            
            # استخراج با awk (مطمئن‌تر از bash regex)
            awk '
            /"[^"]+":\s*{/ {
                if (match($0, /"([^"]+)":/)) {
                    phrase = substr($0, RSTART+1, RLENGTH-3)
                    if (length(phrase) > 3) {
                        print phrase
                    }
                }
            }' "$html_file" | while read -r phrase; do
                if [ -n "$phrase" ]; then
                    # استخراج معنی
                    mani=$(grep -A1 "\"$phrase\"" "$html_file" | grep '"mani"' | head -1 | sed 's/.*"mani": "//;s/",\?$//;s/"$//')
                    # استخراج مثال
                    mesal=$(grep -A2 "\"$phrase\"" "$html_file" | grep '"mesal"' | head -1 | sed 's/.*"mesal": "//;s/",\?$//;s/"$//')
                    # استخراج احساس
                    ehsas=$(grep -A3 "\"$phrase\"" "$html_file" | grep '"ehsas"' | head -1 | sed 's/.*"ehsas": "//;s/",\?$//;s/"$//')
                    
                    if [ "$first" = true ]; then
                        first=false
                    else
                        echo "," >> "$DB_FILE"
                    fi
                    
                    echo -n "  \"$phrase\": {" >> "$DB_FILE"
                    echo -n "\"mani\": \"$mani\"" >> "$DB_FILE"
                    [ -n "$mesal" ] && echo -n ", \"mesal\": \"$mesal\"" >> "$DB_FILE"
                    [ -n "$ehsas" ] && echo -n ", \"ehsas\": \"$ehsas\"" >> "$DB_FILE"
                    echo "}" >> "$DB_FILE"
                    
                    count=$((count + 1))
                fi
            done
        fi
    done
    
    # پایان فایل JSON
    echo "}" >> "$DB_FILE"
    
    echo -e "${GREEN}✅ $count عبارت استخراج و ذخیره شد${NC}"
}

# ══════════════════════════════════════════════════════════════════
# 📑 ساخت ایندکس
# ══════════════════════════════════════════════════════════════════
build_index() {
    echo -e "${BLUE}📑 ساخت ایندکس...${NC}"
    
    local total=$(grep -c '": {' "$DB_FILE" 2>/dev/null || echo "0")
    
    echo "{" > "$DB_INDEX"
    echo "  \"type\": \"$INDEX_TYPE\"," >> "$DB_INDEX"
    echo "  \"last_updated\": \"$(date)\"," >> "$DB_INDEX"
    echo "  \"total_records\": $total," >> "$DB_INDEX"
    echo "  \"categories\": {" >> "$DB_INDEX"
    echo "    \"estelahat\": []," >> "$DB_INDEX"
    echo "    \"zarbolmasalha\": []," >> "$DB_INDEX"
    echo "    \"ashare_mardomi\": []," >> "$DB_INDEX"
    echo "    \"general\": []" >> "$DB_INDEX"
    echo "  }" >> "$DB_INDEX"
    echo "}" >> "$DB_INDEX"
    
    echo -e "${GREEN}✅ ایندکس ساخته شد ($total رکورد)${NC}"
}

# ══════════════════════════════════════════════════════════════════
# 💾 پشتیبان‌گیری هوشمند
# ══════════════════════════════════════════════════════════════════
smart_backup() {
    echo -e "${BLUE}💾 پشتیبان‌گیری هوشمند...${NC}"
    
    BACKUP_NAME="db_backup_$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$DB_FILE" ]; then
        case $SYSTEM_LEVEL in
            "HIGH")
                tar -czf "$DB_BACKUP_DIR/$BACKUP_NAME.tar.gz" -C "$DB_DIR" . 2>/dev/null
                ls -t "$DB_BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
                ;;
            "MEDIUM")
                cp "$DB_FILE" "$DB_BACKUP_DIR/$BACKUP_NAME.json"
                gzip "$DB_BACKUP_DIR/$BACKUP_NAME.json" 2>/dev/null
                ls -t "$DB_BACKUP_DIR"/*.gz 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null
                ;;
            "LOW")
                if [ $DISK_AVAILABLE_GB -gt 1 ]; then
                    cp "$DB_FILE" "$DB_BACKUP_DIR/$BACKUP_NAME.json"
                    ls -t "$DB_BACKUP_DIR"/*.json 2>/dev/null | tail -n +4 | xargs rm -f 2>/dev/null
                fi
                ;;
        esac
        echo -e "${GREEN}✅ پشتیبان ایجاد شد: $BACKUP_NAME${NC}"
    else
        echo -e "${YELLOW}⚠️ دیتابیسی برای پشتیبان‌گیری وجود ندارد${NC}"
    fi
}

# ══════════════════════════════════════════════════════════════════
# 🔍 جستجوی سریع
# ══════════════════════════════════════════════════════════════════
smart_search() {
    local query="$1"
    
    if [ -z "$query" ]; then
        read -p "🔍 عبارت مورد نظر: " query
    fi
    
    echo -e "${BLUE}🔍 جستجو: \"$query\"${NC}"
    
    if [ ! -f "$DB_FILE" ]; then
        echo -e "${RED}❌ دیتابیس وجود ندارد${NC}"
        return 1
    fi
    
    echo -e "${CYAN}نتایج:${NC}"
    echo "----------------------------------------"
    
    # جستجو با grep و نمایش نتایج
    local found=0
    while IFS= read -r line; do
        if [[ $line =~ \"([^\"]+)\":\ \{ ]]; then
            phrase="${BASH_REMATCH[1]}"
            # چک کردن اینکه query در عبارت یا معنی یا مثال باشه
            if echo "$phrase" | grep -qi "$query" || 
               grep -A5 "\"$phrase\"" "$DB_FILE" | grep -qi "$query"; then
                echo -e "  ${GOLD}✨ $phrase${NC}"
                grep -A5 "\"$phrase\"" "$DB_FILE" | grep -E '"mani"|"mesal"' | head -2 | sed 's/.*": "//;s/",\?$//' | while read -r info; do
                    echo -e "    ${CYAN}$info${NC}"
                done
                echo ""
                found=$((found + 1))
            fi
        fi
    done < "$DB_FILE"
    
    echo "----------------------------------------"
    echo -e "${GREEN}📊 $found نتیجه یافت شد${NC}"
}

# ══════════════════════════════════════════════════════════════════
# ➕ افزودن عبارت جدید
# ══════════════════════════════════════════════════════════════════
add_phrase() {
    local phrase="$1"
    local meaning="$2"
    local example="$3"
    local category="${4:-general}"
    
    if [ -z "$phrase" ]; then
        read -p "عبارت: " phrase
        read -p "معنی: " meaning
        read -p "مثال: " example
        read -p "دسته‌بندی (پیش‌فرض: general): " category
        category=${category:-general}
    fi
    
    if [ -z "$phrase" ] || [ -z "$meaning" ]; then
        echo -e "${RED}❌ عبارت و معنی الزامی است${NC}"
        return 1
    fi
    
    echo -e "${BLUE}➕ افزودن عبارت جدید...${NC}"
    
    # چک کردن تکراری نبودن
    if grep -q "\"$phrase\":" "$DB_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️ این عبارت قبلاً وجود دارد${NC}"
        return 1
    fi
    
    # بکاپ قبل از تغییر
    cp "$DB_FILE" "$DB_FILE.bak"
    
    # حذف } آخر فایل
    sed -i '$ d' "$DB_FILE"
    
    # افزودن کاما اگر فایل خالی نیست
    if [ $(wc -l < "$DB_FILE") -gt 1 ]; then
        echo "," >> "$DB_FILE"
    fi
    
    # افزودن عبارت جدید
    echo "  \"$phrase\": {" >> "$DB_FILE"
    echo "    \"mani\": \"$meaning\"," >> "$DB_FILE"
    echo "    \"mesal\": \"$example\"," >> "$DB_FILE"
    echo "    \"category\": \"$category\"," >> "$DB_FILE"
    echo "    \"added\": \"$(date)\"" >> "$DB_FILE"
    echo "  }" >> "$DB_FILE"
    echo "}" >> "$DB_FILE"
    
    echo -e "${GREEN}✅ عبارت اضافه شد: $phrase${NC}"
}

# ══════════════════════════════════════════════════════════════════
# 🔧 بهینه‌سازی دیتابیس
# ══════════════════════════════════════════════════════════════════
optimize_database() {
    echo -e "${BLUE}🔧 بهینه‌سازی دیتابیس...${NC}"
    
    if [ ! -f "$DB_FILE" ]; then
        echo -e "${YELLOW}⚠️ دیتابیس وجود ندارد${NC}"
        return
    fi
    
    # حذف خطوط خالی و فشرده‌سازی
    local before=$(wc -c < "$DB_FILE")
    
    # استفاده از python برای فرمت کردن JSON (اگر موجود باشه)
    if command -v python3 &>/dev/null; then
        python3 -c "
import json
try:
    with open('$DB_FILE', 'r', encoding='utf-8') as f:
        data = json.load(f)
    with open('$DB_FILE', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print('OK')
except Exception as e:
    print(f'Error: {e}')
" 2>/dev/null
    fi
    
    local after=$(wc -c < "$DB_FILE")
    local saved=$((before - after))
    
    echo -e "${GREEN}✅ بهینه‌سازی انجام شد${NC}"
    echo -e "${CYAN}   حجم: $(du -h "$DB_FILE" | cut -f1)${NC}"
    
    # بروزرسانی زمان
    if [ -f "$DB_CONFIG" ]; then
        sed -i "s/\"last_optimized\": \".*\"/\"last_optimized\": \"$(date)\"/" "$DB_CONFIG"
    fi
}

# ══════════════════════════════════════════════════════════════════
# 🔗 خروجی برای Frontend
# ══════════════════════════════════════════════════════════════════
export_for_frontend() {
    echo -e "${BLUE}🔗 ساخت خروجی برای Frontend...${NC}"
    
    local output="js/natiq_db.js"
    
    if [ ! -f "$DB_FILE" ]; then
        echo -e "${RED}❌ دیتابیس وجود ندارد${NC}"
        return 1
    fi
    
    mkdir -p js
    
    # هدر فایل
    echo "/* دیتابیس نطق مصطلح - خودکار */" > "$output"
    echo "/* تاریخ: $(date) */" >> "$output"
    echo "/* سطح سیستم: $SYSTEM_LEVEL */" >> "$output"
    echo "" >> "$output"
    echo "const NATIQ_DB = " >> "$output"
    cat "$DB_FILE" >> "$output"
    echo ";" >> "$output"
    
    # توابع جستجو
    cat >> "$output" << 'JSCODE'

// تابع جستجو
function searchNatiq(query) {
    query = query.toLowerCase().trim();
    const results = [];
    for (const [phrase, data] of Object.entries(NATIQ_DB)) {
        if (phrase.includes(query) || 
            (data.mani && data.mani.includes(query)) || 
            (data.mesal && data.mesal.includes(query))) {
            results.push({ phrase, ...data });
        }
    }
    return results;
}

// عبارت تصادفی
function getRandomPhrase() {
    const keys = Object.keys(NATIQ_DB);
    const random = keys[Math.floor(Math.random() * keys.length)];
    return { phrase: random, ...NATIQ_DB[random] };
}

// تعداد کل عبارات
function getPhraseCount() {
    return Object.keys(NATIQ_DB).length;
}

console.log("🗄️ نطق مصطلح: " + getPhraseCount() + " عبارت بارگذاری شد");
JSCODE
    
    echo -e "${GREEN}✅ خروجی Frontend: $output${NC}"
    echo -e "${CYAN}   حجم: $(du -h "$output" | cut -f1)${NC}"
}

# ══════════════════════════════════════════════════════════════════
# 📊 گزارش کامل
# ══════════════════════════════════════════════════════════════════
generate_report() {
    echo ""
    echo -e "${GOLD}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}║${NC}  ${YELLOW}📊 گزارش پایگاه داده نطق مصطلح${NC}           ${GOLD}║${NC}"
    echo -e "${GOLD}╚══════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}💻 وضعیت سیستم:${NC}"
    echo -e "   RAM: ${TOTAL_RAM}MB (${RAM_PERCENT}% آزاد)"
    echo -e "   CPU: ${CPU_CORES} هسته"
    echo -e "   دیسک: ${DISK_AVAILABLE_GB}GB آزاد از ${DISK_TOTAL_GB}GB"
    echo -e "   سطح بهینه: ${YELLOW}${SYSTEM_LEVEL}${NC}"
    
    echo ""
    echo -e "${CYAN}🗄️ وضعیت دیتابیس:${NC}"
    if [ -f "$DB_FILE" ]; then
        echo -e "   عبارات: $(grep -c '": {' "$DB_FILE" 2>/dev/null || echo 0)"
        echo -e "   حجم: $(du -h "$DB_FILE" 2>/dev/null | cut -f1)"
        echo -e "   ایندکس: ${INDEX_TYPE:-simple}"
    else
        echo -e "   ${RED}دیتابیس وجود ندارد${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}💾 پشتیبان‌ها:${NC}"
    if [ -d "$DB_BACKUP_DIR" ]; then
        echo -e "   تعداد: $(ls "$DB_BACKUP_DIR" 2>/dev/null | wc -l)"
        echo -e "   حجم: $(du -sh "$DB_BACKUP_DIR" 2>/dev/null | cut -f1)"
    else
        echo -e "   پشتیبانی وجود ندارد"
    fi
    echo ""
}

# ══════════════════════════════════════════════════════════════════
# 📋 منوی اصلی
# ══════════════════════════════════════════════════════════════════
show_menu() {
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║${NC}     ${GOLD}🗄️ پایگاه داده نطق مصطلح${NC}              ${YELLOW}║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║${NC}  ۱. 📊 گزارش وضعیت                          ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ۲. 🔍 جستجوی عبارت                        ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ۳. ➕ افزودن عبارت                         ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ۴. 💾 پشتیبان‌گیری                         ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ۵. 🔧 بهینه‌سازی                           ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ۶. 🔗 خروجی برای Frontend                 ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ۷. 📝 بازسازی دیتابیس                     ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ۸. 🚪 خروج                                 ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════╝${NC}"
}

# ══════════════════════════════════════════════════════════════════
# 🚀 اجرای اصلی
# ══════════════════════════════════════════════════════════════════
main() {
    echo -e "${GOLD}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║   🗄️ سامانه هوشمند پایگاه داده              ║"
    echo "║   نطق مصطلح - نسخه ۲.۰                     ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # تحلیل سیستم
    analyze_system_resources
    
    # راه‌اندازی اولیه
    init_database
    
    # پردازش آرگومان‌ها
    case "${1:-menu}" in
        "--optimize"|"-o")
            smart_backup
            optimize_database
            echo -e "${GREEN}✅ بهینه‌سازی خودکار انجام شد${NC}"
            ;;
        "--backup"|"-b")
            smart_backup
            ;;
        "--export"|"-e")
            export_for_frontend
            ;;
        "--search"|"-s")
            smart_search "$2"
            ;;
        "--report"|"-r")
            generate_report
            ;;
        "--menu"|"-m"|"")
            # منوی تعاملی
            while true; do
                show_menu
                echo ""
                read -p "🎯 انتخاب شما (۱-۸): " choice
                
                case $choice in
                    1) generate_report ;;
                    2) smart_search ;;
                    3) add_phrase ;;
                    4) smart_backup ;;
                    5) optimize_database ;;
                    6) export_for_frontend ;;
                    7) 
                        echo -e "${YELLOW}بازسازی دیتابیس از کدها...${NC}"
                        rm -f "$DB_FILE" "$DB_INDEX"
                        init_database
                        ;;
                    8) 
                        echo -e "${GREEN}خدانگهدار! 👋${NC}"
                        exit 0 
                        ;;
                    *) echo -e "${RED}گزینه نامعتبر${NC}" ;;
                esac
                
                echo ""
                read -p "⏎ Enter برای ادامه..."
            done
            ;;
        *)
            echo "استفاده: $0 [--optimize|--backup|--export|--search|--report|--menu]"
            ;;
    esac
}

# اجرا
main "$@"
