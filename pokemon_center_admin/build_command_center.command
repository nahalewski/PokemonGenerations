#!/bin/bash

# Pokemon Center Admin: macOS Build Automation Script

# Get the script's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

filter_build_noise() {
    sed "/search path '\/var\/run\/com\\.apple\\.security\\.cryptexd\/mnt\/com\\.apple\\.MobileAsset\\.MetalToolchain/d"
}

echo "=========================================="
echo "POKEMON CENTER: MACOS RELEASE BUILD"
echo "=========================================="

# 1. Clean environment
echo "[1/4] Cleaning build artifacts..."
flutter clean

# 2. Get dependencies
echo "[2/4] Fetching Flutter packages..."
flutter pub get

# 3. CocoaPods Installation
echo "[3/4] Installing native dependencies (CocoaPods)..."
if command -v pod &> /dev/null
then
    cd macos
    pod install
    cd ..
else
    echo "ERROR: CocoaPods ('pod') not found. Please install it with: sudo gem install cocoapods"
    exit 1
fi

# 4. Build Release
echo "[4/4] Compiling Production macOS Release..."
flutter build macos --release --no-tree-shake-icons 2>&1 | filter_build_noise

echo "=========================================="
echo "BUILD COMPLETE!"
echo "Location: $DIR/build/macos/Build/Products/Release/pokemon_center.app"
echo "=========================================="

# Keep terminal open to see results
read -p "Press enter to close"
