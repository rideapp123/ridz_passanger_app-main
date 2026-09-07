#!/usr/bin/env python3
"""Prepare ephemeral CI inputs. Credential contents are never logged."""
import base64
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
def required(name):
    value = os.environ.get(name, "")
    if not value:
        raise ValueError("Missing required CI setting: " + name)
    return value

def decode(name, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(base64.b64decode(required(name), validate=True))
    path.chmod(0o600)

def prepare(platform):
    flavor = required("FLAVOR")
    if flavor not in ("demo", "prod"):
        raise ValueError("Unsupported CI flavor")
    ci = ROOT / ".ci"
    ci.mkdir(exist_ok=True)
    if platform == "firebase":
        native = json.loads((ROOT / "android/app/src/demo/google-services.json").read_text())
        app_id = required("FIREBASE_ANDROID_APP_ID")
        package = "com.ridzs.passenger.demo"
        matches = [c for c in native["client"] if c["client_info"]["android_client_info"]["package_name"] == package]
        if len(matches) != 1 or matches[0]["client_info"]["mobilesdk_app_id"] != app_id:
            raise ValueError("Firebase distribution app ID does not match this demo package")
        account = json.loads(required("FIREBASE_DISTRIBUTION_SERVICE_ACCOUNT_JSON"))
        if account.get("project_id") != native["project_info"]["project_id"]:
            raise ValueError("Firebase distribution service account project mismatch")
        required("FIREBASE_TESTER_GROUPS")
        dest = Path(required("RUNNER_TEMP")) / "ridzs-firebase-distribution.json"
        dest.write_text(json.dumps(account))
        dest.chmod(0o600)
        with open(required("GITHUB_ENV"), "a") as out:
            out.write(f"GOOGLE_APPLICATION_CREDENTIALS={dest}\n")
        return
    client = json.loads(required("MOBILE_CLIENT_CONFIG_JSON"))
    (ci / "client.json").write_text(json.dumps(client))
    base = int(required("BUILD_NUMBER_BASE"))
    attempt = int(required("GITHUB_RUN_ATTEMPT"))
    number = base + int(required("GITHUB_RUN_NUMBER")) * 100 + attempt
    if base < 0 or not 1 <= attempt < 100 or not 0 < number <= 2100000000:
        raise ValueError("Invalid build number allocation")
    with open(required("GITHUB_ENV"), "a") as out:
        out.write(f"BUILD_NUMBER={number}\n")
    if platform == "android":
        decode("ANDROID_KEYSTORE_BASE64", ci / "upload.jks")
        decode("FIREBASE_ANDROID_CONFIG_BASE64", ROOT / f"android/app/src/{flavor}/google-services.json")
    elif platform == "ios":
        decode("FIREBASE_IOS_CONFIG_BASE64", ROOT / f"ios/config/{flavor}/GoogleService-Info.plist")
    else:
        raise ValueError("Unknown CI platform")
    print("Prepared CI inputs; credentials are not included in build artifacts.")

if __name__ == "__main__":
    try:
        prepare(sys.argv[1])
    except (ValueError, KeyError, OSError, IndexError):
        print("CI input validation failed. Check required environment settings and matching application IDs.")
        raise SystemExit(1)
