#!/bin/bash

# ==============================================================================
# Stitch Aevora Pixel Exchange - Automated Build Suite
# ==============================================================================
# This script automates the production build process for both Android (APK) 
# and Web (Port 65000) distributions.
# ==============================================================================

# 1. Environment Configuration
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Resolve Project Path
PROJECT_DIR="/Users/bennahalewski/Documents/PokeRoster/aevora_exchange"
cd "$PROJECT_DIR" || { echo "ERROR: Project directory not found at $PROJECT_DIR"; exit 1; }

echo "----------------------------------------------------------------"
echo "☢️ INITIALIZING AEVORA_TERMINAL BUILD SEQUENCE..."
echo "----------------------------------------------------------------"

# 2. Dependency Sync
echo "📡 Syncing high-bit dependencies..."
flutter pub get

# 3. Android Production Build
echo "🤖 Building Android APK (Production)..."
flutter build apk --release
if [ $? -eq 0 ]; then
    echo "✅ ANDROID BUILD COMPLETE: $PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ ANDROID BUILD FAILED."
fi

# 4. Web Production Build
echo "🌐 Building Web Distribution (Target Port: 65000)..."
flutter build web --release
if [ $? -eq 0 ]; then
    echo "✅ WEB BUILD COMPLETE: $PROJECT_DIR/build/web"
else
    echo "❌ WEB BUILD FAILED."
fi

echo "----------------------------------------------------------------"
echo "💼 DEPLOYMENT READY"
echo "----------------------------------------------------------------"
echo "To host the web app locally on Port 65000, run:"
echo "cd build/web && python3 -m http.server 65000"
echo "OR"
echo "flutter run -d web-server --web-port 65000"
echo "----------------------------------------------------------------"

# Keep window open
read -p "Press any key to close terminal..."
