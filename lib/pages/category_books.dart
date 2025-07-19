import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebooks/pages/book_detail.dart';
import 'package:ebooks/pages/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class CategoryBooks extends StatelessWidget {
  final String categoryName;
  final String categoryImage;
  const CategoryBooks({
    super.key,
    required this.categoryName,
    required this.categoryImage,
  });

  String getGoogleDrivePdfUrl(String url, {bool forWeb = false}) {
    final driveMatch = RegExp(r'drive\.google\.com\/file\/d\/([^\/]+)').firstMatch(url);
    if (driveMatch != null) {
      final fileId = driveMatch.group(1);
      if (forWeb) {
        return 'https://drive.google.com/file/d/$fileId/preview';
      } else {
        return 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                categoryImage,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('books')
                    .where('Category', isEqualTo: categoryName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading books'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No books found in this category'));
                  }
                  final books = snapshot.data!.docs;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final data = books[index].data() as Map<String, dynamic>;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (data['Image'] ?? data['image']) != null && (data['Image'] ?? data['image']).toString().isNotEmpty
                                    ? ((data['Image'] ?? data['image']).toString().startsWith('http')
                                        ? Image.network(
                                            (data['Image'] ?? data['image']),
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.book,
                                                  color: Colors.grey[600],
                                                ),
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            (data['Image'] ?? data['image']),
                                            height: 300,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.book,
                                                  color: Colors.grey[600],
                                                ),
                                              );
                                            },
                                          ))
                                    : Container(
                                        color: Colors.grey[300],
                                        height: 300,
                                        width: double.infinity,
                                        child: Icon(
                                          Icons.book,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                data['Name'] ?? 'Unknown Title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                data['Author'] ?? '',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              if (data['PdfUrl'] != null && data['PdfUrl'].toString().isNotEmpty)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text('View PDF'),
                                  onPressed: () {
                                    final rawUrl = data['PdfUrl'];
                                    final isWeb = identical(0, 0.0); // kIsWeb alternative
                                    final pdfUrl = getGoogleDrivePdfUrl(rawUrl, forWeb: isWeb);
                                    if (isWeb) {
                                      html.window.open(pdfUrl, '_blank');
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PDFViewerPage(
                                            assetPath: pdfUrl,
                                            title: data['Name'] ?? 'Book',
                                            isNetwork: pdfUrl.startsWith('http'),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookDetail(bookData: data),
                                    ),
                                  );
                                },
                                child: const Text('Details'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
