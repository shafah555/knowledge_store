import 'package:flutter/material.dart';
import 'package:ebooks/pages/signup.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffecefe8),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 50.0, left:20.0,right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Image.asset("images/welcome.png"),
         Padding(
             padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            "Explore The Best Books",
            style: TextStyle(color: Colors.black,fontSize: 30.0,
                fontWeight: FontWeight.bold),)
      ),
            SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Signup()),
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: 20.0),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.black),
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.yellow,fontSize: 30.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
      ],
    ),
      ],
    ),
      ),
      )
    );
  }
}
