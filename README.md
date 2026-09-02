# 🚗 Ridzs Passenger App

Welcome to the Ridzs Passenger App release repository! 🎉

## 📱 Flutter Version

**Current Flutter Version:** 3.24.1

## 🛠️ How to Run the Ridzs App in Develop Flavor

### Step 1: Install Flutter Version Management (fvm)

Install `fvm`:

```bash
dart pub global activate fvm
# or
pub global activate fvm
macOS users can use Homebrew:

brew tap leoafarias/fvm
brew install fvm
   ```

Verify Installation:

```bash
fvm --version
```

Step 2: Set Up Flutter Version 3.24.1
fvm install 3.24.1

Set the Flutter Version for This Project:

```bash
fvm use 3.24.1 --global
```

Verify Flutter Version:

```bash
fvm flutter --version
```
  
ℹ️ Information

Flavors: develop, production

📥 Installation

Clone the repository:

  ```bash
  git clone https://github.com/anshrajani7/ridzs_passanger_app.git
  ```

Navigate to the project directory:
```bash
cd ridzs_passenger_app
```

Install the required dependencies:
```bash
fvm flutter pub get
fvm dart run build_runner build
```
Run the app:

```bash
fvm flutter run --flavor [flavor_name]
```

🏗️ Build and Release

For Android:

Split APK:
```bash
fvm flutter build apk --split-per-abi --release --flavor [flavor_name]
```

For Android (without shrinking):
```bash
fvm flutter build apk --split-per-abi --no-shrink --flavor develop
```

Single fat APK:
```bash
fvm flutter build apk --release --flavor [flavor_name]
```

For iOS:
```bash
fvm flutter build ios --release --flavor [flavor_name]
```

🧹 Code Sanitization

Ensure all commits have 0 problems:

1.	Check issues:
```bash
        dart fix --dry-run
```
2.	Fix automatically fixable issues:
```bash
        dart analyze . --fatal-warnings
```

3.	Check remaining problems:
```bash
        dart analyze . --fatal-warnings
```

🚀 Script to Ensure Above Checks

To run the checks via terminal:

```bash
$ ./run.sh
```

🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

	1.	Fork the Project
	2.	Create your Feature Branch (git checkout -b feature/amazing_feature)
	3.	Commit your Changes (git commit -m 'Add some AmazingFeature')
	4.	Push to the Branch (git push origin feature/amazing_feature)
	5.	Open a Pull Request

📞 Contact

Ridzs: www.ridzs.com/

🙏 Acknowledgements

This app uses the following awesome open-source libraries:

	•	provider
	•	mobx

👨‍💻 Author

Ansh Rajani
GitHub: [anshrajani7](https://github.com/anshrajani7),
LinkedIn: [Ansh Rajani](https://www.linkedin.com/in/ansh-rajani-2a9bb2239/)

Made with ❤️ by the Ridzs team.

This `README.md` provides all the essential information for running, building, contributing to, and maintaining the Ridzs Passenger App.