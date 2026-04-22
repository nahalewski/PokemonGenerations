#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$ROOT_DIR/pokemon_generations_backend"
APP_DIR="$ROOT_DIR/pokemon_generations"
DASHBOARD_DIR="$ROOT_DIR/pokemon_generations_dashboard"
EXCHANGE_DIR="$ROOT_DIR/aevora_exchange"
LOG_DIR="$ROOT_DIR/.logs"

FLUTTER_BIN="/Users/bennahalewski/development/flutter/bin/flutter"
ADB_BIN="/opt/homebrew/bin/adb"
NODE_BIN="/Users/bennahalewski/.nvm/versions/node/v22.22.1/bin/node"
CLOUDFLARED_BIN="$ROOT_DIR/cloudflared"

mkdir -p "$LOG_DIR"

build_flutter_web() {
  local project_dir="$1"
  local pub_log="$2"
  local build_log="$3"
  local label="$4"

  echo "📦 Building $label..."
  cd "$project_dir"

  if ! "$FLUTTER_BIN" pub get > "$pub_log" 2>&1; then
    echo "⚠️  pub get failed for $label. See $pub_log"
    return 1
  fi

  if ! "$FLUTTER_BIN" build web --release --no-tree-shake-icons > "$build_log" 2>&1; then
    echo "⚠️  build failed for $label. See $build_log"
    return 1
  fi

  return 0
}

start_static_server() {
  local port="$1"
  local directory="$2"
  local log_file="$3"
  local label="$4"

  if [ ! -d "$directory" ]; then
    echo "⚠️  Skipping $label on port $port because $directory does not exist."
    return 1
  fi

  nohup python3 -m http.server "$port" --directory "$directory" > "$log_file" 2>&1 &
  return 0
}

echo "--------------------------------------"
echo "🚀 Starting Pokemon Generations Stack"
echo "--------------------------------------"

kill_port() {
  local port="$1"
  lsof -ti:"$port" | xargs kill -9 2>/dev/null || true
}

echo "🧹 Cleaning existing processes..."
kill_port 8080
kill_port 8191
kill_port 8192
kill_port 8193
kill_port 8194
pkill -f "$CLOUDFLARED_BIN" 2>/dev/null || true

export PATH="/opt/homebrew/bin:$PATH"

WEB_BUILD_OK=0
DASHBOARD_BUILD_OK=0
EXCHANGE_BUILD_OK=0

if build_flutter_web \
  "$APP_DIR" \
  "$LOG_DIR/generations_pub.log" \
  "$LOG_DIR/generations_build.log" \
  "main web app for generations.orosapp.us"; then
  WEB_BUILD_OK=1
fi

if build_flutter_web \
  "$DASHBOARD_DIR" \
  "$LOG_DIR/dashboard_pub.log" \
  "$LOG_DIR/dashboard_build.log" \
  "local dashboard (port 8080)"; then
  DASHBOARD_BUILD_OK=1
fi

if [ -f "$EXCHANGE_DIR/build_web.sh" ]; then
  echo "📦 Building Aevora Exchange for exchange.orosapp.us..."
  cd "$EXCHANGE_DIR"
  if bash build_web.sh >> "$LOG_DIR/exchange_build.log" 2>&1; then
    EXCHANGE_BUILD_OK=1
    echo "✅ Aevora Exchange build OK"
  else
    echo "⚠️  Aevora Exchange build failed. See $LOG_DIR/exchange_build.log"
  fi
  cd "$ROOT_DIR"
fi

echo "🔁 Setting up ADB reverse for USB device (if connected)..."
"$ADB_BIN" -s 602305N15309192 reverse tcp:8194 tcp:8194 2>/dev/null || echo "ADB device not connected, skipping"

echo "🌐 Starting public web app on port 8191..."
WEB_PID="not started"
if start_static_server 8191 "$APP_DIR/build/web" "$LOG_DIR/web_app.log" "public web app"; then
  WEB_PID=$!
fi

echo "🖥️  Starting admin dashboard on port 8080..."
DASHBOARD_PID="not started"
if start_static_server 8080 "$DASHBOARD_DIR/build/web" "$LOG_DIR/dashboard.log" "admin dashboard"; then
  DASHBOARD_PID=$!
fi

echo "💱 Starting Aevora Exchange on port 8192..."
EXCHANGE_PID="not started"
if start_static_server 8192 "$EXCHANGE_DIR/build/web" "$LOG_DIR/exchange.log" "Aevora Exchange"; then
  EXCHANGE_PID=$!
fi

echo "⚡ Starting backend on port 8194..."
cd "$BACKEND_DIR"
nohup "$NODE_BIN" server.js > "$LOG_DIR/backend.log" 2>&1 &
BACKEND_PID=$!

echo "☁️ Starting Cloudflare tunnel..."
nohup "$CLOUDFLARED_BIN" --config "$HOME/.cloudflared/config.yml" tunnel run > "$LOG_DIR/cloudflared.log" 2>&1 &
TUNNEL_PID=$!

sleep 3

echo "--------------------------------------"
echo "✅ Stack is starting"
echo "--------------------------------------"
echo "Backend PID:      $BACKEND_PID"
echo "Web App PID:      $WEB_PID"
echo "Dashboard PID:    $DASHBOARD_PID"
echo "Exchange PID:     $EXCHANGE_PID"
echo "Tunnel PID:       $TUNNEL_PID"
echo "Web build OK:     $WEB_BUILD_OK"
echo "Dash build OK:    $DASHBOARD_BUILD_OK"
echo "Exchange build OK: $EXCHANGE_BUILD_OK"
echo ""
echo "Backend API:       https://poke.orosapp.us (Port 8194)"
echo "Aevora Exchange:   https://exchange.orosapp.us (Port 8192)"
echo "Main Web App:      https://generations.orosapp.us (Port 8191)"
echo "Admin Dashboard:   http://127.0.0.1:8080 (Port 8080)"
echo ""
echo "Local Links:"
echo "  Backend:   http://127.0.0.1:8194/health"
echo "  Exchange:  http://127.0.0.1:8192"
echo "  Web App:   http://127.0.0.1:8191"
echo ""
echo "Logs:"
echo "  $LOG_DIR/backend.log"
echo "  $LOG_DIR/web_app.log"
echo "  $LOG_DIR/dashboard.log"
echo "  $LOG_DIR/cloudflared.log"
echo "  $LOG_DIR/generations_build.log"
echo "  $LOG_DIR/dashboard_build.log"
echo "--------------------------------------"

open "https://generations.orosapp.us" 2>/dev/null || true
open "http://127.0.0.1:8192" 2>/dev/null || true

echo "Press Control+C to close this launcher window."
tail -f "$LOG_DIR/backend.log" "$LOG_DIR/cloudflared.log"
