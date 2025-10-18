const fs = require('fs');
const html = fs.readFileSync('index.html', 'utf8');

const checks = {
  hasPaymentSystem: html.includes('paymentSystem'),
  hasCreditDisplay: html.includes('credit-display'),
  hasUserPanel: html.includes('user-panel'),
  scriptsLoaded: html.includes('js/payment.js') && html.includes('js/user-system.js'),
  domContentLoaded: html.includes('DOMContentLoaded')
};

console.log('🔍 Validation Results:');
Object.entries(checks).forEach(([key, value]) => {
  console.log(`${value ? '✅' : '❌'} ${key}: ${value}`);
});

if (!Object.values(checks).every(Boolean)) {
  console.log('\n🚨 HTML structure issues detected!');
  process.exit(1);
}
