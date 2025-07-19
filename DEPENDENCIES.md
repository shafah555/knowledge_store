Based on the `pubspec.yaml` file, here are the complete dependencies for your Flutter ebooks project:

## Project Dependencies

### **Core Flutter Dependencies**
```yaml
flutter:
  sdk: flutter
```

### **Firebase Dependencies**
```yaml
cloud_firestore: ^5.0.0          # Cloud Firestore database
firebase_core: ^3.6.0            # Firebase core functionality
firebase_auth: ^5.3.1            # Firebase authentication
firebase_storage: ^12.4.9        # Firebase cloud storage
```

### **PDF and File Handling**
```yaml
syncfusion_flutter_pdfviewer: ^20.3.47  # PDF viewer component
file_picker: ^10.2.0                    # File picking functionality
image_picker: ^1.0.0                    # Image picking from gallery/camera
```

### **UI and Navigation**
```yaml
curved_navigation_bar: ^1.0.6    # Curved bottom navigation bar
cupertino_icons: ^1.0.8          # iOS-style icons
```

### **Data and Storage**
```yaml
shared_preferences: ^2.3.3       # Local data storage
random_string: ^2.3.1            # Generate random strings
```

### **Network and Permissions**
```yaml
http: ^0.13.6                    # HTTP requests
permission_handler: ^11.0.1      # Handle app permissions
```

### **Development Dependencies**
```yaml
flutter_test:
  sdk: flutter
flutter_lints: ^6.0.0            # Code linting rules
```

## **Dependency Categories and Purposes**

### **Backend Services (Firebase)**
- **cloud_firestore**: Database for storing book information, user data, and orders
- **firebase_core**: Core Firebase functionality and initialization
- **firebase_auth**: User authentication (login/signup)
- **firebase_storage**: Store and retrieve PDF files and images

### **File Management**
- **syncfusion_flutter_pdfviewer**: Display PDF books within the app
- **file_picker**: Allow users to select PDF files for upload
- **image_picker**: Select book cover images from device gallery

### **User Interface**
- **curved_navigation_bar**: Modern curved bottom navigation with animations
- **cupertino_icons**: iOS-style icons for cross-platform consistency

### **Local Storage**
- **shared_preferences**: Store user preferences, favorites, and session data
- **random_string**: Generate unique IDs for books and users

### **System Integration**
- **http**: Make HTTP requests for external API calls
- **permission_handler**: Request and manage device permissions (camera, storage, etc.)

## **Version Information**
- **Flutter SDK**: ^3.8.1
- **App Version**: 1.0.0+1
- **Target Platforms**: Android, iOS, Web, Windows, Linux, macOS

## **Asset Dependencies**
```yaml
assets:
  - images/          # Book cover images and UI graphics
  - assets/pdf/      # PDF book files
```

## **Installation Commands**

To install all dependencies, run:
```bash
flutter pub get
```

To upgrade dependencies to latest versions:
```bash
flutter pub upgrade
```

To check for outdated dependencies:
```bash
flutter pub outdated
```

## **Key Features Enabled by Dependencies**

1. **PDF Reading**: `syncfusion_flutter_pdfviewer` provides full PDF viewing capabilities
2. **Cloud Storage**: `firebase_storage` enables storing and retrieving large PDF files
3. **User Authentication**: `firebase_auth` handles secure user login/signup
4. **Real-time Database**: `cloud_firestore` provides real-time data synchronization
5. **File Upload**: `file_picker` and `image_picker` enable admin book uploads
6. **Local Caching**: `shared_preferences` stores user favorites and settings
7. **Modern UI**: `curved_navigation_bar` provides smooth navigation experience

This dependency structure creates a robust, scalable ebooks application with cloud storage, real-time synchronization, and modern user interface components.
