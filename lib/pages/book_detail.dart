import 'package:ebooks/widget/support_widget.dart';
import 'package:flutter/material.dart';
import 'package:ebooks/pages/pdf_viewer.dart';
import 'dart:html' as html;

class BookDetail extends StatefulWidget {
  final Map<String, dynamic>? bookData;

  const BookDetail({super.key, this.bookData});

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  String getDirectDriveLink(String url) {
    final regExp = RegExp(r'd/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return url;
  }

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
    final bookData = widget.bookData;
    
    return Scaffold(
      backgroundColor: const Color(0xFFfef5f1),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_outlined),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 400,
                      width: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: bookData?['Image'] != null && bookData!['Image'].isNotEmpty
                            ? (bookData!['Image'].toString().startsWith('http')
                                ? Image.network(
                                    bookData!['Image'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.book,
                                          size: 100,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    bookData!['Image'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.book,
                                          size: 100,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ))
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.book,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            bookData?['Name'] ?? 'Unknown Title',
                            style: AppWidget.boldTextFeildStyle(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            bookData?['Category'] ?? 'Unknown',
                            style: TextStyle(
                              color: Colors.purple[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "By ${bookData?['Author'] ?? 'Unknown Author'}",
                      style: AppWidget.lightTextFeildStyle(),
                    ),
                    const SizedBox(height: 20),
                    
                    if (bookData?['AboutAuthor'] != null && bookData!['AboutAuthor'].isNotEmpty) ...[
                      Text(
                        "ABOUT THE AUTHOR:",
                        style: AppWidget.semiboldTextFeildStyle(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bookData!['AboutAuthor'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    if (bookData?['AboutBook'] != null && bookData!['AboutBook'].isNotEmpty) ...[
                      Text(
                        "ABOUT THE BOOK:",
                        style: AppWidget.semiboldTextFeildStyle(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bookData!['AboutBook'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE65100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            final rawUrl = bookData?['PdfUrl'] ?? '';
                            if (rawUrl.isNotEmpty) {
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
                                      title: bookData!['Name'] ?? 'Book',
                                      isNetwork: pdfUrl.startsWith('http'),
                                    ),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('PDF not available for this book'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          child: Text(
                            bookData?['PdfUrl'] != null && bookData!['PdfUrl'].isNotEmpty 
                                ? "Read Now" 
                                : "Read Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
