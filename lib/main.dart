import 'package:flutter/material.dart';
import 'screens/auth_page.dart'; // Humara banaya hua Auth Page

void main() {
  runApp(const AnapeApp());
}

class AnapeApp extends StatelessWidget {
  const AnapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANAPE AI',
      debugShowCheckedModeBanner: false, // Debug banner hatane ke liye
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
        useMaterial3: true,
      ),
      // App shuru hote hi AuthPage dikhayega
      home: const AuthPage(isLogin: true), 
    );
  }
}