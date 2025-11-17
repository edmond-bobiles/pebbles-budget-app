import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const PebblesApp());
}

class PebblesApp extends StatelessWidget {
  const PebblesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pebbles Budget App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
