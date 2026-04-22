const fs = require('fs');
const path = require('path');

const ASSETS_DIR = path.join(__dirname, '..', 'assets');

function processFile(filename) {
    console.log(`Processing ${filename} (Simple Regex Mode)...`);
    const filePath = path.join(ASSETS_DIR, filename);
    const content = fs.readFileSync(filePath, 'utf8');

    // Split by entry
    // Example entry: "	"10000000voltthunderbolt": {"
    const entries = content.split(/\n\t\b(\w+)\b: \{/);
    const result = {};

    for (let i = 1; i < entries.length; i += 2) {
        const id = entries[i];
        const body = entries[i + 1];
        if (!body) continue;

        // Extract simple strings/numbers
        const entry = {};
        
        const nameMatch = body.match(/name:\s*"([^"]+)"/);
        if (nameMatch) entry.name = nameMatch[1];

        const powerMatch = body.match(/basePower:\s*(\d+)/);
        if (powerMatch) entry.basePower = parseInt(powerMatch[1]);

        const accMatch = body.match(/accuracy:\s*(true|\d+)/);
        if (accMatch) entry.accuracy = accMatch[1] === 'true' ? 100 : parseInt(accMatch[1]);

        const typeMatch = body.match(/type:\s*"([^"]+)"/);
        if (typeMatch) entry.type = typeMatch[1];

        const catMatch = body.match(/category:\s*"([^"]+)"/);
        if (catMatch) entry.category = catMatch[1];

        const ppMatch = body.match(/pp:\s*(\d+)/);
        if (ppMatch) entry.pp = parseInt(ppMatch[1]);
        
        const descMatch = body.match(/desc:\s*"([^"]+)"/);
        if (descMatch) entry.desc = descMatch[1];

        result[id] = entry;
    }

    const jsonPath = path.join(ASSETS_DIR, filename.replace('.ts', '.json'));
    fs.writeFileSync(jsonPath, JSON.stringify(result, null, 2));
    console.log(`Saved ${jsonPath} with ${Object.keys(result).length} entries`);
}

// Special case for Pokedex and Learnsets - already worked mostly
// For Items:
function processItems(filename) {
    console.log(`Processing ${filename} (Item Mode)...`);
    const filePath = path.join(ASSETS_DIR, filename);
    const content = fs.readFileSync(filePath, 'utf8');
    const result = {};
    const entries = content.split(/\n\t\b(\w+)\b: \{/);
    for (let i = 1; i < entries.length; i += 2) {
        const id = entries[i];
        const body = entries[i + 1];
        const entry = {};
        const nameMatch = body.match(/name:\s*"([^"]+)"/);
        if (nameMatch) entry.name = nameMatch[1];
        const descMatch = body.match(/shortDesc:\s*"([^"]+)"/);
        if (descMatch) entry.desc = descMatch[1];
        result[id] = entry;
    }
    const jsonPath = path.join(ASSETS_DIR, filename.replace('.ts', '.json'));
    fs.writeFileSync(jsonPath, JSON.stringify(result, null, 2));
}

try {
    // Pokedex and Learnsets were okay with previous script but let's re-run them with simple mode if needed
    // Keep it simple
    processFile('showdown_moves.ts');
    processItems('showdown_items.ts');
    console.log('Finished processing.');
} catch (err) {
    console.error('Fatal error:', err);
}
