

# 📚 eBooks Flutter App

A cross-platform eBook reader application built with Flutter. This app allows users to browse, read, and manage a collection of eBooks, with features for both regular users and administrators.

---

## ✨ Features

### User Features
- **Browse Books:** View all available books by category or as a complete list.
- **Book Details:** See detailed information about each book, including cover image, description, and author.
- **Read eBooks:** Open and read PDF books directly within the app.
- **Favorites:** Mark books as favorites for quick access.
- **User Authentication:** Sign up, log in, and manage your profile.
- **Onboarding:** Smooth onboarding experience for new users.

### Admin Features
- **Admin Login:** Secure admin authentication.
- **Add/Edit/Delete Books:** Add new books or edit/delete existing book details.
- **Book Management:** See a list of all books and perform admin actions.

### Technical Features
- **Firebase Integration:** Uses Firebase for authentication, storage, and database.
- **PDF Viewer:** Integrated PDF viewer for reading eBooks.
- **Persistent Storage:** Uses shared preferences for storing user data locally.
- **Cross-Platform:** Runs on Android, iOS, Web, Windows, macOS, and Linux.

---

## 🗂️ Project Structure

```
lib/
├── Admin/
│   ├── add_book.dart
│   ├── admin_login.dart
│   ├── all_book_list.dart
│   ├── all_order.dart
│   ├── edit_book.dart
│   └── home_admin.dart
├── firebase_options.dart
├── main.dart
├── pages/
│   ├── all_books_page.dart
│   ├── book_detail.dart
│   ├── bottomnav.dart
│   ├── category_books.dart
│   ├── favorite.dart
│   ├── home.dart
│   ├── login.dart
│   ├── onboarding.dart
│   ├── order.dart
│   ├── pdf_viewer.dart
│   ├── profile.dart
│   └── signup.dart
├── services/
│   ├── auth.dart
│   ├── constant.dart
│   ├── database.dart
│   └── shared_pref.dart
└── widget/
    └── support_widget.dart
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Firebase project (with configuration files for Android/iOS/Web)

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-username/ebooks.git
   cd ebooks
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Set up Firebase:**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
   - Update `firebase_options.dart` if needed.

4. **Run the app:**
   ```sh
   flutter run
   ```

---

## 🛠️ Configuration

- **.gitignore** is set up to exclude build artifacts, IDE files, and other non-essential files.
- **Firebase:** Make sure to set up your own Firebase project and update the configuration files.

---

## 📦 Dependencies

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`
- `shared_preferences`
- `flutter_pdfview` or similar for PDF viewing
- (Add any other dependencies you use)

---

## 🤝 Contributing

Contributions are welcome! Please open issues and submit pull requests for improvements or bug fixes.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- Flutter team and community
- Firebase
- Open-source libraries used in this project

---


