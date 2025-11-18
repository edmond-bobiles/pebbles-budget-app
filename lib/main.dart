import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const PebblesApp());
}

class PebblesApp extends StatelessWidget {
  const PebblesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pebbles Budget App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
