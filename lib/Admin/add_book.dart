import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'package:ebooks/services/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'all_book_list.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddBook extends StatefulWidget {
  const AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final ImagePicker _picker = ImagePicker();
  dynamic selectedImage; // Can be File (Android) or Uint8List (Web)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _aboutAuthorController = TextEditingController();
  final TextEditingController _aboutBookController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController(); // New
  final TextEditingController _pdfUrlController = TextEditingController(); // New
  dynamic selectedPdf; // Can be File (Android) or Uint8List (Web)
  String? pdfFileName;
  String? _selectedCategory = 'Fiction';
  bool _isUploading = false;

  final List<String> _categories = ['Fiction', 'Story', 'Poem', 'Kids'];

  Future<void> getImage() async {
    try {
      if (kIsWeb) {
        // Web platform - no permissions needed
        print('Picking image on web platform');
        final pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        
        if (pickedImage != null) {
          print('Image picked on web, reading bytes...');
          final bytes = await pickedImage.readAsBytes();
          print('Image bytes read: ${bytes.length} bytes');
          setState(() {
            selectedImage = bytes;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image selected: ${pickedImage.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          print('No image selected on web');
        }
      } else {
        // Mobile platform - request permissions
        print('Picking image on mobile platform');
        var status = await Permission.photos.request();
        if (status.isDenied) {
          print('Permission denied, requesting again...');
          status = await Permission.photos.request();
        }
        
        print('Permission status: $status');
        
        if (status.isGranted) {
          final pickedImage = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );
          
          if (pickedImage != null) {
            print('Image picked on mobile: ${pickedImage.path}');
            setState(() {
              selectedImage = File(pickedImage.path);
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Image selected: ${pickedImage.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            print('No image selected on mobile');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Permission denied to access gallery. Status: $status'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> pickPdf() async {
    try {
      if (kIsWeb) {
        // Web platform
        print('Picking PDF on web platform');
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        
        if (result != null && result.files.single.bytes != null) {
          print('PDF picked on web: ${result.files.single.name}');
          setState(() {
            selectedPdf = result.files.single.bytes;
            pdfFileName = result.files.single.name;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF selected: ${result.files.single.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          print('No PDF selected on web');
        }
      } else {
        // Mobile platform
        print('Picking PDF on mobile platform');
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        
        if (result != null && result.files.single.path != null) {
          print('PDF picked on mobile: ${result.files.single.path}');
          setState(() {
            selectedPdf = File(result.files.single.path!);
            pdfFileName = result.files.single.name;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF selected: ${result.files.single.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          print('No PDF selected on mobile');
        }
      }
    } catch (e) {
      print('Error picking PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Test Firebase Storage connection
  Future<bool> _testFirebaseStorage() async {
    try {
      print('Testing Firebase Storage connection...');
      final testRef = FirebaseStorage.instance.ref().child('test').child('test.txt');
      
      // Try to upload a small test file
      await testRef.putString('test').timeout(const Duration(seconds: 10));
      print('Test upload successful');
      
      // Try to get download URL
      String testUrl = await testRef.getDownloadURL();
      print('Test download URL: $testUrl');
      
      // Clean up test file
      await testRef.delete();
      print('Test file cleaned up');
      
      return true;
    } catch (e) {
      print('Firebase Storage test failed: $e');
      return false;
    }
  }

  Future<void> uploadItem() async {
    final name = _nameController.text.trim();
    final author = _authorController.text.trim();
    final aboutAuthor = _aboutAuthorController.text.trim();
    final aboutBook = _aboutBookController.text.trim();
    final imageUrlInput = _imageUrlController.text.trim(); // New
    final pdfUrlInput = _pdfUrlController.text.trim(); // New

    // Only require text fields, make image and PDF optional
    if (name.isEmpty || author.isEmpty || aboutAuthor.isEmpty || aboutBook.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the required fields (Name, Author, About Author, About Book, and Category)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate image URL if provided
    bool isValidImageUrl = imageUrlInput.isNotEmpty && (imageUrlInput.startsWith('http://') || imageUrlInput.startsWith('https://'));
    // Validate PDF URL if provided
    bool isValidPdfUrl = pdfUrlInput.isNotEmpty && (pdfUrlInput.startsWith('http://') || pdfUrlInput.startsWith('https://'));

    // If neither file nor valid URL is provided for image, warn
    if (selectedImage == null && !isValidImageUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid image URL or upload an image.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // If neither file nor valid URL is provided for PDF, warn
    if (selectedPdf == null && !isValidPdfUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid PDF URL or upload a PDF.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check file sizes only if files are selected
    if (selectedImage != null) {
      try {
        int imageSize = 0;
        if (kIsWeb) {
          if (selectedImage is Uint8List) {
            imageSize = selectedImage.length;
          }
        } else {
          if (selectedImage is File) {
            imageSize = await selectedImage.length();
          }
        }
        // Check image size (max 10MB)
        if (imageSize > 10 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image file is too large. Please select an image smaller than 10MB.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        print('Image size: ${(imageSize / 1024 / 1024).toStringAsFixed(2)}MB');
      } catch (e) {
        print('Error checking image size: $e');
      }
    }
    if (selectedPdf != null) {
      try {
        int pdfSize = 0;
        if (kIsWeb) {
          if (selectedPdf is Uint8List) {
            pdfSize = selectedPdf.length;
          }
        } else {
          if (selectedPdf is File) {
            pdfSize = await selectedPdf.length();
          }
        }
        // Check PDF size (max 50MB)
        if (pdfSize > 50 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF file is too large. Please select a PDF smaller than 50MB.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        print('PDF size: ${(pdfSize / 1024 / 1024).toStringAsFixed(2)}MB');
      } catch (e) {
        print('Error checking PDF size: $e');
      }
    }

    setState(() {
      _isUploading = true;
    });

    try {
      print('Starting upload process...');
      String imageUrl = '';
      String pdfUrl = '';
      // Use image URL if provided and valid, else upload image
      if (selectedImage != null) {
        // For web: selectedImage is Uint8List, for mobile: File
        Uint8List bytes;
        if (kIsWeb && selectedImage is Uint8List) {
          bytes = selectedImage;
        } else if (selectedImage is File) {
          bytes = await selectedImage.readAsBytes();
        } else {
          throw Exception('Invalid image format');
        }
        String? imgurUrl = await uploadImageToImgur(bytes, 'YOUR_IMGUR_CLIENT_ID');
        if (imgurUrl == null) {
          // Show error
          return;
        }
        imageUrl = imgurUrl;
      } else if (isValidImageUrl) {
        imageUrl = imageUrlInput;
      }

      // Use PDF URL if provided and valid, else upload PDF
      if (isValidPdfUrl) {
        pdfUrl = pdfUrlInput;
        print('Using provided PDF URL: $pdfUrl');
      } else if (selectedPdf != null) {
        print('Uploading PDF...');
        String addId = randomAlphaNumeric(10);
        Reference pdfRef = FirebaseStorage.instance
            .ref()
            .child('bookPdfs')
            .child('$addId.pdf');
        UploadTask pdfUploadTask;
        if (kIsWeb && selectedPdf is Uint8List) {
          print('Uploading PDF as data (web) - Size: ${selectedPdf.length} bytes');
          pdfUploadTask = pdfRef.putData(selectedPdf);
        } else if (selectedPdf is File) {
          print('Uploading PDF as file (mobile)');
          pdfUploadTask = pdfRef.putFile(selectedPdf);
        } else {
          throw Exception('Invalid PDF format');
        }
        TaskSnapshot pdfSnapshot;
        try {
          pdfSnapshot = await pdfUploadTask.timeout(
            const Duration(minutes: 5),
            onTimeout: () {
              throw Exception('PDF upload timed out. Please try again.');
            },
          );
        } catch (e) {
          print('PDF upload exception: $e');
          throw Exception('PDF upload failed: $e');
        }
        pdfUrl = await pdfSnapshot.ref.getDownloadURL();
        print('PDF uploaded successfully: $pdfUrl');
      }
      // Add book to Firestore
      print('Adding book to Firestore...');
      Map<String, dynamic> bookData = {
        "Name": name,
        "Author": author,
        "AboutAuthor": aboutAuthor,
        "AboutBook": aboutBook,
        "Category": _selectedCategory,
        "uploadedAt": DateTime.now().millisecondsSinceEpoch,
        "Image": imageUrl,
        "PdfUrl": pdfUrl,
      };
      try {
        await DatabaseMethods().addBook(bookData).timeout(
          const Duration(minutes: 1),
          onTimeout: () {
            throw Exception('Database operation timed out. Please try again.');
          },
        );
        print('Book added to Firestore successfully');
      } catch (e) {
        print('Database error: $e');
        throw Exception('Failed to save book data: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Book added successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View All Books',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AllBookList()),
                );
              },
            ),
          ),
        );
        // Clear form
        _nameController.clear();
        _authorController.clear();
        _aboutAuthorController.clear();
        _aboutBookController.clear();
        _imageUrlController.clear();
        _pdfUrlController.clear();
        setState(() {
          selectedImage = null;
          selectedPdf = null;
          pdfFileName = null;
          _selectedCategory = 'Fiction';
        });
      }
    } catch (e) {
      print('Upload failed with error: $e');
      if (mounted) {
        String errorMessage = 'Upload failed: ';
        if (e.toString().contains('timeout')) {
          errorMessage += 'Upload timed out. Please check your internet connection and try again.';
        } else if (e.toString().contains('permission')) {
          errorMessage += 'Permission denied. Please check your Firebase configuration.';
        } else if (e.toString().contains('network')) {
          errorMessage += 'Network error. Please check your internet connection.';
        } else if (e.toString().contains('Storage')) {
          errorMessage += 'Firebase Storage error. Please check your configuration.';
        } else {
          errorMessage += e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                uploadItem();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (selectedImage == null && (_imageUrlController.text.isEmpty || !_imageUrlController.text.trim().startsWith('http'))) {
      return const Icon(Icons.camera_alt, size: 40, color: Colors.grey);
    }
    if (kIsWeb && selectedImage is Uint8List) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          selectedImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
            );
          },
        ),
      );
    } else if (selectedImage is File) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          selectedImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
            );
          },
        ),
      );
    } else if (_imageUrlController.text.isNotEmpty && _imageUrlController.text.trim().startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          _imageUrlController.text.trim(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
            );
          },
        ),
      );
    }
    return const Icon(Icons.camera_alt, size: 40, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Upload the Book Image (Optional)',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _isUploading ? null : getImage,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 10),
            // New: Image URL TextField
            TextField(
              controller: _imageUrlController,
              enabled: !_isUploading,
              decoration: InputDecoration(
                labelText: 'Image URL (Optional)',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              enabled: !_isUploading,
              decoration: InputDecoration(
                labelText: 'Book Name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _authorController,
              enabled: !_isUploading,
              decoration: InputDecoration(
                labelText: 'Author Name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _aboutAuthorController,
              enabled: !_isUploading,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'About the Author',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _aboutBookController,
              enabled: !_isUploading,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'About the Book',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : pickPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(pdfFileName ?? 'Upload Book PDF (Optional)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // New: PDF URL TextField
            TextField(
              controller: _pdfUrlController,
              enabled: !_isUploading,
              decoration: InputDecoration(
                labelText: 'PDF URL (Optional)',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: _isUploading ? null : (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Book Category',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : () async {
                      bool success = await _testFirebaseStorage();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Firebase Storage test successful!' : 'Firebase Storage test failed. Check console for details.'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Test Firebase Storage'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : uploadItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[100],
                      foregroundColor: Colors.purple[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isUploading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Uploading...', style: TextStyle(fontSize: 16)),
                            ],
                          )
                        : const Text('Add Book', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> uploadImageToImgur(Uint8List imageBytes, String clientId) async {
  final url = Uri.parse('https://api.imgur.com/3/image');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Client-ID $clientId',
    },
    body: {
      'image': base64Encode(imageBytes),
      'type': 'base64',
    },
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data']['link'];
  } else {
    print('Imgur upload failed: ${response.body}');
    return null;
  }
}
