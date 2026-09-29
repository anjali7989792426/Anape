
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'dashboard.dart';

class AuthPage extends StatefulWidget {
  final bool isLogin;
  const AuthPage({super.key, this.isLogin = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool isLogin;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
  }

  void handleAuth() async {
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);
    final db = DatabaseHelper.instance;

    if (isLogin) {
      final user = await db.loginUser(emailController.text, passController.text);
      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
  builder: (context) => PremiumDashboard(
    userName: user['name'], 
    userEmail: user['email'], // <--- Ye line add karo
  ),
));
      } else {
        _showError("Invalid Email or Password");
      }
    } else {
      try {
        await db.registerUser(nameController.text, emailController.text, passController.text);
        setState(() => isLogin = true);
        _showError("Registration Successful! Please Login.", isSuccess: true);
      } catch (e) {
        _showError("Email already exists or Database error.");
      }
    }
    setState(() => isLoading = false);
  }

  void _showError(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Screen ki size nikalne ke liye
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500), // Mobile par width limit
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Section
                      _buildHeader(),
                      
                      // Form Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30), // Jitna gap chahiye number badal dena (30, 40, ya 50)
                            Text(
                              isLogin ? "Welcome Back!" : "Join ANAPE AI",
                              style: const TextStyle(
                                fontSize: 26, 
                                fontWeight: FontWeight.bold,
                                
                                color: Color(0xFF2D3436)
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isLogin ? "Log in to continue your training." : "Create an account to start.",
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(height: 30),

                            if (!isLogin) ...[
                              _buildField("Full Name", Icons.person_outline, nameController),
                              const SizedBox(height: 16),
                            ],
                            _buildField("Email Address", Icons.email_outlined, emailController),
                            const SizedBox(height: 16),
                            _buildField("Password", Icons.lock_outline, passController, isPass: true),
                            
                            const SizedBox(height: 32),
                            _buildSubmitButton(),
                            
                            const SizedBox(height: 20),
                            _buildToggleLink(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF6C5CE7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: const [
          Icon(Icons.auto_awesome, color: Colors.white, size: 50),
          SizedBox(height: 12),
          Text(
            "ANAPE AI",
            style: TextStyle(
              fontSize: 32, 
              fontWeight: FontWeight.w900, 
              color: Colors.white,
              letterSpacing: 2
            ),
          ),
          Text(
            "Your Personal Speech Coach",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, TextEditingController ctrl, {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF3F0FF),
        prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7), size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5CE7),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isLoading ? null : handleAuth,
        child: isLoading 
            ? const SizedBox(
                height: 20, 
                width: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              ) 
            : Text(
                isLogin ? "Sign In" : "Get Started", 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
              ),
      ),
    );
  }

  Widget _buildToggleLink() {
    return Center(
      child: TextButton(
        onPressed: () => setState(() => isLogin = !isLogin),
        child: RichText(
          text: TextSpan(
            text: isLogin ? "New user? " : "Already have an account? ",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            children: [
              TextSpan(
                text: isLogin ? "Register Now" : "Login", 
                style: const TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
      ),
    );
  }
}