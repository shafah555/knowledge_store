import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'all_book_list.dart';

class EditBook extends StatefulWidget {
  final String bookId;
  final Map<String, dynamic> bookData;
  const EditBook({Key? key, required this.bookId, required this.bookData}) : super(key: key);

  @override
  State<EditBook> createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  final ImagePicker _picker = ImagePicker();
  dynamic selectedImage; // Can be File (Android) or Uint8List (Web)
  dynamic selectedPdf; // Can be File (Android) or Uint8List (Web)
  String? pdfFileName;
  late TextEditingController _nameController;
  late TextEditingController _authorController;
  late TextEditingController _aboutAuthorController;
  late TextEditingController _aboutBookController;
  late TextEditingController _imageUrlController;
  late TextEditingController _pdfUrlController;
  String? _selectedCategory;
  String? imageUrl;
  String? pdfUrl;
  bool _isUpdating = false;

  final List<String> _categories = ['Fiction', 'Story', 'Poem', 'Kids'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bookData['Name'] ?? '');
    _authorController = TextEditingController(text: widget.bookData['Author'] ?? '');
    _aboutAuthorController = TextEditingController(text: widget.bookData['AboutAuthor'] ?? '');
    _aboutBookController = TextEditingController(text: widget.bookData['AboutBook'] ?? '');
    _selectedCategory = widget.bookData['Category'] ?? _categories.first;
    imageUrl = widget.bookData['Image'];
    pdfUrl = widget.bookData['PdfUrl'];
    pdfFileName = pdfUrl != null ? pdfUrl!.split('/').last : null;
    _imageUrlController = TextEditingController(text: imageUrl ?? '');
    _pdfUrlController = TextEditingController(text: pdfUrl ?? '');
  }

  Future<void> getImage() async {
    try {
      if (kIsWeb) {
        // Web platform - no permissions needed
        print('Picking image on web platform for edit');
        final pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        
        if (pickedImage != null) {
          print('Image picked on web for edit, reading bytes...');
          final bytes = await pickedImage.readAsBytes();
          print('Image bytes read for edit: ${bytes.length} bytes');
          setState(() {
            selectedImage = bytes;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('New image selected: ${pickedImage.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          print('No image selected on web for edit');
        }
      } else {
        // Mobile platform - request permissions
        print('Picking image on mobile platform for edit');
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
            print('Image picked on mobile for edit: ${pickedImage.path}');
            setState(() {
              selectedImage = File(pickedImage.path);
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('New image selected: ${pickedImage.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            print('No image selected on mobile for edit');
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
      print('Error picking image for edit: $e');
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
        print('Picking PDF on web platform for edit');
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        
        if (result != null && result.files.single.bytes != null) {
          print('PDF picked on web for edit: ${result.files.single.name}');
          setState(() {
            selectedPdf = result.files.single.bytes;
            pdfFileName = result.files.single.name;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('New PDF selected: ${result.files.single.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          print('No PDF selected on web for edit');
        }
      } else {
        // Mobile platform
        print('Picking PDF on mobile platform for edit');
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        
        if (result != null && result.files.single.path != null) {
          print('PDF picked on mobile for edit: ${result.files.single.path}');
          setState(() {
            selectedPdf = File(result.files.single.path!);
            pdfFileName = result.files.single.name;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('New PDF selected: ${result.files.single.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          print('No PDF selected on mobile for edit');
        }
      }
    } catch (e) {
      print('Error picking PDF for edit: $e');
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

  Future<void> updateBook() async {
    final name = _nameController.text.trim();
    final author = _authorController.text.trim();
    final aboutAuthor = _aboutAuthorController.text.trim();
    final aboutBook = _aboutBookController.text.trim();
    final imageUrlInput = _imageUrlController.text.trim();
    final pdfUrlInput = _pdfUrlController.text.trim();

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
    if (selectedImage == null && !isValidImageUrl && (imageUrl == null || imageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid image URL or upload an image.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // If neither file nor valid URL is provided for PDF, warn
    if (selectedPdf == null && !isValidPdfUrl && (pdfUrl == null || pdfUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid PDF URL or upload a PDF.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check file sizes only if new files are selected
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
        
        print('New image size: ${(imageSize / 1024 / 1024).toStringAsFixed(2)}MB');
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
        
        print('New PDF size: ${(pdfSize / 1024 / 1024).toStringAsFixed(2)}MB');
      } catch (e) {
        print('Error checking PDF size: $e');
      }
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      print('Starting update process...');
      
      String? newImageUrl = imageUrl;
      String? newPdfUrl = pdfUrl;
      // Use image URL if provided and valid, else upload image
      if (isValidImageUrl) {
        newImageUrl = imageUrlInput;
        print('Using provided image URL: $newImageUrl');
      } else if (selectedImage != null) {
        print('Uploading new image...');
        try {
          final testRef = FirebaseStorage.instance.ref().child('test').child('test.txt');
          await testRef.putString('test').timeout(const Duration(seconds: 5));
          await testRef.delete();
          print('Firebase Storage connection test successful');
        } catch (e) {
          print('Firebase Storage connection test failed: $e');
          throw Exception('Firebase Storage is not accessible. Please check your configuration.');
        }
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('bookImages')
            .child('${widget.bookId}.jpg');
        UploadTask uploadTask;
        if (kIsWeb && selectedImage is Uint8List) {
          print('Uploading new image as data (web) - Size: ${selectedImage.length} bytes');
          uploadTask = ref.putData(selectedImage);
        } else if (selectedImage is File) {
          print('Uploading new image as file (mobile)');
          uploadTask = ref.putFile(selectedImage);
        } else {
          throw Exception('Invalid image format');
        }
        TaskSnapshot snapshot;
        try {
          snapshot = await uploadTask.timeout(
            const Duration(minutes: 2),
            onTimeout: () {
              throw Exception('Image upload timed out. Please check your internet connection.');
            },
          );
        } catch (e) {
          print('Image upload exception: $e');
          throw Exception('Image upload failed: $e');
        }
        newImageUrl = await snapshot.ref.getDownloadURL();
        print('New image uploaded successfully: $newImageUrl');
      } else {
        print('No new image selected, keeping existing image');
      }

      // Upload new PDF only if selected
      if (isValidPdfUrl) {
        newPdfUrl = pdfUrlInput;
        print('Using provided PDF URL: $newPdfUrl');
      } else if (selectedPdf != null) {
        print('Uploading new PDF...');
        Reference pdfRef = FirebaseStorage.instance
            .ref()
            .child('bookPdfs')
            .child('${widget.bookId}.pdf');
        UploadTask pdfUploadTask;
        if (kIsWeb && selectedPdf is Uint8List) {
          print('Uploading new PDF as data (web) - Size: ${selectedPdf.length} bytes');
          pdfUploadTask = pdfRef.putData(selectedPdf);
        } else if (selectedPdf is File) {
          print('Uploading new PDF as file (mobile)');
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
        newPdfUrl = await pdfSnapshot.ref.getDownloadURL();
        print('New PDF uploaded successfully: $newPdfUrl');
      } else {
        print('No new PDF selected, keeping existing PDF');
      }

      // Update book in Firestore
      print('Updating book in Firestore...');
      Map<String, dynamic> updateData = {
        "Name": name,
        "Author": author,
        "AboutAuthor": aboutAuthor,
        "AboutBook": aboutBook,
        "Category": _selectedCategory,
        "updatedAt": DateTime.now().millisecondsSinceEpoch,
        "Image": newImageUrl,
        "PdfUrl": newPdfUrl,
      };

      try {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(widget.bookId)
            .update(updateData)
            .timeout(
              const Duration(minutes: 1),
              onTimeout: () {
                throw Exception('Database operation timed out. Please try again.');
              },
            );
        print('Book updated in Firestore successfully');
      } catch (e) {
        print('Database error: $e');
        throw Exception('Failed to update book data: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Book updated successfully!${selectedImage == null ? ' (Image unchanged)' : ''}${selectedPdf == null ? ' (PDF unchanged)' : ''}'),
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
        Navigator.pop(context);
      }
    } catch (e) {
      print('Update failed with error: $e');
      if (mounted) {
        String errorMessage = 'Update failed: ';
        if (e.toString().contains('timeout')) {
          errorMessage += 'Update timed out. Please check your internet connection and try again.';
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
                updateBook();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
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
        title: const Text('Edit Book'),
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
              'Edit the Book Image (Optional)',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _isUpdating ? null : getImage,
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
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              enabled: !_isUpdating,
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
              enabled: !_isUpdating,
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
              enabled: !_isUpdating,
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
              enabled: !_isUpdating,
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
                    onPressed: _isUpdating ? null : pickPdf,
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
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: _isUpdating ? null : (value) {
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
            const SizedBox(height: 10),
            // New: Image URL TextField
            TextField(
              controller: _imageUrlController,
              enabled: !_isUpdating,
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
              controller: _pdfUrlController,
              enabled: !_isUpdating,
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : updateBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[100],
                  foregroundColor: Colors.purple[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isUpdating
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
                          Text('Updating...', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : const Text('Update Book', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 