import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebooks/widget/support_widget.dart';
import 'package:flutter/material.dart';
import 'package:ebooks/Admin/home_admin.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Image.asset("images/logos.jpg"),
              Text("Admin Panel", style: AppWidget.semiboldTextFeildStyle()),

              Text("User Name", style: AppWidget.semiboldTextFeildStyle()),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  color: Color(0xFFB3E5FC),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: TextFormField(
                  controller: usernamecontroller,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "User Name",
                  ),
                ),
              ),

              SizedBox(height: 40),
              Text(
                " Admin Password",
                style: AppWidget.semiboldTextFeildStyle(),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  color: Color(0xFFB3E5FC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: userpasswordcontroller,
                  enabled: !_isLoading,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Password",
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _isLoading ? null : () {
                  LoginAdmin();
                },
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.blue),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Log In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void LoginAdmin() async {
    final username = usernamecontroller.text.trim();
    final password = userpasswordcontroller.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Please enter both username and password",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Admin")
          .where('username', isEqualTo: username)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Invalid username or password",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        final adminData = snapshot.docs.first.data() as Map<String, dynamic>;
        if (adminData['password'] == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeAdmin()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                "Invalid username or password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Login failed: $e",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
