class UserSystem {
    constructor() {
        this.currentUser = null;
        this.init();
    }

    init() {
        this.loadUserData();
        this.createUserInterface();
    }

    loadUserData() {
        const userData = localStorage.getItem('natiqUser');
        if (userData) {
            this.currentUser = JSON.parse(userData);
        } else {
            this.currentUser = {
                id: this.generateUserId(),
                username: 'کاربر مهمان',
                joinDate: new Date().toISOString(),
                searchHistory: [],
                favoritePhrases: [],
                credit: 5,
                settings: {
                    theme: 'light',
                    notifications: true,
                    voiceSearch: false
                }
            };
            this.saveUserData();
        }
        this.updateUserDisplay();
    }

    generateUserId() {
        return 'user_' + Math.random().toString(36).substr(2, 9);
    }

    saveUserData() {
        localStorage.setItem('natiqUser', JSON.stringify(this.currentUser));
    }

    createUserInterface() {
        const userPanel = document.createElement('div');
        userPanel.id = 'user-panel';
        userPanel.innerHTML = `
            <div style="
                position: fixed;
                top: 20px;
                right: 20px;
                background: linear-gradient(135deg, #ff9a9e, #fad0c4);
                color: white;
                padding: 10px 15px;
                border-radius: 20px;
                font-size: 14px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.2);
                z-index: 1000;
                cursor: pointer;
            ">
                👤 ${this.currentUser.username}
                <div id="user-menu" style="
                    display: none;
                    position: absolute;
                    top: 100%;
                    right: 0;
                    background: white;
                    color: #333;
                    border-radius: 10px;
                    padding: 10px;
                    margin-top: 5px;
                    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
                    min-width: 200px;
                ">
                    <div style="padding: 5px 0; border-bottom: 1px solid #eee;">
                        <strong>${this.currentUser.username}</strong>
                    </div>
                    <div style="padding: 5px 0; border-bottom: 1px solid #eee;">
                        📊 تاریخچه جستجو: ${this.currentUser.searchHistory.length}
                    </div>
                    <div style="padding: 5px 0; border-bottom: 1px solid #eee;">
                        ⭐ علاقه‌مندی‌ها: ${this.currentUser.favoritePhrases.length}
                    </div>
                    <div style="padding: 5px 0;">
                        <button onclick="userSystem.showSearchHistory()" style="
                            background: #667eea;
                            color: white;
                            border: none;
                            padding: 8px 15px;
                            border-radius: 5px;
                            width: 100%;
                            cursor: pointer;
                            margin: 2px 0;
                        ">📜 تاریخچه جستجو</button>
                        <button onclick="userSystem.showFavorites()" style="
                            background: #ff9a9e;
                            color: white;
                            border: none;
                            padding: 8px 15px;
                            border-radius: 5px;
                            width: 100%;
                            cursor: pointer;
                            margin: 2px 0;
                        ">⭐ علاقه‌مندی‌ها</button>
                    </div>
                </div>
            </div>
        `;

        document.body.appendChild(userPanel);

        userPanel.querySelector('div').addEventListener('click', (e) => {
            const menu = document.getElementById('user-menu');
            menu.style.display = menu.style.display === 'block' ? 'none' : 'block';
            e.stopPropagation();
        });

        document.addEventListener('click', () => {
            const menu = document.getElementById('user-menu');
            if (menu) menu.style.display = 'none';
        });
    }

    addToSearchHistory(searchTerm, result) {
        this.currentUser.searchHistory.unshift({
            term: searchTerm,
            result: result,
            timestamp: new Date().toISOString(),
            creditUsed: 1
        });

        if (this.currentUser.searchHistory.length > 50) {
            this.currentUser.searchHistory = this.currentUser.searchHistory.slice(0, 50);
        }

        this.saveUserData();
    }

    addToFavorites(phrase, meaning) {
        const existingIndex = this.currentUser.favoritePhrases.findIndex(
            fav => fav.phrase === phrase
        );

        if (existingIndex === -1) {
            this.currentUser.favoritePhrases.push({
                phrase: phrase,
                meaning: meaning,
                timestamp: new Date().toISOString()
            });
            this.saveUserData();
            return true;
        }
        return false;
    }

    removeFromFavorites(phrase) {
        this.currentUser.favoritePhrases = this.currentUser.favoritePhrases.filter(
            fav => fav.phrase !== phrase
        );
        this.saveUserData();
    }

    showSearchHistory() {
        this.showModal('تاریخچه جستجو', this.currentUser.searchHistory, 'search');
    }

    showFavorites() {
        this.showModal('علاقه‌مندی‌ها', this.currentUser.favoritePhrases, 'favorites');
    }

    showModal(title, data, type) {
        const modal = document.createElement('div');
        modal.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 3000;
        `;

        const modalContent = document.createElement('div');
        modalContent.style.cssText = `
            background: white;
            padding: 20px;
            border-radius: 15px;
            max-width: 90%;
            max-height: 80%;
            overflow-y: auto;
            width: 400px;
        `;

        let content = `<h3>${title}</h3>`;
        
        if (data.length === 0) {
            content += '<p>موردی یافت نشد.</p>';
        } else {
            content += '<div style="max-height: 300px; overflow-y: auto;">';
            data.forEach((item, index) => {
                if (type === 'search') {
                    content += `
                        <div style="padding: 10px; border-bottom: 1px solid #eee;">
                            <strong>${item.term}</strong>
                            <div style="font-size: 12px; color: #666;">
                                ${new Date(item.timestamp).toLocaleString('fa-IR')}
                            </div>
                        </div>
                    `;
                } else if (type === 'favorites') {
                    content += `
                        <div style="padding: 10px; border-bottom: 1px solid #eee;">
                            <strong>${item.phrase}</strong>
                            <div style="font-size: 12px; color: #666;">${item.meaning}</div>
                            <button onclick="userSystem.removeFromFavorites('${item.phrase}')" style="
                                background: #ff4757;
                                color: white;
                                border: none;
                                padding: 5px 10px;
                                border-radius: 5px;
                                font-size: 10px;
                                cursor: pointer;
                                margin-top: 5px;
                            ">حذف</button>
                        </div>
                    `;
                }
            });
            content += '</div>';
        }

        content += `
            <button onclick="this.closest('div[style]').remove()" style="
                background: #667eea;
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 5px;
                cursor: pointer;
                margin-top: 15px;
                width: 100%;
            ">بستن</button>
        `;

        modalContent.innerHTML = content;
        modal.appendChild(modalContent);
        document.body.appendChild(modal);
    }

    updateUserDisplay() {
        const userElement = document.querySelector('#user-panel div');
        if (userElement) {
            userElement.innerHTML = `👤 ${this.currentUser.username}`;
        }
    }
}

const userSystem = new UserSystem();
