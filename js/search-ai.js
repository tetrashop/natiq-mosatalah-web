// هسته هوش مصنوعی نطق مصطلح - موتور جستجوی پیشرفته
class NatiqAI {
    constructor() {
        this.searchHistory = [];
        this.favorites = [];
    }

    // جستجوی هوشمند با الگوریتم fuzzy matching
    smartSearch(query) {
        if (!query || query.trim().length < 2) {
            return [];
        }

        const searchTerm = query.trim().toLowerCase();
        const results = [];
        
        // الگوریتم جستجوی چندلایه
        natiqDatabase.forEach(item => {
            let score = 0;
            
            // جستجوی دقیق در عبارت
            if (item.phrase.toLowerCase().includes(searchTerm)) {
                score += 100;
            }
            
            // جستجوی دقیق در معنی
            if (item.meaning.toLowerCase().includes(searchTerm)) {
                score += 80;
            }
            
            // جستجوی fuzzy در عبارت
            if (this.fuzzyMatch(item.phrase.toLowerCase(), searchTerm)) {
                score += 60;
            }
            
            // جستجوی fuzzy در معنی
            if (this.fuzzyMatch(item.meaning.toLowerCase(), searchTerm)) {
                score += 40;
            }
            
            // جستجوی در مثال
            if (item.example && item.example.toLowerCase().includes(searchTerm)) {
                score += 20;
            }
            
            // جستجوی در دسته‌بندی
            if (item.category.toLowerCase().includes(searchTerm)) {
                score += 10;
            }
            
            if (score > 0) {
                results.push({
                    ...item,
                    relevanceScore: score
                });
            }
        });
        
        // مرتب‌سازی بر اساس امتیاز مرتبط‌بودن
        results.sort((a, b) => b.relevanceScore - a.relevanceScore);
        
        // ذخیره در تاریخچه جستجو
        this.addToSearchHistory(query, results.length);
        
        return results.slice(0, 10); // بازگشت 10 نتیجه برتر
    }
    
    // الگوریتم جستجوی fuzzy
    fuzzyMatch(text, search) {
        if (!text || !search) return false;
        
        // جستجوی کلمات جداگانه
        const searchWords = search.split(' ');
        const textWords = text.split(' ');
        
        for (let searchWord of searchWords) {
            if (searchWord.length < 2) continue;
            
            let found = false;
            for (let textWord of textWords) {
                if (textWord.includes(searchWord)) {
                    found = true;
                    break;
                }
            }
            if (!found) return false;
        }
        return true;
    }
    
    // جستجوی پیشرفته با فیلتر
    advancedSearch(query, filters = {}) {
        let results = this.smartSearch(query);
        
        // اعمال فیلترهای مختلف
        if (filters.category) {
            results = results.filter(item => 
                item.category === filters.category
            );
        }
        
        if (filters.usage) {
            results = results.filter(item => 
                item.usage === filters.usage
            );
        }
        
        return results;
    }
    
    // پیشنهادات هوشمند
    getSuggestions(query) {
        if (!query || query.length < 2) return [];
        
        const suggestions = new Set();
        const searchTerm = query.toLowerCase();
        
        natiqDatabase.forEach(item => {
            if (item.phrase.toLowerCase().includes(searchTerm)) {
                suggestions.add(item.phrase);
            }
            if (item.meaning.toLowerCase().includes(searchTerm)) {
                suggestions.add(item.meaning);
            }
        });
        
        return Array.from(suggestions).slice(0, 5);
    }
    
    // مدیریت تاریخچه جستجو
    addToSearchHistory(query, resultCount) {
        this.searchHistory.unshift({
            query: query,
            timestamp: new Date().toISOString(),
            resultCount: resultCount
        });
        
        // محدود کردن تاریخچه به 50 مورد
        if (this.searchHistory.length > 50) {
            this.searchHistory = this.searchHistory.slice(0, 50);
        }
        
        // ذخیره در localStorage
        localStorage.setItem('natiqSearchHistory', JSON.stringify(this.searchHistory));
    }
    
    getSearchHistory() {
        return this.searchHistory;
    }
    
    clearSearchHistory() {
        this.searchHistory = [];
        localStorage.removeItem('natiqSearchHistory');
    }
    
    // مدیریت علاقه‌مندی‌ها
    addToFavorites(itemId) {
        const item = natiqDatabase.find(i => i.id === itemId);
        if (item && !this.favorites.find(fav => fav.id === itemId)) {
            this.favorites.push({
                ...item,
                addedAt: new Date().toISOString()
            });
            localStorage.setItem('natiqFavorites', JSON.stringify(this.favorites));
            return true;
        }
        return false;
    }
    
    removeFromFavorites(itemId) {
        this.favorites = this.favorites.filter(fav => fav.id !== itemId);
        localStorage.setItem('natiqFavorites', JSON.stringify(this.favorites));
    }
    
    getFavorites() {
        return this.favorites;
    }
    
    // بارگذاری داده‌های ذخیره شده
    loadSavedData() {
        try {
            const savedHistory = localStorage.getItem('natiqSearchHistory');
            const savedFavorites = localStorage.getItem('natiqFavorites');
            
            if (savedHistory) {
                this.searchHistory = JSON.parse(savedHistory);
            }
            
            if (savedFavorites) {
                this.favorites = JSON.parse(savedFavorites);
            }
        } catch (error) {
            console.error('خطا در بارگذاری داده‌های ذخیره شده:', error);
        }
    }
    
    // آمار استفاده
    getStats() {
        return {
            totalPhrases: natiqDatabase.length,
            totalSearches: this.searchHistory.length,
            totalFavorites: this.favorites.length,
            categories: [...new Set(natiqDatabase.map(item => item.category))],
            usageTypes: [...new Set(natiqDatabase.map(item => item.usage))]
        };
    }
}

// ایجاد نمونه اصلی
const natiqAI = new NatiqAI();

// بارگذاری داده‌های ذخیره شده
natiqAI.loadSavedData();

console.log('🧠 هسته هوش مصنوعی نطق مصطلح فعال شد!');
console.log('📊 آمار:', natiqAI.getStats());
