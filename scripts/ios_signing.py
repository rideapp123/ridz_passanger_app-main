#!/usr/bin/env python3
"""Temporary macOS signing keychain and App Store Connect API authentication."""
import base64
import json
import os
import plistlib
import re
import secrets
import shutil
import subprocess
import sys
from pathlib import Path
from ci_inputs import required, decode

ROOT = Path(__file__).resolve().parents[1]
TEMP = Path(required("RUNNER_TEMP")) / "ridzs-ios-signing"
KEYCHAIN = TEMP / "build.keychain-db"

def run(*args):
    return subprocess.run(args, check=True, capture_output=True).stdout

def install():
    TEMP.mkdir(mode=0o700, exist_ok=True)
    decode("APPLE_CERTIFICATE_BASE64", TEMP / "certificate.p12")
    decode("APPLE_PROVISIONING_PROFILE_BASE64", TEMP / "profile.mobileprovision")
    profile = plistlib.loads(run("security", "cms", "-D", "-i", str(TEMP / "profile.mobileprovision")))
    flavor = required("FLAVOR")
    bundle = "com.ridzs.passenger" + ("" if flavor == "prod" else ".demo")
    team = required("APPLE_TEAM_ID")
    expected = team + "." + bundle
    if profile["Entitlements"].get("application-identifier") != expected:
        raise ValueError("Provisioning profile application ID mismatch")
    if profile["Entitlements"].get("aps-environment") != "production":
        raise ValueError("App Store provisioning profile must enable push notifications")
    if profile.get("ProvisionedDevices") or profile.get("ProvisionsAllDevices"):
        raise ValueError("Use an App Store distribution provisioning profile")
    if profile["TeamIdentifier"] != [team]:
        raise ValueError("Provisioning profile team mismatch")
    uuid = profile["UUID"]
    if not re.fullmatch(r"[A-Fa-f0-9-]+", uuid) or not re.fullmatch(r"[A-Z0-9]+", team):
        raise ValueError("Invalid signing identifier format")
    profiles = Path.home() / "Library/MobileDevice/Provisioning Profiles"
    profiles.mkdir(parents=True, exist_ok=True)
    destination = profiles / (uuid + ".mobileprovision")
    if destination.exists():
        raise ValueError("Provisioning profile already exists on this runner")
    (TEMP / "profile-path.txt").write_text(str(destination))
    shutil.copyfile(TEMP / "profile.mobileprovision", destination)
    original = run("security", "list-keychains", "-d", "user").decode()
    keychains = [line.strip().strip('"') for line in original.splitlines() if line.strip()]
    (TEMP / "keychains.json").write_text(json.dumps(keychains))
    password = secrets.token_urlsafe(32)
    run("security", "create-keychain", "-p", password, str(KEYCHAIN))
    run("security", "set-keychain-settings", "-lut", "21600", str(KEYCHAIN))
    run("security", "unlock-keychain", "-p", password, str(KEYCHAIN))
    run("security", "import", str(TEMP / "certificate.p12"), "-P",
        required("APPLE_CERTIFICATE_PASSWORD"), "-A", "-t", "cert", "-f", "pkcs12",
        "-k", str(KEYCHAIN))
    run("security", "set-key-partition-list", "-S", "apple-tool:,apple:,codesign:",
        "-k", password, str(KEYCHAIN))
    run("security", "list-keychains", "-d", "user", "-s", str(KEYCHAIN), *keychains)
    (ROOT / "ios/signing.xcconfig").write_text(
        f"DEVELOPMENT_TEAM = {team}\nCODE_SIGN_STYLE = Manual\n"
        f"CODE_SIGN_IDENTITY = Apple Distribution\nPROVISIONING_PROFILE_SPECIFIER = {uuid}\n")
    options = {"method": "app-store-connect", "teamID": team, "signingStyle": "manual",
               "signingCertificate": "Apple Distribution", "manageAppVersionAndBuildNumber": False,
               "provisioningProfiles": {bundle: uuid}}
    (ROOT / "ios/ExportOptions.plist").write_bytes(plistlib.dumps(options))
    print("Installed temporary signing material for the selected application.")

def upload():
    key = required("APP_STORE_CONNECT_KEY_ID")
    issuer = required("APP_STORE_CONNECT_ISSUER_ID")
    if not re.fullmatch(r"[A-Za-z0-9]+", key):
        raise ValueError("Invalid App Store Connect key ID")
    key_dir = TEMP / "private_keys"
    decode("APP_STORE_CONNECT_PRIVATE_KEY_BASE64", key_dir / f"AuthKey_{key}.p8")
    ipas = list((ROOT / "build/ios/ipa").glob("*.ipa"))
    if len(ipas) != 1:
        raise ValueError("Expected exactly one IPA")
    # altool searches ./private_keys for App Store Connect API keys.
    subprocess.run(["xcrun", "altool", "--upload-app", "--type", "ios", "--file", str(ipas[0]),
                    "--apiKey", key, "--apiIssuer", issuer], cwd=TEMP, check=True)
    print("Upload submitted. Confirm processing and beta review in App Store Connect.")

def cleanup():
    if (TEMP / "keychains.json").exists():
        subprocess.run(["security", "list-keychains", "-d", "user", "-s",
                        *json.loads((TEMP / "keychains.json").read_text())], check=False,
                       capture_output=True)
    if KEYCHAIN.exists():
        subprocess.run(["security", "delete-keychain", str(KEYCHAIN)], check=False, capture_output=True)
    if (TEMP / "profile-path.txt").exists():
        Path((TEMP / "profile-path.txt").read_text()).unlink(missing_ok=True)
    for path in [ROOT / "ios/signing.xcconfig", ROOT / "ios/ExportOptions.plist"]:
        path.unlink(missing_ok=True)
    shutil.rmtree(TEMP, ignore_errors=True)
    shutil.rmtree(ROOT / ".ci", ignore_errors=True)
    for flavor in ("demo", "prod"):
        for name in ("GoogleService-Info.plist", "Client.xcconfig"):
            (ROOT / f"ios/config/{flavor}" / name).unlink(missing_ok=True)

if __name__ == "__main__":
    try:
        {"install": install, "upload": upload, "cleanup": cleanup}[sys.argv[1]]()
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError):
        print("Apple signing/upload failed. Verify the selected app, profile, certificate, team and API-key permissions.")
        raise SystemExit(1)
