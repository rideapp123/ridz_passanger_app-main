#!/usr/bin/env python3
"""Scan mobile source/configuration without disclosing matched values."""
from pathlib import Path
import re
import os
import sys

ROOT = Path(__file__).resolve().parents[1]
SKIP = {".git", ".dart_tool", ".gradle", "build", "Pods", ".symlinks",
        "ephemeral", ".pub-cache", "node_modules", ".ci"}
PATTERNS = {
    "STRIPE_SECRET": r"\bsk_(?:test|live)_[A-Za-z0-9]{12,}",
    "STRIPE_WEBHOOK_SECRET": r"\bwhsec_[A-Za-z0-9]{12,}",
    "PRIVATE_KEY": r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----",
    "SERVICE_ACCOUNT_PRIVATE_KEY": r'"private_key"\s*:\s*"[^"]+',
    "MONGODB_CREDENTIALS": r"mongodb(?:\+srv)?://[^\s/]+:[^\s/]+@",
    "AWS_ACCESS_KEY": r"\b(?:AKIA|ASIA)[A-Z0-9]{16}\b",
    "MAPBOX_SECRET_TOKEN": r"\bsk\.eyJ[A-Za-z0-9_.-]+",
    "GITHUB_TOKEN": r"\b(?:ghp_|github_pat_)[A-Za-z0-9_]{20,}",
    "JWT_LITERAL": r"\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{20,}",
}
def main():
    audit = "--inventory" in sys.argv
    failures = 0
    def source_files():
        for base, dirs, files in os.walk(ROOT):
            dirs[:] = sorted(d for d in dirs if d not in SKIP)
            for name in sorted(files):
                yield Path(base) / name
    
    for path in source_files():
        rel = path.relative_to(ROOT)
        if not path.is_file() or set(rel.parts) & SKIP or path.stat().st_size > 5_000_000:
            continue
        if path.suffix in {".jks", ".keystore", ".p8", ".p12", ".mobileprovision"}:
            if audit:
                print(f"SIGNING_MATERIAL: {rel} (must remain ignored)")
            continue
        try:
            data = path.read_text()
        except (UnicodeError, OSError):
            continue
        for number, line in enumerate(data.splitlines(), 1):
            for name, pattern in PATTERNS.items():
                if re.search(pattern, line):
                    print(f"CRITICAL SECURITY ISSUE: {name} at {rel}:{number}")
                    failures += 1
            if audit and re.search(r"AIza[A-Za-z0-9_-]{20,}|\bpk_(test|live)_|\bpk\.eyJ", line):
                print(f"CLIENT_CONFIGURATION: {rel}:{number} (restrictions require provider review)")
            if audit and path.name.startswith(".env") and re.match(r"^[A-Z][A-Z0-9_]*=", line):
                print(f"ENV_VARIABLE: {line.split('=', 1)[0]} at {rel}:{number}")
    print(f"Mobile private-credential scan: {failures} finding(s).")
    sys.exit(1 if failures else 0)

if __name__ == "__main__":
    main()
