import 'package:ebooks/widget/support_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail.dart';

class AllBooksPage extends StatelessWidget {
  List<Map<String, dynamic>> get constantBooks => [
    {
      'id': 'constant1',
      'Name': 'The Great Adventure',
      'Author': 'John Smith',
      'Category': 'Fiction',
      'Image': "images/fiction_a.jpeg",
      'AboutAuthor': 'John Smith is a renowned author with over 20 years of experience.',
      'AboutBook': 'An exciting adventure story that takes readers on a journey through mysterious lands.',
      'isConstant': true,
    },
    {
      'id': 'constant2',
      'Name': 'Mystery Manor',
      'Author': 'Sarah Johnson',
      'Category': 'Thriller',
      'Image': "images/kids_a.jpeg",
      'AboutAuthor': 'Sarah Johnson specializes in mystery and thriller novels.',
      'AboutBook': 'A gripping mystery that will keep you guessing until the very end.',
      'isConstant': true,
    },
    {
      'id': 'constant3',
      'Name': 'Poems of Life',
      'Author': 'Michael Brown',
      'Category': 'Poem',
      'Image': "images/poem_a.jpeg",
      'AboutAuthor': 'Michael Brown is a celebrated poet with numerous awards.',
      'AboutBook': 'A collection of beautiful poems that reflect on life and nature.',
      'isConstant': true,
    },
    {
      'id': 'constant4',
      'Name': 'Fun with Friends',
      'Author': 'Emily Davis',
      'Category': 'Kids',
      'Image': "images/thriller_a.jpeg",
      'AboutAuthor': 'Emily Davis writes engaging stories for children.',
      'AboutBook': 'A delightful story about friendship and adventure for young readers.',
      'isConstant': true,
    },
  ];

  const AllBooksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Books'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading books',
                    style: TextStyle(fontSize: 18, color: Colors.red[300]),
                  ),
                ],
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No books found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          
          final books = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final data = books[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (data['Image'] ?? data['image']) != null && (data['Image'] ?? data['image']).toString().isNotEmpty
                          ? ((data['Image'] ?? data['image']).toString().startsWith('http')
                              ? Image.network(
                                  (data['Image'] ?? data['image']),
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
                              child: Icon(
                                Icons.book,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
                  title: Text(
                    data['Name'] ?? 'Unknown Title',
                    style: AppWidget.semiboldTextFeildStyle(),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['Author'] ?? 'Unknown Author'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),

                        child: Text(
                          data['Category'] ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.purple[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetail(bookData: data),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 