class VoiceSearch {
    constructor() {
        this.recognition = null;
        this.isListening = false;
        this.init();
    }

    init() {
        if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
            const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
            this.recognition = new SpeechRecognition();
            
            this.recognition.continuous = false;
            this.recognition.interimResults = false;
            this.recognition.lang = 'fa-IR';

            this.recognition.onstart = () => {
                this.isListening = true;
                this.updateButtonState();
            };

            this.recognition.onresult = (event) => {
                const transcript = event.results[0][0].transcript;
                document.querySelector('input[type="text"]').value = transcript;
                this.search(transcript);
            };

            this.recognition.onerror = (event) => {
                console.error('خطا در تشخیص صدا:', event.error);
                this.isListening = false;
                this.updateButtonState();
            };

            this.recognition.onend = () => {
                this.isListening = false;
                this.updateButtonState();
            };
        }
    }

    startListening() {
        if (this.recognition && !this.isListening) {
            try {
                this.recognition.start();
            } catch (error) {
                console.error('خطا در شروع تشخیص صدا:', error);
            }
        }
    }

    stopListening() {
        if (this.recognition && this.isListening) {
            this.recognition.stop();
        }
    }

    search(query) {
        // استفاده از سیستم جستجوی موجود
        const searchEvent = new Event('input', { bubbles: true });
        const searchInput = document.querySelector('input[type="text"]');
        searchInput.value = query;
        searchInput.dispatchEvent(searchEvent);

        // اجرای جستجو
        const searchBtn = document.querySelector('button');
        if (searchBtn) searchBtn.click();
    }

    updateButtonState() {
        const voiceBtn = document.getElementById('voice-search-btn');
        if (voiceBtn) {
            if (this.isListening) {
                voiceBtn.innerHTML = '🎤 در حال گوش دادن...';
                voiceBtn.style.background = 'linear-gradient(135deg, #ff4757, #ff3742)';
            } else {
                voiceBtn.innerHTML = '🎤 جستجوی صوتی';
                voiceBtn.style.background = 'linear-gradient(135deg, #4CAF50, #45a049)';
            }
        }
    }

    createVoiceButton() {
        const voiceBtn = document.createElement('button');
        voiceBtn.id = 'voice-search-btn';
        voiceBtn.innerHTML = '🎤 جستجوی صوتی';
        voiceBtn.style.cssText = `
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 25px;
            margin: 10px;
            cursor: pointer;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            transition: all 0.3s ease;
        `;

        voiceBtn.onclick = () => {
            if (this.isListening) {
                this.stopListening();
            } else {
                this.startListening();
            }
        };

        return voiceBtn;
    }
}

// راه‌اندازی جستجوی صوتی
const voiceSearch = new VoiceSearch();
