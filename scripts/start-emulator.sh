#!/usr/bin/env bash
# Keep Noorva AVD running in this terminal (do not launch from Cursor Agent — the window will close).
set -euo pipefail

export ANDROID_HOME="${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}"
export PATH="/opt/homebrew/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${PATH}"

AVD="${NOORVA_AVD:-noorva_pixel}"

if adb devices 2>/dev/null | grep -qE 'emulator-[0-9]+\s+device'; then
  echo "Emulator already connected:"
  adb devices -l
  exit 0
fi

echo "Starting ${AVD} (1080×2400, 4GB RAM — close this terminal to stop the emulator)..."
exec emulator -avd "$AVD" -no-snapshot-load -gpu host -memory 4096
