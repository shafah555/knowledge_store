import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_book.dart';
import 'package:ebooks/pages/pdf_viewer.dart';

class AllBookList extends StatefulWidget {
  const AllBookList({Key? key}) : super(key: key);

  @override
  State<AllBookList> createState() => _AllBookListState();
}

class _AllBookListState extends State<AllBookList> {
  String getDirectDriveLink(String url) {
    final regExp = RegExp(r'd/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Book List'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').orderBy('uploadedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading books'));
          }
          final books = snapshot.data?.docs ?? [];
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.orange[100],
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.purple, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Total Books: ${books.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: books.isEmpty
                    ? Center(
                  child: Text(
                    'No books found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final data = books[index].data() as Map<String, dynamic>;
                    final docId = books[index].id;
                    final imageUrl = (data['Image'] ?? data['image'] ?? '').toString();
                    final title = data['Name'] ?? 'Unknown';
                    final author = data['Author'] ?? 'Unknown';
                    final category = data['Category'] ?? 'Unknown';
                    final pdfUrl = (data['PdfUrl'] ?? data['pdfUrl'])?.toString() ?? '';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.orange[100]!, width: 1),
                      ),
                      color: Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                                  ? Image.network(
                                imageUrl,
                                width: 60,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.menu_book, color: Colors.grey, size: 32),
                                  );
                                },
                              )
                                  : Container(
                                width: 60,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.menu_book, color: Colors.grey, size: 32),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'By $author',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.purple[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            color: Colors.purple[700],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditBook(bookId: docId, bookData: data),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Book'),
                                        content: const Text('Are you sure you want to delete this book?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await FirebaseFirestore.instance.collection('books').doc(docId).delete();
                                    }
                                  },
                                ),
                                if (pdfUrl.isNotEmpty)
                                  TextButton.icon(
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: const Text('Open PDF'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PDFViewerPage(
                                            assetPath: pdfUrl,
                                            title: title,
                                            isNetwork: pdfUrl.startsWith('http'),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
