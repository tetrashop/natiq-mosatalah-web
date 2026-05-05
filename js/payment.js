"use strict";
// سیستم مدیریت اعتبار و پرداخت - نسخه اصلاح شده
class NatiqPayment {
    constructor() {
        this.credit = parseInt(localStorage.getItem('natiqCredit')) || 12;
        this.init();
    }

    init() {
        this.createCreditDisplay();
        this.setupSearchHandler();
    }

    createCreditDisplay() {
        const creditDiv = document.createElement('div');
        creditDiv.id = 'credit-display';
        creditDiv.innerHTML = `
            <div style="
                position: fixed;
                top: 20px;
                left: 20px;
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                padding: 10px 15px;
                border-radius: 20px;
                font-size: 14px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.2);
                z-index: 1000;
            ">
                💰 اعتبار: <span id="credit-count">${this.credit}</span>
                <button onclick="paymentSystem.addCredit()" style="
                    background: white;
                    color: #667eea;
                    border: none;
                    padding: 5px 10px;
                    border-radius: 10px;
                    margin-right: 10px;
                    cursor: pointer;
                    font-size: 12px;
                ">+ شارژ</button>
            </div>
        `;
        document.body.appendChild(creditDiv);
    }

    setupSearchHandler() {
        const searchBtn = document.querySelector('button');
        if (searchBtn) {
            const originalClick = searchBtn.onclick;
            searchBtn.onclick = async (e) => {
                // ابتدا جستجو انجام شود، سپس اعتبار کسر شود
                if (originalClick) {
                    // اجرای جستجو و بررسی نتیجه
                    const hasResults = await this.executeSearchAndCheckResults();
                    if (hasResults) {
                        this.useCredit(1);
                    } else {
                        alert('❌ هیچ نتیجه‌ای یافت نشد. اعتبار کسر نشد.');
                    }
                }
            };
        }
    }

    // تابع جدید برای بررسی نتیجه جستجو
    async executeSearchAndCheckResults() {
        return new Promise((resolve) => {
            // شبیه‌سازی بررسی نتیجه جستجو
            setTimeout(() => {
                // اینجا باید منطق واقعی بررسی نتیجه جستجو قرار گیرد
                const hasResults = this.checkSearchResults();
                resolve(hasResults);
            }, 100);
        });
    }

    // تابع برای بررسی وجود نتایج جستجو
    checkSearchResults() {
        // اینجا باید منطق واقعی بررسی عناصر نتایج قرار گیرد
        // به طور موقت فرض می‌کنیم اگر عبارت معتبر باشد نتیجه دارد
        const searchInput = document.querySelector('input[type="text"]');
        const searchTerm = searchInput ? searchInput.value.trim() : '';
        
        // لیست عبارات معتبر - این باید با دیتابیس اصلی جایگزین شود
        const validTerms = ['آب از آسیاب افتادن', 'دست بالای دست بسیار است', 'سنگ بزرگ نشانه نزدن است'];
        
        return validTerms.includes(searchTerm);
    }

    useCredit(amount = 1) {
        if (this.credit >= amount) {
            this.credit -= amount;
            this.updateDisplay();
            localStorage.setItem('natiqCredit', this.credit);
            
            setTimeout(() => {
                alert(`✅ جستجو موفق! ${amount} اعتبار کسر شد.\nاعتبار باقی‌مانده: ${this.credit}`);
            }, 500);
            
            return true;
        } else {
            alert('❌ اعتبار کافی نیست! لطفاً حساب خود را شارژ کنید.');
            this.showPaymentModal();
            return false;
        }
    }

    addCredit(amount = 10) {
        this.credit += amount;
        this.updateDisplay();
        localStorage.setItem('natiqCredit', this.credit);
        alert(`🎉 ${amount} اعتبار به حساب شما اضافه شد!\nاعتبار جدید: ${this.credit}`);
    }

    updateDisplay() {
        const creditElement = document.getElementById('credit-count');
        if (creditElement) {
            creditElement.textContent = this.credit;
        }
    }

    showPaymentModal() {
        const modal = document.createElement('div');
        modal.innerHTML = `
            <div style="
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.5);
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 2000;
            ">
                <div style="
                    background: white;
                    padding: 30px;
                    border-radius: 20px;
                    text-align: center;
                    max-width: 400px;
                    width: 90%;
                ">
                    <h3>💳 شارژ حساب</h3>
                    <p>برای ادامه استفاده از نطق مصطلح، حساب خود را شارژ کنید.</p>
                    
                    <div style="margin: 20px 0;">
                        <button onclick="paymentSystem.buyPackage(5)" style="
                            background: linear-gradient(135deg, #667eea, #764ba2);
                            color: white;
                            border: none;
                            padding: 10px 20px;
                            border-radius: 10px;
                            margin: 5px;
                            cursor: pointer;
                        ">۵ اعتبار - ۵,۰۰۰ تومان</button>
                        
                        <button onclick="paymentSystem.buyPackage(20)" style="
                            background: linear-gradient(135deg, #4CAF50, #45a049);
                            color: white;
                            border: none;
                            padding: 10px 20px;
                            border-radius: 10px;
                            margin: 5px;
                            cursor: pointer;
                        ">۲۰ اعتبار - ۱۵,۰۰۰ تومان</button>
                    </div>
                    
                    <button onclick="modal.remove()" style="
                        background: #ff4757;
                        color: white;
                        border: none;
                        padding: 10px 20px;
                        border-radius: 10px;
                        cursor: pointer;
                    ">بستن</button>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }

    buyPackage(amount) {
        alert(`🔗 در حال اتصال به درگاه پرداخت...\nمبلغ: ${amount * 1000} تومان`);
        
        setTimeout(() => {
            this.addCredit(amount);
            document.querySelector('div[style*="position: fixed"]')?.remove();
        }, 2000);
    }
}

// راه‌اندازی سیستم
const paymentSystem = new NatiqPayment();
