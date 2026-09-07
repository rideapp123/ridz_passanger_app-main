#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
environment="${1:-demo}"
target="${2:-apk}"
client_config="${3:-config/$environment.json}"
case "$environment" in local|demo|prod) ;; *) echo "Use local, demo or prod" >&2; exit 1;; esac
case "$target" in apk|appbundle|run) platform=android;; ipa|ios-run) platform=ios;; *) echo "Use apk, appbundle, ipa, run or ios-run" >&2; exit 1;; esac
if [[ "$environment" == demo && -f android/demo-signing/credentials.properties && -z "${ANDROID_KEY_PROPERTIES:-}" && -z "${ANDROID_KEYSTORE_PATH:-}" ]]; then
  export ANDROID_KEY_PROPERTIES="demo-signing/credentials.properties"
fi
python3 scripts/mobile_config.py --environment "$environment" --platform "$platform" --client-config "$client_config"
bash scripts/validate.sh
args=(--flavor "$environment" --dart-define-from-file=".ci/$environment-defines.json")
if [[ "$target" == run || "$target" == ios-run ]]; then
  exec flutter run "${args[@]}"
fi
if [[ -n "${BUILD_NUMBER:-}" ]]; then
  [[ "$BUILD_NUMBER" =~ ^[1-9][0-9]*$ ]] || { echo "BUILD_NUMBER must be a positive integer" >&2; exit 1; }
  args+=(--build-number="$BUILD_NUMBER")
fi
if [[ "$target" == ipa ]]; then
  [[ -f ios/ExportOptions.plist ]] || { echo "Create ios/ExportOptions.plist for the registered Apple app" >&2; exit 1; }
  args+=(--export-options-plist=ios/ExportOptions.plist)
fi
exec flutter build "$target" --release "${args[@]}"
