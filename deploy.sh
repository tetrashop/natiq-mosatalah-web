#!/bin/bash
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  🚀 NATIQ AUTO-DEPLOY → GitHub → Vercel    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

COMMIT_MSG="${1:-"🔄 بروزرسانی: $(date +'%Y-%m-%d %H:%M')"}"

# ۱. آماده‌سازی فایل‌ها
echo "🔧 آماده‌سازی فایل‌ها..."

[ ! -f "vercel.json" ] && cat > vercel.json << 'VEOF'
{"version":2,"routes":[{"src":"/api/ai-core","dest":"/api/ai_core.js"},{"src":"/(.*)","dest":"/index.html"}]}
VEOF

[ ! -f "manifest.json" ] && echo '{"name":"نطق مصطلح","start_url":"/","display":"standalone"}' > manifest.json

mkdir -p api
cat > api/ai_core.js << 'AIEOF'
module.exports = async (req, res) => {
  const fs = require('fs');
  const html = fs.readFileSync('./index.html', 'utf-8');
  const phrases = (html.match(/"([^"]+)":\s*\{/g) || []).length;
  res.json({ name: "🧠 Natiq AI", phrases, status: "active" });
};
AIEOF

echo "✅ فایل‌ها آماده شد"

# ۲. Pull از گیت‌هاب
echo "📥 دریافت تغییرات از گیت‌هاب..."
git pull origin main --allow-unrelated-histories 2>/dev/null || git pull origin master --allow-unrelated-histories 2>/dev/null || echo "  (first push - skip pull)"

# ۳. Add و Commit
echo "📦 آماده‌سازی کامیت..."
git add .
git commit -m "$COMMIT_MSG" 2>/dev/null || echo "  (بدون تغییر جدید)"

# ۴. Push
echo "📤 آپلود به گیت‌هاب..."
git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null

if [ $? -eq 0 ]; then
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║  ✅ با موفقیت آپلود شد!                    ║"
    echo "║  🔄 Vercel داره خودکار deploy می‌کنه       ║"
    echo "║  🧠 AI Core: /api/ai-core                  ║"
    echo "╚══════════════════════════════════════════════╝"
else
    echo ""
    echo "❌ Push ناموفق - احراز هویت لازمه"
    echo ""
    echo "با توکن شخصی امتحان کنید:"
    echo "  git remote set-url origin https://TOKEN@github.com/tetrashop/natiq-mosatalah-web.git"
    echo "  ./deploy.sh"
fi
