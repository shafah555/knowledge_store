

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
  Admin/           # Admin-specific screens and logic
  pages/           # User-facing pages (home, login, signup, etc.)
  services/        # Firebase, database, and shared preferences services
  widget/          # Reusable widgets
  firebase_options.dart  # Firebase configuration
  main.dart        # App entry point
assets/
  pdf/             # PDF files for eBooks
images/            # Book covers and other images
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

## 📸 Screenshots

<img width="995" height="1274" alt="book1" src="https://github.com/user-attachments/assets/89fbba58-4800-4508-9246-5dc65617a442" />
<img width="988" height="1299" alt="book2" src="https://github.com/user-attachments/assets/8b7d4739-4e45-4801-9f0b-e9f4ac2d25b2" />
<img width="1002" height="1305" alt="book3" src="https://github.com/user-attachments/assets/e6642c4e-8542-4130-bba3-2267172dabc2" />
<img width="1003" height="1297" alt="book4" src="https://github.com/user-attachments/assets/4c2f55e6-0f5c-400a-bc4e-0c51f3334be1" />
<img width="992" height="1293" alt="book5" src="https://github.com/user-attachments/assets/e65d0652-a904-4d8a-9ebf-7e6a9da32ad3" />
<img width="1003" height="1295" alt="book6" src="https://github.com/user-attachments/assets/bca42883-96c9-438a-8d76-d4f60fcd9086" />
<img width="1003" height="1289" alt="book7" src="https://github.com/user-attachments/assets/360460d7-678b-4677-a071-076ebdcecdfb" />
<img width="1004" height="1289" alt="book8" src="https://github.com/user-attachments/assets/ade93344-5f91-4982-8f89-8565217d77c5" />
<img width="1001" height="1292" alt="book9" src="https://github.com/user-attachments/assets/ca8cdd3b-5c99-4605-acbc-e556b85c9fc9" />
<img width="996" height="1295" alt="book91" src="https://github.com/user-attachments/assets/8e531632-aee6-4d4a-8a8b-d843bf2e5d10" />
<img width="1004" height="1294" alt="book92" src="https://github.com/user-attachments/assets/ecf8e90e-b6bd-4fc3-a7a7-d3ebd448b9c2" />
<img width="993" height="1292" alt="book93" src="https://github.com/user-attachments/assets/4c02e8f8-5163-4daf-ad33-e78dc11d2ff2" />
<img width="999" height="1305" alt="book94" src="https://github.com/user-attachments/assets/233e83f2-422e-4ea3-976b-239717a08754" />


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


