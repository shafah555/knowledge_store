import 'package:flutter/material.dart';
import 'package:ebooks/services/shared_pref.dart';
import 'package:ebooks/widget/support_widget.dart';
import 'package:ebooks/pages/pdf_viewer.dart';
import 'dart:html' as html;

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  List<Map<String, dynamic>> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteItems();
  }

  Future<void> loadFavoriteItems() async {
    List<Map<String, dynamic>> items = await SharedPreferenceHelper().getCartItems();
    setState(() {
      favoriteItems = items;
    });
  }

  Future<void> removeFromFavorite(String bookName) async {
    await SharedPreferenceHelper().removeFromCart(bookName);
    loadFavoriteItems();
  }

  Future<void> clearFavorite() async {
    await SharedPreferenceHelper().clearCart();
    loadFavoriteItems();
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFFfef5f1),
      appBar: AppBar(
        title: Text('My Favorite', style: AppWidget.boldTextFeildStyle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (favoriteItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear favorite'),
                    content: const Text('Are you sure you want to clear all favorite books?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          clearFavorite();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: favoriteItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your favorite list is empty',
                    style: AppWidget.semiboldTextFeildStyle(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add some books to get started!',
                    style: AppWidget.lightTextFeildStyle(),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                var item = favoriteItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ((item['Image'] ?? item['image']) != null && (item['Image'] ?? item['image']).toString().startsWith('http'))
                            ? Image.network(
                                (item['Image'] ?? item['image']),
                                width: 80,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(Icons.book, color: Colors.grey[600]),
                                  );
                                },
                              )
                            : Image.asset(
                                (item['Image'] ?? item['image']) ?? 'images/fiction_a.jpeg',
                                width: 80,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(Icons.book, color: Colors.grey[600]),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? 'Unknown Book',
                              style: AppWidget.semiboldTextFeildStyle(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['author'] ?? '',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                           if ((item['PdfUrl'] ?? item['pdfUrl']) != null && (item['PdfUrl'] ?? item['pdfUrl']).toString().isNotEmpty)
                             TextButton.icon(
                               icon: const Icon(Icons.picture_as_pdf),
                               label: const Text('Open PDF'),
                               onPressed: () {
                                 final rawUrl = (item['PdfUrl'] ?? item['pdfUrl']) ?? '';
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
                                         title: item['name'] ?? 'Book',
                                         isNetwork: pdfUrl.toString().startsWith('http'),
                                       ),
                                     ),
                                   );
                                 }
                               },
                             ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeFromFavorite(item['name']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
