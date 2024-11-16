import 'package:achieve75/extras/hard75_slideshow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Displaying the logo in the top half
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/achieve75-high-resolution-logo-transparent.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Title
                    Text(
                      _isLogin ? 'Welcome!' : 'Create an Account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gugi',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email input field
                    TextFormField(
                      controller: _emailController,
                      validator: (value) => _validateEmail(value!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Gugi',
                      ), // Input text color
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email, color: Colors.blue),
                        labelText: 'Email',
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Gugi',
                        ), // Label text color
                        hintText: 'Enter your email',
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Gugi',
                        ), // Hint text color
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Password input field
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) => _validatePassword(value!),
                      obscureText: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Gugi',
                      ), // Input text color
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Gugi',
                        ), // Label text color
                        hintText: 'Enter your password',
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Gugi',
                        ), // Hint text color
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login/Register button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 60,
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          _handleAuth();
                        }
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        _isLogin ? 'Login' : 'Register',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Gugi',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Toggle login/register mode
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? 'Create Account'
                            : 'Have an Account? Login',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontFamily: 'Gugi',
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Forgot Password button
                    TextButton(
                      onPressed: () {
                        // Add functionality to reset password
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontFamily: 'Gugi',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Email validation
  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) return 'Invalid email';
    return null;
  }

  // Password validation
  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // Authentication logic
  Future<void> _handleAuth() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signIn(email, password);
      } else {
        await _authService.register(email, password);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Hard75Slideshow()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Authentication failed: $e',
            style: const TextStyle(fontFamily: 'Gugi'),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
