const fs = require('fs');
const content = fs.readFileSync('pokemon_generations_backend/server.js', 'utf8');
const lines = content.split('\n');
let count = 0;
lines.forEach((line, index) => {
  const open = (line.match(/{/g) || []).length;
  const close = (line.match(/}/g) || []).length;
  count += open - close;
  if (count < 0) {
    console.log(`Unbalanced at line ${index + 1}: ${line}`);
    count = 0; // reset to find more
  }
});
console.log(`Final count: ${count}`);
