// lib/screens/login_screen.dart

import 'package:achieve75/extras/hard75_slideshow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ensure Provider is imported
import '../providers/auth_provider.dart';
import '../styles/styles.dart'; // Import styles

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      border: Border.all(color: AppColors.primary, width: 4),
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
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 20),

                    // Email input field
                    TextFormField(
                      controller: _emailController,
                      validator: (value) => _validateEmail(value!),
                      style: AppTextStyles.body, // Input text color
                      decoration: AppInputDecorations.email.copyWith(
                        hintText: 'Enter your email',
                        hintStyle: AppTextStyles.hint,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Password input field
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) => _validatePassword(value!),
                      obscureText: true,
                      style: AppTextStyles.body, // Input text color
                      decoration: AppInputDecorations.password.copyWith(
                        hintText: 'Enter your password',
                        hintStyle: AppTextStyles.hint,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login/Register button
                    ElevatedButton(
                      style: AppButtonStyles.primary,
                      onPressed: _isLoading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          _handleAuth();
                        }
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        color: AppColors.text,
                      )
                          : Text(
                        _isLogin ? 'Login' : 'Register',
                        style: AppTextStyles.button,
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
                        _isLogin ? 'Create Account' : 'Have an Account? Login',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Forgot Password button
                    TextButton(
                      onPressed: () {
                        // Add functionality to reset password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 14,
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
      final authProvider = Provider.of<MyAuthProvider>(context, listen: false);

      if (_isLogin) {
        await authProvider.signIn(email, password);
      } else {
        await authProvider.register(email, password);
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
            style: AppTextStyles.body,
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
