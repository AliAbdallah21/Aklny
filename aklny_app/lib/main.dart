// lib/main.dart
// Main entry point for the Aklny Flutter application.

import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import your LoginScreen
// Import other screens if needed for initial navigation or routing setup
import 'utils/token_manager.dart'; // To check for existing tokens on startup
import 'screens/main_app_screen.dart'; // Import HomeScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = const LoginScreen(); // Default to LoginScreen

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check if a token already exists
  }

  // Checks if a JWT token is already present, to navigate directly to home if logged in
  Future<void> _checkLoginStatus() async {
    final token = await TokenManager.getToken();
    if (token != null) {
      // If token exists, user is considered logged in, navigate to HomeScreen
      setState(() {
        _initialScreen = const MainAppScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aklny App',
      theme: ThemeData(
        primarySwatch: Colors.orange, // Define a primary color swatch
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // You can define global text styles here as well
      ),
      debugShowCheckedModeBanner: false, // Hide the debug banner
      home: _initialScreen, // Set the initial screen based on login status
    );
  }
}
