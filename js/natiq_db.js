"use strict";
/* دیتابیس نطق مصطلح - خودکار */
/* تاریخ: Tue May  5 14:38:24 +0330 2026 */
/* سطح سیستم: LOW */

const NATIQ_DB = 
{
  "دستش درد نکند": {
    "mani": "آفرین، زحمت کشیدی (بیان قدردانی و تشکر)",
    "mesal": "دستت درد نکند که این غذای خوشمزه را درست کردی",
    "ehsas": "قدردانی"
  },
  "چشمم روشن": {
    "mani": "خوشحال شدم از دیدن تو",
    "mesal": "چشمم روشن که بعد از این همه وقت تو را دیدم",
    "ehsas": "خوشحالی"
  },
  "دلم تنگ شده": {
    "mani": "دلم برای کسی یا چیزی تنگ شده",
    "mesal": "دلم تنگ شده برای روزهای قدیم",
    "ehsas": "احساسی"
  },
  "ما شاء الله": {
    "mani": "آنچه خدا خواسته (بیان تحسین، تعجب و توکل)",
    "mesal": "ما شاء الله! چه پروژه زیبایی ساخته‌اید!",
    "ehsas": "تحسین"
  },
  "کبوتر با کبوتر، باز با باز": {
    "mani": "اشخاص با افراد هم‌فکر و هم‌سطح خود معاشرت می‌کنند",
    "mesal": "همیشه با کتابخوان‌ها هستی، کبوتر با کبوتر باز با باز",
    "ehsas": "اجتماعی"
  },
  "آدم عاقل در یک سوراخ دو بار گزیده نمی‌شود": {
    "mani": "انسان باهاش از یک اشتباه دوباره تکرار نمی‌کند",
    "mesal": "بعد از اینکه کلاهبرداری شدی، دیگر به افراد ناشناس اعتماد نکن",
    "ehsas": "پندآموز"
  },
  "گر صبر کنی ز غوره حلوا سازی": {
    "mani": "با صبر و حوصله می‌توان به نتیجه خوب رسید",
    "mesal": "نگران نباش، گر صبر کنی ز غوره حلوا سازی",
    "ehsas": "صبر"
  },
  "چو عضوى به درد آورد روزگار، دگر عضوها را نماند قرار": {
    "mani": "وقتی یکی رنج ببیند، دیگران نیز آرامش ندارند",
    "mesal": "این بیت ادامه همان شعر معروف سعدی است",
    "ehsas": "همدلی"
  }
};

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

//console.log("🗄️ نطق مصطلح: " + getPhraseCount() + " عبارت بارگذاری شد");
