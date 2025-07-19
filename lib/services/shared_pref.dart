import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferenceHelper {

  static String userIdkey = "USERKEY";
  static String userNamekey = "USERNAMEKEY";
  static String userEmailkey = "USEREMAILKEY";
  static String userImagekey = "USERIMAGEKEY";
  static String cartItemsKey = "CARTITEMSKEY";

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdkey, getUserId);
  }

  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNamekey, getUserName);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailkey, getUserEmail);
  }

  Future<bool> saveUserImage(String getUserImage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userImagekey, getUserImage);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdkey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNamekey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailkey);
  }

  Future<String?> getUserImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userImagekey);
  }

  // Cart methods
  Future<bool> addToCart(Map<String, dynamic> book) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList(cartItemsKey) ?? [];
    
    // Check if book already exists in cart
    for (int i = 0; i < cartItems.length; i++) {
      Map<String, dynamic> existingBook = jsonDecode(cartItems[i]);
      if (existingBook['name'] == book['name']) {
        // Update quantity if book already exists
        existingBook['quantity'] = (existingBook['quantity'] ?? 1) + 1;
        cartItems[i] = jsonEncode(existingBook);
        return prefs.setStringList(cartItemsKey, cartItems);
      }
    }
    
    // Add new book to cart
    book['quantity'] = 1;
    cartItems.add(jsonEncode(book));
    return prefs.setStringList(cartItemsKey, cartItems);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList(cartItemsKey) ?? [];
    return cartItems.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  Future<bool> removeFromCart(String bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList(cartItemsKey) ?? [];
    cartItems.removeWhere((item) {
      Map<String, dynamic> book = jsonDecode(item);
      return book['name'] == bookName;
    });
    return prefs.setStringList(cartItemsKey, cartItems);
  }

  Future<bool> clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(cartItemsKey);
  }
}