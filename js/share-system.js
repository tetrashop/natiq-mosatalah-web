class ShareSystem {
    constructor() {
        this.init();
    }

    init() {
        this.integrateWithSearch();
    }

    integrateWithSearch() {
        setTimeout(() => {
            this.addShareButtonsToResults();
        }, 1000);
    }

    addShareButtonsToResults() {
        const results = document.querySelectorAll('.phrase-result, .search-result, .category-item');
        
        results.forEach((result, index) => {
            if (!result.querySelector('.share-btn')) {
                const shareBtn = document.createElement('button');
                shareBtn.className = 'share-btn';
                shareBtn.innerHTML = '📤 اشتراک‌گذاری';
                shareBtn.style.cssText = `
                    background: linear-gradient(135deg, #667eea, #764ba2);
                    color: white;
                    border: none;
                    padding: 8px 15px;
                    border-radius: 15px;
                    margin: 5px;
                    cursor: pointer;
                    font-size: 12px;
                    transition: all 0.3s ease;
                `;

                shareBtn.onmouseenter = () => {
                    shareBtn.style.transform = 'scale(1.05)';
                };

                shareBtn.onmouseleave = () => {
                    shareBtn.style.transform = 'scale(1)';
                };

                shareBtn.onclick = () => {
                    const phrase = result.querySelector('strong, h3, .phrase-text')?.textContent || 'اصطلاح فارسی';
                    const meaning = result.querySelector('p, .meaning, .description')?.textContent || 'معنی اصطلاح';
                    
                    this.showShareOptions(phrase, meaning);
                };

                result.style.position = 'relative';
                result.appendChild(shareBtn);
            }
        });
    }

    showShareOptions(phrase, meaning) {
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
            z-index: 2500;
        `;

        const shareContent = `
            <div style="
                background: white;
                padding: 25px;
                border-radius: 20px;
                text-align: center;
                max-width: 400px;
                width: 90%;
            ">
                <h3 style="color: #333; margin-bottom: 15px;">📤 اشتراک‌گذاری اصطلاح</h3>
                
                <div style="background: #f8f9fa; padding: 15px; border-radius: 10px; margin: 15px 0;">
                    <strong style="color: #667eea;">${phrase}</strong>
                    <p style="color: #666; margin: 8px 0; font-size: 14px;">${meaning}</p>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin: 20px 0;">
                    <button onclick="shareSystem.shareToTelegram('${phrase}', '${meaning}')" style="
                        background: #0088cc;
                        color: white;
                        border: none;
                        padding: 12px;
                        border-radius: 10px;
                        cursor: pointer;
                        font-size: 13px;
                    ">📱 تلگرام</button>

                    <button onclick="shareSystem.shareToWhatsApp('${phrase}', '${meaning}')" style="
                        background: #25D366;
                        color: white;
                        border: none;
                        padding: 12px;
                        border-radius: 10px;
                        cursor: pointer;
                        font-size: 13px;
                    ">💚 واتساپ</button>

                    <button onclick="shareSystem.copyToClipboard('${phrase}', '${meaning}')" style="
                        background: #6c757d;
                        color: white;
                        border: none;
                        padding: 12px;
                        border-radius: 10px;
                        cursor: pointer;
                        font-size: 13px;
                    ">📋 کپی متن</button>

                    <button onclick="shareSystem.shareAsImage('${phrase}', '${meaning}')" style="
                        background: #ff6b6b;
                        color: white;
                        border: none;
                        padding: 12px;
                        border-radius: 10px;
                        cursor: pointer;
                        font-size: 13px;
                    ">🖼️ عکس</button>
                </div>

                <button onclick="this.closest('div[style]').parentElement.remove()" style="
                    background: #667eea;
                    color: white;
                    border: none;
                    padding: 10px 20px;
                    border-radius: 10px;
                    cursor: pointer;
                    width: 100%;
                ">بستن</button>
            </div>
        `;

        modal.innerHTML = shareContent;
        document.body.appendChild(modal);
    }

    shareToTelegram(phrase, meaning) {
        const text = `📚 *${phrase}*\n\n${meaning}\n\n🔍 از طریق نطق مصطلح`;
        const url = `https://t.me/share/url?url=${encodeURIComponent('https://sensational-croquembouche-457830.netlify.app')}&text=${encodeURIComponent(text)}`;
        window.open(url, '_blank');
    }

    shareToWhatsApp(phrase, meaning) {
        const text = `📚 *${phrase}*\n\n${meaning}\n\n🔍 از طریق نطق مصطلح`;
        const url = `https://wa.me/?text=${encodeURIComponent(text)}`;
        window.open(url, '_blank');
    }

    copyToClipboard(phrase, meaning) {
        const text = `📚 ${phrase}\n\n${meaning}\n\n🔍 از طریق نطق مصطلح\n🌐 https://sensational-croquembouche-457830.netlify.app`;
        
        navigator.clipboard.writeText(text).then(() => {
            alert('✅ متن با موفقیت کپی شد!');
        }).catch(() => {
            const textArea = document.createElement('textarea');
            textArea.value = text;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            alert('✅ متن با موفقیت کپی شد!');
        });
    }

    shareAsImage(phrase, meaning) {
        alert('🖼️ این قابلیت به زودی اضافه خواهد شد!');
    }

    addToFavoritesAndShare(phrase, meaning) {
        if (userSystem.addToFavorites(phrase, meaning)) {
            alert(`✅ "${phrase}" به علاقه‌مندی‌ها اضافه شد!`);
            this.showShareOptions(phrase, meaning);
        } else {
            alert(`ℹ️ "${phrase}" قبلاً در علاقه‌مندی‌ها موجود است.`);
            this.showShareOptions(phrase, meaning);
        }
    }
}

const shareSystem = new ShareSystem();
