# Ebooks App - Build Manual

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Project Setup](#project-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [Development Environment Setup](#development-environment-setup)
5. [Building for Different Platforms](#building-for-different-platforms)
6. [Deployment](#deployment)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- **Flutter SDK**: Version 3.8.1 or higher
- **Dart SDK**: Version 3.8.1 or higher
- **Android Studio**: Latest version with Android SDK
- **Xcode**: Latest version (for iOS builds)
- **Visual Studio**: With C++ development tools (for Windows builds)
- **Git**: For version control

### System Requirements
- **Operating System**: Windows 10/11, macOS 10.15+, or Ubuntu 18.04+
- **RAM**: Minimum 8GB, recommended 16GB
- **Storage**: At least 10GB free space
- **Internet**: Stable connection for dependency downloads

### Flutter Installation
1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract to a desired location (e.g., `C:\flutter` on Windows)
3. Add Flutter to your PATH environment variable
4. Run `flutter doctor` to verify installation
5. Install any missing dependencies reported by `flutter doctor`

---

## Project Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd ebooks
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Verify Project Structure
Ensure the following directories and files exist:
```
ebooks/
├── lib/
│   ├── Admin/
│   ├── pages/
│   ├── services/
│   ├── widget/
│   ├── firebase_options.dart
│   └── main.dart
├── android/
├── ios/
├── web/
├── windows/
├── macos/
├── linux/
├── assets/
│   └── pdf/
├── images/
├── pubspec.yaml
└── README.md
```

### 4. Check Dependencies
The project uses the following key dependencies:
- **syncfusion_flutter_pdfviewer**: ^20.3.47 (PDF viewer)
- **cloud_firestore**: ^5.0.0 (Firebase Firestore)
- **firebase_core**: ^3.6.0 (Firebase core)
- **firebase_auth**: ^5.3.1 (Firebase authentication)
- **firebase_storage**: ^12.4.9 (Firebase storage)
- **shared_preferences**: ^2.3.3 (Local storage)
- **image_picker**: ^1.0.0 (Image selection)
- **file_picker**: ^10.2.0 (File selection)
- **permission_handler**: ^11.0.1 (Permissions)
- **curved_navigation_bar**: ^1.0.6 (Navigation)

---

## Firebase Configuration

### 1. Firebase Project Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing project
3. Enable the following services:
   - **Authentication** (Email/Password)
   - **Firestore Database**
   - **Storage**

### 2. Android Configuration
1. In Firebase Console, add Android app:
   - Package name: `com.example.ebooks`
   - App nickname: "Ebooks App"
2. Download `google-services.json`
3. Place it in `android/app/google-services.json`

### 3. iOS Configuration
1. In Firebase Console, add iOS app:
   - Bundle ID: `com.example.ebooks`
   - App nickname: "Ebooks App"
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Web Configuration
1. In Firebase Console, add Web app
2. Copy the Firebase configuration
3. Update `lib/firebase_options.dart` if needed

### 5. Firebase Security Rules
Configure Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /books/{bookId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Configure Storage security rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /books/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    match /covers/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

---

## Development Environment Setup

### 1. IDE Setup
**Recommended: Android Studio or VS Code**

#### Android Studio:
1. Install Flutter and Dart plugins
2. Configure Flutter SDK path
3. Set up Android emulator or connect physical device

#### VS Code:
1. Install Flutter extension
2. Install Dart extension
3. Configure Flutter SDK path

### 2. Device Setup

#### Android:
1. Enable Developer Options on device
2. Enable USB Debugging
3. Connect device via USB
4. Run `flutter devices` to verify connection

#### iOS:
1. Open project in Xcode
2. Sign in with Apple Developer account
3. Configure signing certificates
4. Set up iOS Simulator or connect physical device

### 3. Environment Variables
Set up environment variables for Firebase:
```bash
# Windows
set FIREBASE_PROJECT_ID=ebook-7e0a5

# macOS/Linux
export FIREBASE_PROJECT_ID=ebook-7e0a5
```

---

## Building for Different Platforms

### 1. Android Build

#### Debug Build:
```bash
flutter build apk --debug
```

#### Release Build:
```bash
flutter build apk --release
```

#### App Bundle (for Play Store):
```bash
flutter build appbundle --release
```

#### Build Configuration:
The Android build uses:
- **compileSdk**: 35
- **minSdk**: 23
- **targetSdk**: 34
- **Java Version**: 11

### 2. iOS Build

#### Debug Build:
```bash
flutter build ios --debug
```

#### Release Build:
```bash
flutter build ios --release
```

#### Archive for App Store:
1. Open project in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Follow App Store submission process

### 3. Web Build

#### Development:
```bash
flutter run -d chrome
```

#### Production Build:
```bash
flutter build web --release
```

#### Deploy to Firebase Hosting:
```bash
firebase init hosting
firebase deploy --only hosting
```

### 4. Windows Build

#### Debug Build:
```bash
flutter build windows --debug
```

#### Release Build:
```bash
flutter build windows --release
```

### 5. macOS Build

#### Debug Build:
```bash
flutter build macos --debug
```

#### Release Build:
```bash
flutter build macos --release
```

### 6. Linux Build

#### Debug Build:
```bash
flutter build linux --debug
```

#### Release Build:
```bash
flutter build linux --release
```

---

## Deployment

### 1. Android Deployment

#### Google Play Store:
1. Create signed APK/Bundle:
   ```bash
   flutter build appbundle --release
   ```
2. Upload to Google Play Console
3. Configure store listing
4. Submit for review

#### Direct APK Distribution:
1. Build APK:
   ```bash
   flutter build apk --release
   ```
2. Distribute APK file directly

### 2. iOS Deployment

#### App Store:
1. Archive in Xcode
2. Upload to App Store Connect
3. Configure app metadata
4. Submit for review

#### TestFlight:
1. Archive in Xcode
2. Upload to TestFlight
3. Invite testers

### 3. Web Deployment

#### Firebase Hosting:
```bash
# Initialize Firebase (if not done)
firebase init hosting

# Build and deploy
flutter build web --release
firebase deploy --only hosting
```

#### Other Hosting Services:
- Netlify
- Vercel
- GitHub Pages

### 4. Desktop Deployment

#### Windows:
- Create installer using tools like Inno Setup
- Distribute executable files

#### macOS:
- Create DMG file
- Notarize for distribution

#### Linux:
- Create AppImage or Snap package
- Distribute through package managers

---

## Troubleshooting

### Common Build Issues

#### 1. Flutter Doctor Issues
```bash
flutter doctor -v
```
Fix any issues reported by Flutter doctor before proceeding.

#### 2. Dependency Issues
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

#### 3. Android Build Issues

**Gradle Issues:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**SDK Issues:**
- Verify Android SDK installation
- Check SDK versions in `android/app/build.gradle.kts`
- Update Android Studio and SDK tools

#### 4. iOS Build Issues

**CocoaPods Issues:**
```bash
cd ios
pod install
cd ..
```

**Signing Issues:**
- Verify Apple Developer account
- Check signing certificates in Xcode
- Update provisioning profiles

#### 5. Firebase Issues

**Configuration Issues:**
- Verify `google-services.json` placement
- Check Firebase project settings
- Ensure all required services are enabled

**Permission Issues:**
- Check Firebase security rules
- Verify authentication setup
- Test with Firebase console

#### 6. PDF Viewer Issues

**Syncfusion License:**
- Ensure valid Syncfusion license
- Check license key configuration
- Contact Syncfusion support if needed

### Performance Optimization

#### 1. Build Optimization
```bash
# Enable build optimization
flutter build apk --release --split-per-abi
flutter build appbundle --release --target-platform android-arm64
```

#### 2. Asset Optimization
- Compress images before adding to assets
- Use appropriate image formats (WebP for web)
- Optimize PDF files for mobile viewing

#### 3. Code Optimization
- Enable tree shaking
- Use const constructors where possible
- Implement proper state management

### Testing

#### 1. Unit Tests
```bash
flutter test
```

#### 2. Integration Tests
```bash
flutter test integration_test/
```

#### 3. Widget Tests
```bash
flutter test test/widget_test.dart
```

---

## Maintenance

### 1. Regular Updates
- Keep Flutter SDK updated
- Update dependencies regularly
- Monitor for security updates

### 2. Backup Strategy
- Regular code backups
- Firebase data backups
- Configuration backups

### 3. Monitoring
- Firebase Analytics
- Crash reporting
- Performance monitoring

---

## Support and Resources

### Official Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Syncfusion Documentation](https://help.syncfusion.com/)

### Community Resources
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [GitHub Issues](https://github.com/flutter/flutter/issues)

### Contact Information
- **Development Team**: [Team Contact]
- **Firebase Support**: [Firebase Support]
- **Syncfusion Support**: [Syncfusion Support]

---

*This build manual covers the essential steps for building and deploying the Ebooks App. For specific issues or advanced configurations, refer to the official documentation or contact the development team.*

**Last Updated**: December 2024
**Version**: 1.0.0 