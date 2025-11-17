import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Home Screen (Navigation will be added here)",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
