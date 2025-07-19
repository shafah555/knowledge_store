import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ebooks/pages/home.dart';
import 'package:ebooks/pages/order.dart';
import 'package:ebooks/pages/profile.dart';
import 'package:ebooks/pages/favorite.dart';
import 'package:flutter/material.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {

  late List<Widget>pages;
  late Home homepage;
  late Order order;
  late Profile profile;
  late Favorite favorite;
  int currentTabIndex=0;

  @override
  void initState() {

    homepage = Home();
    favorite = Favorite();
    profile = Profile();
    pages= [homepage,favorite,profile];
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height:65 ,
          backgroundColor: Colors.white,
          color: Colors.black,
          animationDuration: Duration(milliseconds: 600),
          onTap: (int index){
          setState(() {
            currentTabIndex=index;
          });
          },
          items: [
      Icon(Icons.home_outlined,
        color: Colors.white,),
      Icon(Icons.favorite_border,
      color: Colors.white,),
      Icon(Icons.person_2_outlined,
      color: Colors.white,)
      ]),
      body: pages[currentTabIndex],
    );
  }
}
