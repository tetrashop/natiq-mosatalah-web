module.exports = async (req, res) => {
  const fs = require('fs');
  const html = fs.readFileSync('./index.html', 'utf-8');
  const phrases = (html.match(/"([^"]+)":\s*\{/g) || []).length;
  res.json({ name: "🧠 Natiq AI", phrases, status: "active" });
};
