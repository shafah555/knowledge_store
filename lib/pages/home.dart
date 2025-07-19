import 'package:ebooks/widget/support_widget.dart';
import 'package:ebooks/pages/book_detail.dart';
import 'package:ebooks/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'all_books_page.dart';
import 'package:ebooks/Admin/admin_login.dart';
import 'package:ebooks/pages/signup.dart';
import 'package:ebooks/pages/login.dart';
import 'package:ebooks/pages/category_books.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List categories = [
    "images/fiction.jpeg",
    "images/thriller.jpeg",
    "images/poem.jpeg",
    "images/kids.jpeg",

  ];

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allBooks = [];
  List<Map<String, dynamic>> adminBooks = []; // Books added by admin
  List<Map<String, dynamic>> filteredBooks = [];
  bool isSearching = false;
  bool isLoading = true;

  // Remove the constantBooks list and all references to it
  // List<Map<String, dynamic>> get constantBooks => [...];

  @override
  void initState() {
    super.initState();
    fetchBooks();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh books when returning to this page
    fetchBooks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        filteredBooks = [];
      });
    } else {
      setState(() {
        isSearching = true;
        // Search only in adminBooks
        List<Map<String, dynamic>> allBooksForSearch = [...adminBooks];
        filteredBooks = allBooksForSearch.where((book) {
          final name = (book['Name'] ?? '').toString().toLowerCase();
          final author = (book['Author'] ?? '').toString().toLowerCase();
          final category = (book['Category'] ?? '').toString().toLowerCase();
          return name.contains(query) || 
                 author.contains(query) || 
                 category.contains(query);
        }).toList();
      });
    }
  }

  Future<void> fetchBooks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .orderBy('uploadedAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> fetchedBooks = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      setState(() {
        // Only use adminBooks (books from Firestore)
        allBooks = [];
        adminBooks = fetchedBooks;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching books from Firebase: $e');
      setState(() {
        allBooks = [];
        adminBooks = [];
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading books: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> addBookToCart(String name, String author, String image) async {
    Map<String, dynamic> book = {
      'name': name,
      'author': author,
      'image': image,
    };
    await SharedPreferenceHelper().addToCart(book);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added to Favorite!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddBookDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Books'),
          content: const Text(
            'To add real books to the app, you need to access the admin panel. '
            'Would you like to go to the admin login?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to admin login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLogin()),
                );
              },
              child: const Text('Go to Admin'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final img = book['Image'] ?? book['image'] ?? '';
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(10),
      width: 120, // Fixed width for consistent layout
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetail(bookData: book),
                ),
              );
            },
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: img.isNotEmpty
                    ? (img.toString().startsWith('http')
                        ? Image.network(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.book,
                                  color: Colors.grey[600],
                                  size: 40,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.book,
                                  color: Colors.grey[600],
                                  size: 40,
                                ),
                              );
                            },
                          ))
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.book,
                          color: Colors.grey[600],
                          size: 40,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book['Name'] ?? 'Unknown Title',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            book['Author'] ?? 'Unknown Author',
            style: TextStyle(
              color: Colors.orange[600],
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  book['Category'] ?? 'Unknown',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => addBookToCart(
                  book['Name'] ?? 'Unknown',
                  book['Author'] ?? 'Unknown',
                  book['Image'] ?? '',
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: RefreshIndicator(
        onRefresh: fetchBooks,
        child: Container(
          margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\nWelcome in \n Knowledge Store",
                          style: AppWidget.boldTextFeildStyle(),
                        ),
                        Text(
                          "Happy Reading",
                          style: AppWidget.lightTextFeildStyle(),
                        ),
                        const SizedBox(height: 15),
                        // Navigation buttons
                        Row(

                          children: [

                            Expanded(
                              child: GestureDetector(

                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const Signup()),
                                  );
                                },

                                child: Container(

                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const Login()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      "images/logos.jpg",
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              
              // Get Started Section (only show if no admin books)
              if (adminBooks.isEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[50]!, Colors.purple[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange[600], size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign up to access all features and save your favorite books!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              
              Container(
                padding: const EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search Books by name, author, or category",
                    hintStyle: AppWidget.lightTextFeildStyle(),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              
              // Search Results
              if (isSearching) ...[
                Text(
                  "Search Results (${filteredBooks.length})",
                  style: AppWidget.semiboldTextFeildStyle(),
                ),
                const SizedBox(height: 10),
                if (filteredBooks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No books found for "${searchController.text}"',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (book['Image'] ?? book['image']) != null && (book['Image'] ?? book['image']).toString().isNotEmpty
                                    ? ((book['Image'] ?? book['image']).toString().startsWith('http')
                                        ? Image.network(
                                            (book['Image'] ?? book['image']),
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
                                            (book['Image'] ?? book['image']),
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
                            book['Name'] ?? 'Unknown Title',
                            style: AppWidget.semiboldTextFeildStyle(),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book['Author'] ?? 'Unknown Author'),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  book['Category'] ?? 'Unknown',
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
                                builder: (context) => BookDetail(bookData: book),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ] else ...[
                // Categories Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Categories", style: AppWidget.semiboldTextFeildStyle()),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AllBooksPage()),
                        );
                      },
                      child: Text(
                        "see all",
                        style: TextStyle(
                          color: const Color(0xFFfd6f3e),
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 130,
                  child: Row(
                    children: [
                      Container(
                        height: 130,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(right: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Center(
                          child: Text(
                            "All",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: categories.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            // Map index to category name
                            final categoryNames = ["Fiction", "Thriller", "Poem", "Kids"];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryBooks(
                                      categoryName: categoryNames[index],
                                      categoryImage: categories[index],
                                    ),
                                  ),
                                );
                              },
                              child: CategoryTile(image: categories[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // All Books Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("All Books", style: AppWidget.semiboldTextFeildStyle()),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AllBooksPage()),
                        );
                      },
                      child: Text(
                        "see all",
                        style: TextStyle(
                          color: const Color(0xFFfd6f3e),
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Books List
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (adminBooks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.book_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No books available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: adminBooks.length,
                      itemBuilder: (context, index) {
                        return _buildBookCard(adminBooks[index]);
                      },
                    ),
                  ),
                ],
              ],
  ],
          ),
        ),
      ),
    )
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String image;
  const CategoryTile({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(right: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      height: 90.0,
      width: 146.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(image, height: 50.0, width: 81.0, fit: BoxFit.cover),
          const SizedBox(height: 10.0),
          const Icon(Icons.arrow_forward),
        ],
      ),
    );
  }
}
