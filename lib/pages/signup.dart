import 'dart:math';

import 'package:ebooks/pages/bottomnav.dart';
import 'package:ebooks/pages/login.dart';
import 'package:ebooks/services/database.dart';
import 'package:ebooks/services/shared_pref.dart';
import 'package:ebooks/widget/support_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String? name, email, password;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool _obscurePassword = true;

  final _formkey = GlobalKey<FormState>();

  Future<void> registration() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Creating account...'),
              ],
            ),
          );
        },
      );

      // Create user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!, password: password!);

      String uid = userCredential.user!.uid;

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'Name': namecontroller.text,
        'Email': mailcontroller.text,
        'image': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Save to SharedPreferences
      String Id = randomAlphaNumeric(10);
      await SharedPreferenceHelper().saveUserEmail(mailcontroller.text);
      await SharedPreferenceHelper().saveUserId(Id);
      await SharedPreferenceHelper().saveUserName(namecontroller.text);

      // Save to Database
      Map<String, dynamic> userInfoMap = {
        "Name": namecontroller.text,
        "Email": mailcontroller.text,
        "Id": Id,
      };
      await DatabaseMethods().addUserDetails(userInfoMap, Id);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registered Successfully! Welcome ${namecontroller.text}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Bottomnav()),
        );
      }
    } on FirebaseException catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
      
      String errorMessage = "Registration failed";
      if (e.code == 'weak-password') {
        errorMessage = "Password provided too weak. Please use at least 6 characters.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Account already exists with this email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Please enter a valid email address.";
      } else {
        errorMessage = "Registration failed: ${e.message}";
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.blue,
            content: Text(
              errorMessage,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Registration failed: $e",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Image.asset("images/logos.jpg"),
                Text("Sign Up", style: AppWidget.semiboldTextFeildStyle()),
                Text(
                  "Please enter information to continue",
                  style: AppWidget.lightTextFeildStyle(),
                ),
                SizedBox(height: 40),
                Text("User Name", style: AppWidget.semiboldTextFeildStyle()),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFB3E5FC),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      } else {
                        return null;
                      }
                    },
                    controller: namecontroller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "User Name",
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text("Email", style: AppWidget.semiboldTextFeildStyle()),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFB3E5FC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email';
                      } else {
                        return null;
                      }
                    },
                    controller: mailcontroller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Email",
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text("Password", style: AppWidget.semiboldTextFeildStyle()),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFB3E5FC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      } else {
                        return null;
                      }
                    },
                    controller: passwordcontroller,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        setState(() {
                          name = namecontroller.text;
                          email = mailcontroller.text;
                          password = passwordcontroller.text;
                        });
                        await registration();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "           Already have an account?",
                      style: AppWidget.semiboldTextFeildStyle(),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
