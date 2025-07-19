import 'package:flutter/material.dart';

class AllOrder extends StatelessWidget {
  const AllOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('All orders will be listed here.'),
      ),
    );
  }
} 