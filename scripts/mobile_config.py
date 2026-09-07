#!/usr/bin/env python3
"""Validate public mobile config and prepare flavor-specific native inputs."""
import argparse
import json
import plistlib
import re
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
ROLE = "passenger"
ALLOWED = {
    "ENVIRONMENT", "API_BASE_URL", "SOCKET_BASE_URL", "SOCKET_PATH",
    "STRIPE_PUBLISHABLE_KEY", "MAPBOX_PUBLIC_TOKEN", "AMPLITUDE_API_KEY",
    "SENTRY_DSN", "GOOGLE_MAPS_ANDROID_API_KEY", "GOOGLE_MAPS_IOS_API_KEY",
    "GOOGLE_WEB_CLIENT_ID",
}
if ROLE == "passenger":
    ALLOWED |= {"ADMOB_ANDROID_APP_ID", "ADMOB_IOS_APP_ID",
                "ADMOB_REWARDED_ANDROID_AD_UNIT_ID", "ADMOB_REWARDED_IOS_AD_UNIT_ID"}

class ConfigError(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise ConfigError(message)

def origin(value, deployed):
    require(isinstance(value, str) and value == value.strip(), "Invalid backend origin")
    parsed = urlsplit(value)
    require(parsed.scheme in ("http", "https") and parsed.hostname and
            not parsed.username and not parsed.password and not parsed.query and
            not parsed.fragment and parsed.path in ("", "/"), "Invalid backend origin")
    if deployed:
        require(parsed.scheme == "https" and parsed.hostname != "localhost" and
                parsed.hostname != "::1" and not re.fullmatch(r"[0-9.]+", parsed.hostname),
                "Distributed builds require public HTTPS origins")
    return value.rstrip("/")

def validate(registry, client, environment):
    require(environment in ("local", "demo", "prod"), "Unknown environment")
    require(isinstance(client, dict), "Client configuration must be a JSON object")
    require(not set(client) - ALLOWED, "Unapproved mobile configuration names: " +
            ", ".join(sorted(set(client) - ALLOWED)))
    require(all(isinstance(v, str) and "\n" not in v and "\r" not in v for v in client.values()),
            "Mobile config values must be single-line strings")
    require(client.get("ENVIRONMENT") == environment, "Client ENVIRONMENT must match native flavor")
    entry = registry[environment]
    result = dict(client)
    for key in ("API_BASE_URL", "SOCKET_BASE_URL"):
        expected = entry.get(key, "")
        value = client.get(key) or expected
        origin(value, environment != "local")
        if environment != "local":
            require(value == expected, key + " must match config/environments.json")
            other = registry["prod" if environment == "demo" else "demo"]
            for other_key in ("API_BASE_URL", "SOCKET_BASE_URL"):
                require(origin(value, True) != (other.get(other_key) or "").rstrip("/"),
                        "Demo and production origins must be distinct")
        result[key] = value.rstrip("/")
    project = entry.get("FIREBASE_PROJECT_ID", "")
    require(project, "Register FIREBASE_PROJECT_ID in config/environments.json")
    if environment != "local":
        other = registry["prod" if environment == "demo" else "demo"]
        require(project != other.get("FIREBASE_PROJECT_ID"),
                "Demo and production Firebase projects must be distinct")
    key = result.get("STRIPE_PUBLISHABLE_KEY", "")
    require(key.startswith("pk_live_" if environment == "prod" else "pk_test_"),
            "Provide the environment's Stripe publishable key")
    require(result.get("MAPBOX_PUBLIC_TOKEN", "").startswith("pk."),
            "Provide a public Mapbox token; secret Mapbox tokens are forbidden")
    path = result.get("SOCKET_PATH", "/socket.io/")
    require(path.startswith("/") and "?" not in path and "#" not in path,
            "SOCKET_PATH must be an absolute path")
    result["SOCKET_PATH"] = path
    result["PAYMENT_URL_SCHEME"] = "com.ridzs." + ROLE + ("" if environment == "prod" else "." + environment) + ".payments"
    # Reject secret-shaped values even if placed under an allowed client variable.
    from security_scan import PATTERNS
    require(not any(re.search(pattern, value) for pattern in PATTERNS.values()
                    for value in result.values()), "Private credentials are forbidden in mobile config")
    return result

def check_native_credentials(source):
    from security_scan import PATTERNS
    text = source.read_text()
    require(not any(re.search(pattern, text) for pattern in PATTERNS.values()),
            "Private credentials are forbidden in native Firebase configuration")


def prepare(environment, platform, config_path):
    registry = json.loads((ROOT / "config/environments.json").read_text())
    client = json.loads(config_path.read_text())
    config = validate(registry, client, environment)
    app_id = "com.ridzs." + ROLE + ("" if environment == "prod" else "." + environment)
    maps_key = config.get("GOOGLE_MAPS_" + platform.upper() + "_API_KEY", "")
    require(maps_key.startswith("AIza"), "Provide the platform-restricted Maps client API key")
    if platform == "android":
        source = ROOT / f"android/app/src/{environment}/google-services.json"
        require(source.is_file(), "Missing flavor-specific android google-services.json")
        check_native_credentials(source)
        native = json.loads(source.read_text())
        require(native["project_info"]["project_id"] == registry[environment]["FIREBASE_PROJECT_ID"],
                "Android Firebase project does not match the environment registry")
        matches = [c for c in native["client"]
                   if c["client_info"]["android_client_info"]["package_name"] == app_id]
        require(len(matches) == 1, "Android Firebase package does not match the selected application")
        require(matches[0]["client_info"]["mobilesdk_app_id"], "Missing Firebase Android app ID")
        if ROLE == "passenger":
            require(config.get("ADMOB_ANDROID_APP_ID", "").startswith("ca-app-pub-"),
                    "Provide ADMOB_ANDROID_APP_ID")
    else:
        source = ROOT / f"ios/config/{environment}/GoogleService-Info.plist"
        require(source.is_file(), "Missing flavor-specific iOS GoogleService-Info.plist")
        check_native_credentials(source)
        native = plistlib.loads(source.read_bytes())
        require(native.get("BUNDLE_ID") == app_id, "iOS Firebase bundle ID mismatch")
        require(native.get("PROJECT_ID") == registry[environment]["FIREBASE_PROJECT_ID"],
                "iOS Firebase project does not match the environment registry")
        require(native.get("CLIENT_ID") and native.get("REVERSED_CLIENT_ID"),
                "Enable Google sign-in and download a plist with iOS OAuth client configuration")
        values = {
            "GOOGLE_MAPS_IOS_API_KEY": maps_key,
            "GOOGLE_IOS_CLIENT_ID": native["CLIENT_ID"],
            "GOOGLE_REVERSED_CLIENT_ID": native["REVERSED_CLIENT_ID"],
            "GOOGLE_WEB_CLIENT_ID": config.get("GOOGLE_WEB_CLIENT_ID") or native.get("WEB_CLIENT_ID", ""),
            "PAYMENT_URL_SCHEME": config["PAYMENT_URL_SCHEME"],
        }
        require(values["GOOGLE_WEB_CLIENT_ID"], "Provide GOOGLE_WEB_CLIENT_ID for iOS Google ID token audience")
        if ROLE == "passenger":
            values["ADMOB_IOS_APP_ID"] = config.get("ADMOB_IOS_APP_ID", "")
            require(values["ADMOB_IOS_APP_ID"].startswith("ca-app-pub-"), "Provide ADMOB_IOS_APP_ID")
        require(all(re.fullmatch(r"[A-Za-z0-9_.~-]+", v) for v in values.values()),
                "Unsafe native client configuration format")
        (source.parent / "Client.xcconfig").write_text(
            "// Generated by scripts/mobile_config.py; public client configuration only.\n" +
            "".join(f"{key} = {value}\n" for key, value in values.items()))
    if ROLE == "passenger":
        ad_key = "ADMOB_REWARDED_" + platform.upper() + "_AD_UNIT_ID"
        require(config.get(ad_key, "").startswith("ca-app-pub-"), "Provide " + ad_key)
        if environment == "prod":
            require(all("3940256099942544" not in value for key, value in config.items()
                        if key.startswith("ADMOB_")), "Production must not use AdMob sample IDs")
    destination = ROOT / f".ci/{environment}-defines.json"
    destination.parent.mkdir(exist_ok=True)
    destination.write_text(json.dumps(config, indent=2) + "\n")
    print(f"Prepared {ROLE} {environment} {platform}; public config validated.")
    return config

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--environment", required=True, choices=("local", "demo", "prod"))
    parser.add_argument("--platform", required=True, choices=("android", "ios"))
    parser.add_argument("--client-config", type=Path, required=True)
    args = parser.parse_args()
    try:
        prepare(args.environment, args.platform, args.client_config)
    except ConfigError as error:
        print("Configuration validation failed: " + str(error))
        raise SystemExit(1)
    except (ValueError, KeyError, OSError, TypeError):
        # Never echo JSON input or underlying exception text containing client/secret values.
        print("Configuration validation failed. Check registry, approved client variables, flavor IDs, Firebase files and platform keys.")
        raise SystemExit(1)

if __name__ == "__main__":
    main()
