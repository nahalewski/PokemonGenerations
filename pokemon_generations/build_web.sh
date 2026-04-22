#!/usr/bin/env bash
# build_web.sh — clean build + disable service worker + cache-bust main.dart.js
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

echo "[BUILD] Cleaning..."
"$FLUTTER_BIN" clean

echo "[BUILD] Building release web..."
"$FLUTTER_BIN" build web --release --no-tree-shake-icons 2>&1 | filter_build_noise

BUILD_V=$(date +%s)
BOOTSTRAP="build/web/flutter_bootstrap.js"

echo "[BUILD] Patching $BOOTSTRAP (v=$BUILD_V)..."
python3 - "$BUILD_V" "$BOOTSTRAP" <<'PYEOF'
import sys, re

build_v = sys.argv[1]
path    = sys.argv[2]

with open(path, 'r') as f:
    content = f.read()

# Disable service worker registration
content = re.sub(
    r'serviceWorkerSettings\s*:\s*\{[^}]+\}',
    'serviceWorkerSettings: null',
    content
)

# Cache-bust main.dart.js so CDN/browsers always fetch fresh JS
content = content.replace('"main.dart.js"', f'"main.dart.js?v={build_v}"')

with open(path, 'w') as f:
    f.write(content)

print(f'  serviceWorkerSettings -> null')
print(f'  main.dart.js -> main.dart.js?v={build_v}')
PYEOF

echo "[build] Removing flutter_service_worker.js..."
rm -f build/web/flutter_service_worker.js

echo "[build] Done. build/web is ready to deploy."
