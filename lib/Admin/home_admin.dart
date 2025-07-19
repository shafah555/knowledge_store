import 'package:flutter/material.dart';
import 'package:ebooks/Admin/add_book.dart';
import 'package:ebooks/Admin/all_order.dart';
import 'package:ebooks/Admin/all_book_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ebooks/services/database.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  bool _isLoading = false;

  Future<void> _testFirebaseConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Testing Firebase connections...');
      
      // Test Firestore connection
      print('Testing Firestore...');
      await FirebaseFirestore.instance.collection('test').doc('test').get();
      print('Firestore connection successful');
      
      // Test Storage connection
      print('Testing Firebase Storage...');
      final storageRef = FirebaseStorage.instance.ref().child('test').child('test.txt');
      await storageRef.putString('test').timeout(const Duration(seconds: 10));
      await storageRef.delete(); // Clean up test file
      print('Firebase Storage connection successful');
      
      // Test Database methods
      print('Testing Database methods...');
      final dbTest = await DatabaseMethods().testConnection();
      if (dbTest) {
        print('Database methods test successful');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All Firebase connections successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Firebase connection test failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase connection failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Test Firebase Connection Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_done),
                label: Text(_isLoading ? 'Testing...' : 'Test Firebase Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[700],
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: _isLoading ? null : _testFirebaseConnection,
              ),
            ),
            const SizedBox(height: 24),
            
            // All Book List Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.menu_book),
                label: const Text('All Book List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllBookList()),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Add Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Book'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddBook()),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // All Orders Button

          ],
        ),
      ),
    );
  }
}
