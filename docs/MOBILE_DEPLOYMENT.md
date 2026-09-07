# Ridzs Mobile Deployment

## Repository and Application Identity

This runbook applies to Passenger in `ridz_passanger_app-main`, an independent Git repository.
The backend runs on Azure Container Apps. Mobile apps are compiled and signed;
they are not deployed as web servers.

| Application | Android application ID / iOS bundle ID | Display name |
| --- | --- | --- |
| Driver production | com.ridzs.driver | Ridzs Driver |
| Driver demo | com.ridzs.driver.demo | Ridzs Driver Demo |
| Driver local | com.ridzs.driver.local | Ridzs Driver Local |
| Passenger production | com.ridzs.passenger | Ridzs |
| Passenger demo | com.ridzs.passenger.demo | Ridzs Demo |
| Passenger local | com.ridzs.passenger.local | Ridzs Local |

Production IDs are preserved from the original projects. Registration/ownership in
Google Play, Apple and Firebase still needs confirmation. Never replace an existing
store signing identity. Driver and passenger must have separate app records and CI settings.

## Environments and Public Configuration

1. Install Flutter **3.41.2** (Dart 3.11), Java 17 for Android, Android SDK 36,
   build tools 35.0.0, NDK 27.0.12077973 and Python 3. iOS additionally needs a Mac,
   Xcode 26.2 and CocoaPods. Run `flutter doctor -v`.
2. Edit `config/environments.json`. This reviewed, tracked file is the endpoint
   authority. Fill demo/prod `API_BASE_URL`, `SOCKET_BASE_URL` and
   `FIREBASE_PROJECT_ID` after the real backend and Firebase projects exist.
   Keep the same registry values in both mobile repositories.
3. For the Azure gateway, API and socket URLs are the **same HTTPS origin**.
   Do not append `/driver`, `/passenger` or `/socket.io/`. AppConfig adds the
   role prefix; `SOCKET_PATH` is separately `/socket.io/`.
4. Create ignored `config/demo.json` from `config/client.example.json`.
   Create `config/local.json` and `config/prod.json` the same way, with matching
   `ENVIRONMENT` values. These are public client values, even when stored in CI secrets.
5. Supply the environment's Stripe publishable key, public Mapbox token and
   platform-specific Maps key. Optional analytics values are `AMPLITUDE_API_KEY`
   and `SENTRY_DSN`; empty values disable those integrations.
6. Passenger also needs the Android/iOS AdMob app IDs and rewarded ad unit IDs.
   Demo/local can use the sample IDs in the template. Production rejects sample IDs.
7. For iOS Google sign-in, provide `GOOGLE_WEB_CLIENT_ID` if the downloaded plist
   lacks `WEB_CLIENT_ID`. The iOS client and reversed URL scheme come from that plist.
8. Run the preparation command below. It validates Firebase package/bundle and
   project IDs and writes ignored `.ci/<flavor>-defines.json` and, on iOS,
   `ios/config/<flavor>/Client.xcconfig`.

```bash
python3 scripts/mobile_config.py --environment demo --platform android --client-config config/demo.json
python3 scripts/mobile_config.py --environment demo --platform ios --client-config config/demo.json
```

Unknown client variable names and secret-shaped values fail validation. Compile-time
overrides for demo/prod must exactly match the reviewed registry. Runtime validation
also checks that Flutter's native flavor matches `ENVIRONMENT`, that URLs use HTTPS,
and that demo/prod do not share origins. These checks cannot detect an administrator
incorrectly labeling a real production URL as demo: review the registry against Azure
before approving it. Blank registry values deliberately block distributed builds.

Local uses emulator origins by default. Physical phones need the development machine's
LAN address in `config/local.json`; local may override URLs. Android local permits
HTTP. For iOS local use an HTTPS development tunnel, or a narrowly scoped local ATS
exception reviewed in Xcode. Demo/prod do not enable cleartext traffic.

Legacy `.env.local/.env.qa/.env.prod` files remain ignored as migration references,
but are no longer consumed. Replace `FLUTTER_APP_FLAVOR=develop/production`,
passenger `BACKEND_BASE_URL/SOCKET_URL` and `STRIPE_PK` with the configuration above.
Old Firebase downloads are preserved only under ignored `config/legacy-*` files;
they are not automatically assigned to a new demo application.

## Firebase and Push Setup

1. In [Firebase Console](https://console.firebase.google.com/), create separate demo
   and production projects. Do this manually; no script here creates projects.
2. In each project, register separate Android and iOS apps for driver and passenger
   using the exact IDs in the table. Local requires its own registrations or a
   dedicated development Firebase project. Do not reuse a production Firebase app
   for a `.demo` or `.local` package.
3. Download Android configuration to
   `android/app/src/<flavor>/google-services.json`.
4. Download iOS configuration to
   `ios/config/<flavor>/GoogleService-Info.plist`.
   Firebase initializes from native configuration; there is no shared Dart
   `firebase_options.dart` override.
5. Enable Google sign-in. Add SHA-1/SHA-256 fingerprints for the actual Android signing
   certificate, including the Play app-signing certificate for store releases.
   Download updated Firebase files after changing OAuth configuration.
6. In Apple Developer, enable Push Notifications for each App ID, create profiles
   with that capability and upload an APNs authentication key to the matching
   Firebase project. The apps include push entitlements and remote-notification
   background mode. Driver also retains background location needs.
7. The existing clients obtain an FCM device token and submit it through backend
   authentication APIs. Configure the backend Firebase Admin service account from
   the **same Firebase project** via Azure Key Vault and `FIREBASE_ENABLED=true`.
   Admin JSON never belongs in a mobile JSON/plist, APK, AAB or IPA.
8. Test push on real Android and iOS devices, including foreground, background,
   terminated launch, token refresh and sign-out/sign-in. Local unit tests do not
   establish push delivery. No Crashlytics, Firebase Analytics or Remote Config
   integration was found; existing analytics use Amplitude and error reporting Sentry.

## Maps, Payments and Links

Restrict each Google Maps client key to the appropriate SDK and application.
Android restrictions need the exact package and certificate fingerprint; iOS needs
the bundle ID. Restrictions cannot be verified from source code: check Google Cloud
Console. Use separate Android and iOS keys and review quotas for demo.

Mapbox routing/search uses a public token. Never use a secret Mapbox token.
Stripe initialization uses only `STRIPE_PUBLISHABLE_KEY`; payment intents, setup
intents, subscriptions and sensitive payment operations remain backend API calls.
Demo/local require test publishable keys; prod requires a live publishable key.
Backend Stripe mode must match. Existing failed-adjustment/retry device E2E is still
a required payment acceptance test.

Payment return schemes are derived as `<application-id>.payments`, registered in
Android/iOS and passed to Stripe. Google iOS callbacks use the selected Firebase
reversed client ID. There were no existing associated-domain entitlements or Android
verified app-link routes. HTTPS universal/app links require a real owned domain,
AASA/assetlinks files and route handling; no fictitious domain was introduced.
Exercise 3DS/payment return and Google login on devices before distribution.

## Android Signing

### Prepared Demo Identity

This workspace now has a dedicated, locally generated demo upload identity in
ignored android/demo-signing/. The directory is private (mode 700); its keystore,
credentials and fingerprint files use mode 600. Back it up securely before the
first distribution. It is independent of the other app and any production key.

- upload.jks: demo upload keystore.
- credentials.properties: signing credentials and allowedFlavor=demo.
- fingerprints.json: public SHA-1/SHA-256 fingerprints for Firebase registration.

On a fresh checkout, create a new identity only if this demo app has not already
been distributed. For an existing distributed app, restore its backed-up identity.

```bash
python3 scripts/setup_demo_signing.py
```

The helper refuses to overwrite an existing directory. scripts/build.sh selects
the generated demo properties only when building demo and no explicit signing
input has been supplied. ANDROID_KEY_PROPERTIES can select another reviewed local
properties file relative to android/. Gradle rejects production/local release
builds when a demo-only properties file is selected.

In this workspace, demo signing has passed Gradle validation. Production dry-run
builds using the demo identity were rejected as expected. This does not mean an
APK has been built; Firebase registration and public client configuration remain
pending. config/demo.json is an ignored starter with required values left blank.

For GitHub, use this keystore for ANDROID_KEYSTORE_BASE64 and its matching credentials
for the demo environment's signing secrets. Do not paste these values into chat.

### Production and Manual Signing

Create or locate the correct upload keystore **for this app**. Preserve any existing
registered production key; the ignored passenger `new_keystore.jks` is not proof
that it is the registered key. Verify the certificate in Play Console first.

For a new demo app, run interactively (password prompts stay off command history):

```bash
keytool -genkeypair -v -keystore /secure/path/passenger-demo-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create ignored `android/key.properties` using the safe example:

```properties
storeFile=/absolute/path/to/the-correct-upload.jks
storePassword=REPLACE_LOCALLY
keyAlias=upload
keyPassword=REPLACE_LOCALLY
```

Alternatively set `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS` and `ANDROID_KEY_PASSWORD` in the build process.
Release builds have **no debug-signing fallback**. Debug runs use debug signing.
When switching environments, select the correct environment's keystore.

## Build and Validate

Run from this repository's root:

```bash
bash scripts/validate.sh
bash scripts/build.sh local run config/local.json
bash scripts/build.sh demo apk config/demo.json
bash scripts/build.sh demo appbundle config/demo.json
BUILD_NUMBER=10001 bash scripts/build.sh prod appbundle config/prod.json
bash scripts/build.sh demo ios-run config/demo.json
BUILD_NUMBER=10001 bash scripts/build.sh demo ipa config/demo.json
BUILD_NUMBER=10002 bash scripts/build.sh prod ipa config/prod.json
```

The wrapper prepares public configuration, runs the security scan, Python tests,
`flutter pub get`, `flutter analyze`, and `flutter test` before building. Replace
sample build numbers with numbers above the app's last uploaded build.

Equivalent Flutter commands, after configuration preparation and quality gates:

```bash
flutter run --flavor demo --dart-define-from-file=.ci/demo-defines.json
flutter build apk --release --flavor demo --dart-define-from-file=.ci/demo-defines.json
flutter build appbundle --release --flavor prod --dart-define-from-file=.ci/prod-defines.json --build-number=10001
flutter build ipa --release --flavor demo --dart-define-from-file=.ci/demo-defines.json --build-number=10001 --export-options-plist=ios/ExportOptions.plist
```

Android outputs are `build/app/outputs/flutter-apk/app-demo-release.apk` and
`build/app/outputs/bundle/prodRelease/app-prod-release.aab`; iOS outputs are under
`build/ios/ipa/`. VS Code launch entries expect previously prepared define files.
No backend credentials are passed to Flutter.

## iOS Signing and TestFlight

1. Join the Apple Developer Program and confirm the production bundle IDs belong to
   the account. The old projects contained a development-team setting; the new
   configuration requires the team actually authorized for deployment.
2. Register the demo App ID and create a separate App Store Connect app record.
   Repeat independently for driver and passenger. Enable push as described above.
3. Create an Apple Distribution certificate with its private key; export it as an
   encrypted P12. Create an **App Store** distribution provisioning profile for
   the exact app ID, team and certificate.
4. Create an App Store Connect API key with permission to upload builds. Retain
   its key ID, issuer ID and downloaded private P8 securely.
5. Locally, select your team/certificate/profile in Xcode or use ignored
   `ios/signing.xcconfig`. Prepare `ios/ExportOptions.plist` with
   `method=app-store-connect`, `teamID`, `signingStyle=manual`,
   `signingCertificate=Apple Distribution`,
   `manageAppVersionAndBuildNumber=false` and a `provisioningProfiles` dictionary
   mapping this flavor's bundle ID to its profile UUID.
6. The CI helper validates the profile's bundle, team, distribution type and push
   entitlement, then installs signing material in a temporary keychain. It restores
   the keychain search list and deletes its profile/keychain/private inputs afterward.
7. Upload the IPA via the workflow, Xcode Organizer or Transporter. Wait for build
   processing in App Store Connect, complete export-compliance questions and add
   TestFlight testers. External testers may require beta app review.
8. TestFlight upload does not submit an App Store production release. Submission,
   metadata, privacy disclosures, review and phased release remain manual.

As of April 28, 2026 Apple requires the iOS 26 SDK or later for new uploads; the
workflow selects Xcode 26.2 on a macOS runner. See
[Apple's SDK requirements](https://developer.apple.com/news/?id=ueeok6yw).

## GitHub Environments and CI Settings

Create **demo** and **production** environments in this repository. Add required
reviewers and allowed release refs to production; this is GitHub account setup,
not something YAML can enforce by itself. Protect main and require the quality job.
All build/distribution enable flags start unset, so uploads remain disabled until review.

Repository variables:

| Name | Purpose |
| --- | --- |
| MOBILE_BUILDS_ENABLED | Set true after Android configuration/signing is reviewed |
| IOS_BUILDS_ENABLED | Set true after Apple setup; macOS builds otherwise skip |

Environment variables (configure separately in demo and production):

| Name | Purpose |
| --- | --- |
| BUILD_NUMBER_BASE | Nonnegative reserved offset above historical store build numbers |
| FIREBASE_ANDROID_APP_ID | This app's matching Firebase Android app ID; demo distribution only |
| FIREBASE_TESTER_GROUPS | Existing Firebase tester group aliases |
| APPLE_TEAM_ID | Authorized Apple team |
| DEMO_DISTRIBUTION_ENABLED | Set true in demo only to allow distribution on main pushes |

Environment secrets:

| Name | Used by |
| --- | --- |
| MOBILE_CLIENT_CONFIG_JSON | Approved public client JSON; never backend env JSON |
| FIREBASE_ANDROID_CONFIG_BASE64 | This environment's downloaded google-services.json |
| ANDROID_KEYSTORE_BASE64 | Base64 of this app/environment's upload keystore |
| ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD | Android signing |
| FIREBASE_DISTRIBUTION_SERVICE_ACCOUNT_JSON | Firebase App Distribution CI credential, runner-only |
| FIREBASE_IOS_CONFIG_BASE64 | This environment's downloaded GoogleService-Info.plist |
| APPLE_CERTIFICATE_BASE64, APPLE_CERTIFICATE_PASSWORD | Encrypted signing P12 |
| APPLE_PROVISIONING_PROFILE_BASE64 | App Store provisioning profile |
| APP_STORE_CONNECT_KEY_ID, APP_STORE_CONNECT_ISSUER_ID | Upload API identity |
| APP_STORE_CONNECT_PRIVATE_KEY_BASE64 | Upload API private P8, runner-only |

Grant the distribution service account the Firebase App Distribution Admin role
in the demo project, not general project Owner. Do not reuse backend Firebase Admin
credentials as mobile build configuration. Base64 is encoding, not encryption;
store these inputs only in protected CI secrets.

Android main pushes run quality gates. Signed builds run only when enabled.
Successful demo builds can publish to Firebase when explicitly enabled or when a
manual dispatch sets `distribute=true`. The Android production dispatch creates
signed artifacts only; it never publishes to Play automatically.

iOS uses a separate macOS workflow, with quality gates before signing. It can upload
to TestFlight after explicit enablement. Production requires a manual dispatch and
protected environment approval; there is no automatic App Store release.

## Versioning

Keep the human version in `pubspec.yaml` (`1.0.0+1` initially in both apps).
For example, increase the release name to `1.0.1` when releasing fixes.
CI overrides the build number using:

`BUILD_NUMBER_BASE + github.run_number * 100 + github.run_attempt`

This gives a distinct number for each workflow attempt (attempts 1-99). Android and
iOS have separate store histories; each environment has a different app ID.
Reserve an offset above any existing store builds. Do not reset it, rename workflows
without reallocating it, upload older reruns after newer builds, or reuse example
numbers. Store checks remain the final authority for monotonic versions.

## Google Play Production

1. Create/confirm a separate Play Console app for each production package ID.
2. Enroll in Play App Signing, confirm the registered upload certificate, and complete
   developer verification, app content, privacy/data-safety and permission declarations.
3. Manually dispatch the Android workflow for production after approval.
4. Download the signed production AAB artifact. Upload it to Internal testing first.
5. Verify login, GPS, push, complete ride, payments, driver payout/subscription screens
   and passenger wallet/reward flows on the store-signed build.
6. Complete any account testing requirements, submit for review, then use a controlled
   production rollout. Never promote a `.demo` package as the production app.

## Rollback and Troubleshooting

Mobile rollback normally means rebuilding the last good source with a **higher**
build number and releasing it. You cannot assume testers or store users can install
a lower version over a newer one. Retain signed artifacts and the associated source
SHA; preserve API backward compatibility during backend rollback.

| Symptom | Check |
| --- | --- |
| Config validation fails | Fill registry, correct ENVIRONMENT, approved variable names, per-platform keys and Firebase IDs |
| Google login fails | Package/bundle, SHA fingerprints, OAuth client IDs and iOS reversed callback |
| Maps blank | SDK API enabled, key's package/bundle and signing restrictions |
| Push unavailable | Correct project, APNs key, push profile, backend Admin project and physical-device permission |
| Socket fails while REST works | Gateway active, /socket.io/ forwarding, valid JWT, HTTPS socket origin |
| Release signing fails | Correct keystore path/alias/password; debug fallback was intentionally removed |
| Xcode signing fails | Exact bundle/team/profile/certificate match; Distribution profile includes push |
| Reused build number | Increase reserved offset/build number above the last uploaded build |
| Driver/passenger installs replace each other | Incorrect package/Firebase/signing setup; use the identity table |
| Pipeline skipped | Review setup, then enable repository build flags |
| Dependencies report newer versions | Review separately; this task does not bulk-upgrade packages |

## References

- [Flutter Android flavors](https://docs.flutter.dev/deployment/flavors)
- [Flutter iOS flavors](https://docs.flutter.dev/deployment/flavors-ios)
- [Firebase CLI distribution](https://firebase.google.com/docs/app-distribution/android/distribute-cli)
- [Firebase service-account authentication](https://firebase.google.com/docs/app-distribution/authenticate-service-account)
- [GitHub Apple signing](https://docs.github.com/en/actions/how-tos/deploy/deploy-to-third-party-platforms/sign-xcode-applications)
- [Apple build uploads](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)
