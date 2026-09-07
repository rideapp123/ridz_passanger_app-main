#!/usr/bin/env python3
"""Create a private, app-specific Android demo upload identity without overwriting keys."""
import hashlib
import json
import os
from pathlib import Path
import secrets
import shutil
import subprocess
import tempfile

from mobile_config import ROOT, ROLE


def java_property(value):
    return str(value).replace("\\", "\\\\").replace(":", "\\:").replace("=", "\\=").replace(" ", "\\ ")


def initialize(root=ROOT, role=ROLE):
    android = root / "android"
    target = android / "demo-signing"
    if target.exists():
        raise RuntimeError("android/demo-signing already exists; refusing to replace a signing identity")
    if not shutil.which("keytool"):
        raise RuntimeError("Install a JDK with keytool before creating demo signing")
    ignored = subprocess.run(["git", "check-ignore", "-q", "android/demo-signing/credentials.properties"],
                             cwd=root, check=False)
    if ignored.returncode != 0:
        raise RuntimeError("android/demo-signing must be ignored before generating credentials")
    with tempfile.TemporaryDirectory(prefix=".demo-signing-", dir=android) as temporary:
        staging = Path(temporary)
        password = secrets.token_hex(32)
        alias = f"ridzs-{role}-demo"
        env = dict(os.environ, RIDZS_DEMO_STORE_PASSWORD=password)
        args = ["keytool", "-genkeypair", "-noprompt", "-storetype", "PKCS12",
                "-keystore", str(staging / "upload.jks"), "-alias", alias,
                "-keyalg", "RSA", "-keysize", "3072", "-validity", "3650",
                "-dname", f"CN=Ridzs {role.title()} Demo,OU=Demo",
                "-storepass:env", "RIDZS_DEMO_STORE_PASSWORD",
                "-keypass:env", "RIDZS_DEMO_STORE_PASSWORD"]
        subprocess.run(args, env=env, check=True, capture_output=True)
        certificate = subprocess.run(
            ["keytool", "-exportcert", "-keystore", str(staging / "upload.jks"),
             "-alias", alias, "-storepass:env", "RIDZS_DEMO_STORE_PASSWORD"],
            env=env, check=True, capture_output=True).stdout
        fingerprints = {
            "applicationId": f"com.ridzs.{role}.demo",
            "SHA1": ":".join(f"{b:02X}" for b in hashlib.sha1(certificate).digest()),
            "SHA256": ":".join(f"{b:02X}" for b in hashlib.sha256(certificate).digest()),
        }
        (staging / "fingerprints.json").write_text(json.dumps(fingerprints, indent=2) + "\n")
        properties = {
            "storeFile": str(target / "upload.jks"),
            "storePassword": password,
            "keyAlias": alias,
            "keyPassword": password,
            "allowedFlavor": "demo",
        }
        (staging / "credentials.properties").write_text(
            "".join(f"{key}={java_property(value)}\n" for key, value in properties.items()))
        for file in staging.iterdir():
            file.chmod(0o600)
        # Atomic installation; a second invocation cannot replace the existing directory.
        staging.rename(target)
    target.chmod(0o700)
    print(f"Created {role} demo signing. Private files: android/demo-signing/")
    print("Firebase signing fingerprints: android/demo-signing/fingerprints.json")
    print("Back up this directory securely before distributing the first demo build.")


if __name__ == "__main__":
    try:
        initialize()
    except RuntimeError as error:
        print(str(error))
        raise SystemExit(1)
    except (OSError, subprocess.CalledProcessError):
        print("Demo signing initialization failed; existing signing files were not replaced.")
        raise SystemExit(1)
