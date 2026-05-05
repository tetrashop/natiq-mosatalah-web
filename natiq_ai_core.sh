#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  🧠 NATIQ AI CORE - هسته مرکزی هوش مصنوعی نطق                        ║
# ║  خودکار - خودیادگیر - همیشه فعال - بهینه‌ساز هوشمند                  ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# ============================================================================
# تنظیمات هسته
# ============================================================================
CORE_NAME="NatiqAI-Core"
VERSION="3.0.0"
PID_FILE="/tmp/natiq_ai_core.pid"
HEARTBEAT_FILE="/tmp/natiq_ai_heartbeat"
CONFIG_FILE="natiq_database/db_config.json"
DB_FILE="natiq_database/natiq_phrases.json"
LOG_DIR="natiq_database/logs"
CYCLE_LOG="$LOG_DIR/ai_cycles.log"
LEARNING_LOG="$LOG_DIR/ai_learning.log"
ERROR_LOG="$LOG_DIR/ai_errors.log"
STATUS_FILE="natiq_database/ai_status.json"

# پیکربندی پویا
IDLE_THRESHOLD=10        # ثانیه بیکاری تا شروع بهینه‌سازی
LEARNING_INTERVAL=300     # هر ۵ دقیقه یادگیری
HEALTH_CHECK_INTERVAL=60  # هر ۱ دقیقه بررسی سلامت
MAX_CPU_LOAD=70          # حداکثر درصد CPU مجاز
MAX_RAM_USAGE=80         # حداکثر درصد RAM مجاز
MIN_DISK_SPACE=500       # حداقل فضای دیسک (MB)

# ============================================================================
# توابع هسته
# ============================================================================

# ── راه‌اندازی اولیه ─────────────────────────────────────────────────────
init_core() {
    mkdir -p "$LOG_DIR" "natiq_database/backups" "natiq_database/cache"
    
    # ثبت شروع به کار
    echo "$$" > "$PID_FILE"
    echo "$(date +%s)" > "$HEARTBEAT_FILE"
    
    log_ai "INFO" "🧠 هسته $CORE_NAME v$VERSION شروع به کار کرد"
    log_ai "INFO" "📊 PID: $$ | سیستم: $(uname -s) | هسته: $(nproc)"
    
    # بررسی اولیه
    health_check
    analyze_environment
}

# ── سیستم لاگ هوشمند ─────────────────────────────────────────────────────
log_ai() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [$level] $message" >> "$CYCLE_LOG"
    
    case "$level" in
        "ERROR") echo "[$timestamp] ❌ $message" >> "$ERROR_LOG" ;;
        "LEARN") echo "[$timestamp] 🧠 $message" >> "$LEARNING_LOG" ;;
    esac
}

# ── تحلیل محیط اجرا ──────────────────────────────────────────────────────
analyze_environment() {
    local ram=$(awk '/^MemTotal:/{printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo "1000")
    local cpu=$(nproc 2>/dev/null || echo "1")
    local disk=$(df -m / 2>/dev/null | awk 'NR==2{print $4}' || echo "1000")
    
    # تنظیم پارامترها بر اساس توان سیستم
    if [ "$ram" -lt 2000 ]; then
        LEARNING_INTERVAL=600
        HEALTH_CHECK_INTERVAL=120
        log_ai "INFO" "⚡ حالت کم‌مصرف فعال شد (RAM: ${ram}MB)"
    elif [ "$ram" -gt 6000 ]; then
        LEARNING_INTERVAL=180
        HEALTH_CHECK_INTERVAL=30
        log_ai "INFO" "🚀 حالت پرقدرت فعال شد (RAM: ${ram}MB)"
    fi
}

# ── بررسی سلامت سیستم ────────────────────────────────────────────────────
health_check() {
    local cpu_load=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 || echo "0")
    local ram_usage=$(free | awk '/^Mem:/{printf "%.0f", $3/$2*100}' 2>/dev/null || echo "0")
    local disk_free=$(df -m . 2>/dev/null | awk 'NR==2{print $4}' || echo "9999")
    local db_size=$(wc -c < "$DB_FILE" 2>/dev/null || echo "0")
    local phrase_count=$(grep -c '": {' "$DB_FILE" 2>/dev/null || echo "0")
    
    # ثبت وضعیت
    cat > "$STATUS_FILE" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "cpu_load": $cpu_load,
  "ram_usage": $ram_usage,
  "disk_free_mb": $disk_free,
  "db_size_bytes": $db_size,
  "phrase_count": $phrase_count,
  "cycles_completed": $cycles,
  "phrases_learned": $learned,
  "optimizations_done": $optimizations,
  "status": "healthy"
}
EOF
    
    # هشدار اگر منابع کم باشه
    [ "${cpu_load%.*}" -gt "$MAX_CPU_LOAD" ] && log_ai "WARN" "CPU بالا: ${cpu_load}%"
    [ "$ram_usage" -gt "$MAX_RAM_USAGE" ] && log_ai "WARN" "RAM بالا: ${ram_usage}%"
    [ "$disk_free" -lt "$MIN_DISK_SPACE" ] && log_ai "WARN" "فضای کم: ${disk_free}MB"
}

# ── تشخیص بیکاری سیستم ───────────────────────────────────────────────────
is_system_idle() {
    local cpu_now=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 || echo "100")
    local load_1min=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',' || echo "99")
    
    # سیستم بیکاره اگر CPU زیر ۲۰٪ و load average زیر ۱ باشه
    if [ "${cpu_now%.*}" -lt 20 ] && [ "${load_1min%.*}" -lt 2 ]; then
        return 0
    fi
    return 1
}

# ── یادگیری از فایل‌های موجود ────────────────────────────────────────────
learn_from_files() {
    log_ai "LEARN" "شروع چرخه یادگیری..."
    
    local new_phrases=0
    
    # ۱. یادگیری از فایل‌های HTML
    for html_file in *.html نطق_*.html; do
        [ -f "$html_file" ] || continue
        
        # استخراج عبارات جدید با الگوهای مختلف
        while IFS= read -r line; do
            # الگوی ۱: عبارات داخل دیتابیس JavaScript
            if [[ "$line" =~ \"([^\"]+)\":\s*\{ ]]; then
                phrase="${BASH_REMATCH[1]}"
                # فیلتر کلیدهای غیرعبارت
                [[ "$phrase" =~ ^(mani|mesal|ehsas|sharer|estelahat|zarbolmasalha|ashare_mardomi|general)$ ]] && continue
                
                if ! grep -q "\"$phrase\":" "$DB_FILE" 2>/dev/null; then
                    # استخراج اطلاعات
                    local mani=$(grep -A5 "\"$phrase\"" "$html_file" | grep '"mani"' | head -1 | sed 's/.*"mani":\s*"//;s/".*//')
                    local mesal=$(grep -A5 "\"$phrase\"" "$html_file" | grep '"mesal"' | head -1 | sed 's/.*"mesal":\s*"//;s/".*//')
                    
                    [ -n "$mani" ] && add_to_database "$phrase" "$mani" "$mesal" "auto-learned" && new_phrases=$((new_phrases + 1))
                fi
            fi
        done < "$html_file"
    done
    
    # ۲. یادگیری از فایل‌های متنی
    for txt_file in *.md *.txt; do
        [ -f "$txt_file" ] || continue
        # استخراج عبارات فارسی بالقوه (کلمات داخل " " یا « »)
        grep -oP '["«][^"»\n]{4,50}["»]' "$txt_file" 2>/dev/null | while read -r phrase; do
            phrase=$(echo "$phrase" | sed 's/^["«]//;s/["»]$//')
            if [ ${#phrase} -gt 5 ] && ! grep -q "\"$phrase\":" "$DB_FILE" 2>/dev/null; then
                add_to_database "$phrase" "عبارت خودآموخته" "یافت شده در $txt_file" "ai-discovered" && new_phrases=$((new_phrases + 1))
            fi
        done
    done
    
    log_ai "LEARN" "✅ چرخه یادگیری: $new_phrases عبارت جدید کشف شد"
    return $new_phrases
}

# ── افزودن به دیتابیس ────────────────────────────────────────────────────
add_to_database() {
    local phrase="$1"
    local meaning="$2"
    local example="$3"
    local source="$4"
    
    # اعتبارسنجی
    [ ${#phrase} -lt 3 ] && return 1
    [ -z "$meaning" ] && return 1
    
    # بکاپ قبل از تغییر
    cp "$DB_FILE" "$DB_FILE.bak" 2>/dev/null
    
    # حذف } آخر
    sed -i '$d' "$DB_FILE" 2>/dev/null
    echo "  ," >> "$DB_FILE"
    
    # افزودن عبارت
    cat >> "$DB_FILE" << PHRASE_END
  "$phrase": {
    "mani": "$meaning",
    "mesal": "$example",
    "source": "$source",
    "learned_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "confidence": 0.8
  }
}
PHRASE_END
    
    log_ai "LEARN" "➕ آموخته شد: $phrase"
    return 0
}

# ── بهینه‌سازی خودکار ───────────────────────────────────────────────────
auto_optimize() {
    log_ai "INFO" "🔧 شروع بهینه‌سازی خودکار..."
    
    # ۱. حذف تکراری‌ها
    local before=$(wc -l < "$DB_FILE")
    python3 -c "
import json
with open('$DB_FILE', 'r') as f:
    data = json.load(f)
unique = {}
for k, v in data.items():
    if k not in unique:
        unique[k] = v
with open('$DB_FILE', 'w') as f:
    json.dump(unique, f, ensure_ascii=False, indent=2)
" 2>/dev/null
    local after=$(wc -l < "$DB_FILE")
    
    # ۲. فشرده‌سازی اگر فضا کم باشه
    local disk_free=$(df -m . | awk 'NR==2{print $4}')
    if [ "$disk_free" -lt 1000 ]; then
        gzip -f "$DB_FILE" 2>/dev/null
        log_ai "INFO" "📦 دیتابیس فشرده شد (فضای کم)"
    fi
    
    # ۳. پاکسازی لاگ‌های قدیمی
    find "$LOG_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null
    find "natiq_database/backups" -name "*.gz" -mtime +30 -delete 2>/dev/null
    
    log_ai "INFO" "✅ بهینه‌سازی: $before -> $after خط"
}

# ── ضربان قلب ─────────────────────────────────────────────────────────────
heartbeat() {
    echo "$(date +%s)" > "$HEARTBEAT_FILE"
}

# ── بررسی توقف ────────────────────────────────────────────────────────────
should_stop() {
    [ -f "/tmp/natiq_ai_stop" ] && return 0
    return 1
}

# ── نمایش وضعیت زنده ─────────────────────────────────────────────────────
live_status() {
    clear
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║  🧠 $CORE_NAME v$VERSION                        ║"
    echo "║  هسته مرکزی هوش مصنوعی - فعال                       ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  ⏱️  زمان اجرا: ${runtime}s                              ║"
    echo "║  🔄 سیکل‌ها: $cycles                                       ║"
    echo "║  🧠 آموخته‌ها: $learned                                   ║"
    echo "║  🔧 بهینه‌سازی‌ها: $optimizations                           ║"
    echo "║  📊 عبارات: $(grep -c '": {' "$DB_FILE" 2>/dev/null || echo 0)                                      ║"
    echo "║  💾 دیسک: $(df -h . | awk 'NR==2{print $4}') آزاد                              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    echo "  📝 آخرین فعالیت‌ها:"
    tail -5 "$CYCLE_LOG" 2>/dev/null | sed 's/^/  /'
}

# ═══════════════════════════════════════════════════════════════════════════
# حلقه اصلی - مغز متفکر
# ═══════════════════════════════════════════════════════════════════════════
main_loop() {
    cycles=0
    learned=0
    optimizations=0
    last_learning=0
    last_health=0
    last_status_update=0
    start_time=$(date +%s)
    
    log_ai "INFO" "🔄 حلقه اصلی شروع شد"
    
    while true; do
        # بررسی توقف
        if should_stop; then
            log_ai "INFO" "🛑 سیگنال توقف دریافت شد"
            rm -f "/tmp/natiq_ai_stop"
            break
        fi
        
        cycles=$((cycles + 1))
        heartbeat
        runtime=$(( $(date +%s) - start_time ))
        
        # ── چرخه یادگیری ─────────────────────────────────────────────
        if [ $(( $(date +%s) - last_learning )) -ge $LEARNING_INTERVAL ]; then
            if is_system_idle; then
                log_ai "INFO" "🧠 سیستم بیکار - شروع یادگیری..."
                learn_from_files
                learned=$((learned + $?))
                last_learning=$(date +%s)
            fi
        fi
        
        # ── چرخه سلامت ──────────────────────────────────────────────
        if [ $(( $(date +%s) - last_health )) -ge $HEALTH_CHECK_INTERVAL ]; then
            health_check
            last_health=$(date +%s)
        fi
        
        # ── بهینه‌سازی خودکار ───────────────────────────────────────
        if [ $cycles -gt 0 ] && [ $((cycles % 50)) -eq 0 ]; then
            if is_system_idle; then
                auto_optimize
                optimizations=$((optimizations + 1))
            fi
        fi
        
        # ── بروزرسانی نمایش ─────────────────────────────────────────
        if [ $(( $(date +%s) - last_status_update )) -ge 30 ]; then
            live_status
            last_status_update=$(date +%s)
        fi
        
        # ── کشف فرصت‌های جدید ───────────────────────────────────────
        if [ $((cycles % 100)) -eq 0 ]; then
            log_ai "INFO" "🔍 اسکن فرصت‌های جدید..."
            
            # چک کردن فایل‌های جدید در پوشه
            new_files=$(find . -name "*.html" -o -name "*.md" -o -name "*.txt" | wc -l)
            log_ai "INFO" "📁 $new_files فایل برای یادگیری موجود است"
        fi
        
        # خواب کوتاه بین سیکل‌ها (صرفه‌جویی در مصرف)
        sleep 2
    done
    
    log_ai "INFO" "🏁 هسته متوقف شد | مجموع سیکل‌ها: $cycles | آموخته‌ها: $learned"
}

# ═══════════════════════════════════════════════════════════════════════════
# مدیریت دستورات
# ═══════════════════════════════════════════════════════════════════════════
case "${1}" in
    "start"|"")
        # شروع هسته
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "⚠️  هسته قبلاً در حال اجراست (PID: $(cat $PID_FILE))"
            echo "برای توقف: $0 stop"
            echo "برای وضعیت: $0 status"
            exit 1
        fi
        
        echo "🧠 شروع هسته $CORE_NAME v$VERSION..."
        init_core
        main_loop &
        echo "✅ هسته در پس‌زمینه شروع به کار کرد (PID: $!)"
        echo ""
        echo "دستورات:"
        echo "  $0 status  - مشاهده وضعیت"
        echo "  $0 stop    - توقف هسته"
        echo "  $0 logs    - مشاهده لاگ‌ها"
        echo "  $0 learn   - یادگیری فوری"
        ;;
    
    "stop")
        if [ -f "$PID_FILE" ]; then
            touch "/tmp/natiq_ai_stop"
            sleep 3
            kill $(cat "$PID_FILE") 2>/dev/null
            rm -f "$PID_FILE" "/tmp/natiq_ai_stop"
            echo "🛑 هسته متوقف شد"
        else
            echo "⚠️  هسته در حال اجرا نیست"
        fi
        ;;
    
    "status")
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "✅ هسته فعال است (PID: $(cat $PID_FILE))"
            cat "$STATUS_FILE" 2>/dev/null
        else
            echo "❌ هسته غیرفعال است"
        fi
        ;;
    
    "logs")
        echo "📝 آخرین لاگ‌ها:"
        tail -20 "$CYCLE_LOG" 2>/dev/null
        ;;
    
    "learn")
        echo "🧠 شروع یادگیری فوری..."
        learn_from_files
        echo "✅ یادگیری انجام شد"
        ;;
    
    "restart")
        $0 stop
        sleep 2
        $0 start
        ;;
    
    *)
        echo "🧠 $CORE_NAME v$VERSION"
        echo ""
        echo "استفاده: $0 {start|stop|status|logs|learn|restart}"
        echo ""
        echo "  start   - شروع هسته (پیش‌فرض)"
        echo "  stop    - توقف هسته"
        echo "  status  - وضعیت فعلی"
        echo "  logs    - مشاهده لاگ‌ها"
        echo "  learn   - یادگیری فوری"
        echo "  restart - راه‌اندازی مجدد"
        ;;
esac
