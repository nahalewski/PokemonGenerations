const fs = require('fs');
const content = fs.readFileSync('pokemon_generations_backend/server.js', 'utf8');
const stack = [];
for (let i = 0; i < content.length; i++) {
  const char = content[i];
  if (char === '{') {
    stack.push(i);
  } else if (char === '}') {
    if (stack.length === 0) {
      console.log(`Extra } at index ${i}`);
    } else {
      stack.pop();
    }
  }
}
if (stack.length > 0) {
  stack.forEach(index => {
    const lineNum = content.substring(0, index).split('\n').length;
    console.log(`Unclosed { at index ${index} (line ${lineNum})`);
    console.log('Snippet:', content.substring(index, index + 50).replace(/\n/g, ' '));
  });
}
