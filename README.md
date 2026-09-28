# 🚀 Pashudhan QR App

A Flutter-based mobile application designed to streamline communication and operations between instructors, associate partners, and users.

---

## 📱 Features

- 🔐 OTP-based Authentication
- 👤 Role-based Access (Admin / Associate Partner / User)
- 📊 Clean and Responsive UI
- 🔄 API Integration with Backend Services
- 🔑 Secure Token Storage using Flutter Secure Storage

---

## 🛠️ Tech Stack

- **Frontend:** Flutter, Dart
- **Architecture:** MVVM (Stacked Architecture)
- **State Management:** Stacked
- **Networking:** Dio
- **Backend:** REST APIs (Swagger integrated)



# Build Commands
```sh
flutter pub get
flutter pub outdated
flutter pub upgrade
flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk --debug
flutter run -d {device}
```

---

## Release Bundle (Play Store)

### 1. Bump the version

In `pubspec.yaml`, increment the build number before every release:

```
version: 1.0.1+4   →   version: 1.0.1+5
```

Format: `<semver>+<build-number>`
- Increment `+N` for every upload to Play Store (even internal testing).
- Bump the semver (`1.0.1` → `1.0.2` etc.) for user-visible releases.

### 2. Build the release AAB

```sh
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 3. Upload to Play Store

Upload `app-release.aab` via the [Google Play Console](https://play.google.com/console) to the appropriate track (Internal → Closed Testing → Production).