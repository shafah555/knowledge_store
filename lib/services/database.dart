import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addBook(Map<String, dynamic> bookData) async {
    try {
      print('Database: Adding book to Firestore...');
      await _firestore.collection("books").add(bookData);
      print('Database: Book added successfully');
    } catch (e) {
      print('Database: Error adding book: $e');
      throw Exception('Failed to add book to database: $e');
    }
  }

  Future<void> addUserDetails(
    Map<String, dynamic> userInfoMap,
    String id,
  ) async {
    try {
      await _firestore.collection("users").doc(id).set(userInfoMap);
    } catch (e) {
      print('Database: Error adding user details: $e');
      throw Exception('Failed to add user details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("books").get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Database: Error getting all books: $e');
      throw Exception('Failed to get books: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBooksByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("books")
          .where("Category", isEqualTo: category)
          .get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Database: Error getting books by category: $e');
      throw Exception('Failed to get books by category: $e');
    }
  }

  // Test method to verify Firebase connection
  Future<bool> testConnection() async {
    try {
      await _firestore.collection("test").doc("test").get();
      return true;
    } catch (e) {
      print('Database: Connection test failed: $e');
      return false;
    }
  }
}
