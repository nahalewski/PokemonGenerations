#!/usr/bin/env bash
set -eo pipefail

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="$(command -v flutter)"
else
  FLUTTER_BIN="/Users/bennahalewski/development/flutter/bin/flutter"
fi

filter_build_noise() {
  sed \
    -e '/Wasm dry run succeeded\./d' \
    -e '/Use --no-wasm-dry-run to disable these warnings\./d' \
    -e '/platform-integration\/web\/wasm/d'
}

echo "[build] Cleaning..."
"$FLUTTER_BIN" clean

echo "[build] Building release web..."
"$FLUTTER_BIN" build web --release --no-tree-shake-icons 2>&1 | filter_build_noise

BUILD_V=$(date +%s)
BOOTSTRAP="build/web/flutter_bootstrap.js"

echo "[build] Patching $BOOTSTRAP (v=$BUILD_V)..."
python3 - "$BUILD_V" "$BOOTSTRAP" <<'PYEOF'
import re
import sys

build_v = sys.argv[1]
path = sys.argv[2]

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(
    r'serviceWorkerSettings\s*:\s*\{[^}]+\}',
    'serviceWorkerSettings: null',
    content,
)
content = content.replace('"main.dart.js"', f'"main.dart.js?v={build_v}"')

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print('  serviceWorkerSettings -> null')
print(f'  main.dart.js -> main.dart.js?v={build_v}')
PYEOF

echo "[build] Removing flutter_service_worker.js..."
rm -f build/web/flutter_service_worker.js

echo "[build] Done. build/web is ready to deploy."
