import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? errorMessage;

  final String correctUser = "budget";
  final String correctPass = "pebbles";

  void attemptLogin() {
    final user = _usernameController.text.trim();
    final pass = _passwordController.text.trim();

    if (user == correctUser && pass == correctPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        errorMessage = "Incorrect username or password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Budget App"),

            const SizedBox(height: 20),

            // Username
            SizedBox(
              width: 250,
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Password
            SizedBox(
              width: 250,
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
                obscureText: true,
              ),
            ),

            const SizedBox(height: 10),

            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: attemptLogin,
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
