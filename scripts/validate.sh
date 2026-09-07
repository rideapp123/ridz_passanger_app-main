#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/security_scan.py
python3 -m unittest discover -s scripts -p 'test_*.py'
flutter pub get
flutter analyze
flutter test
