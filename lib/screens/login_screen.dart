import 'package:achieve75/extras/hard75_slideshow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _isLogin ? 'Login' : 'Register',
          style: const TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? 'Welcome Back!' : 'Create an Account',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Email input field
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.blue.shade200),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Password input field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.blue.shade200),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login/Register button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 60),
                ),
                onPressed: () async {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  if (_isLogin) {
                    User? user = await _authService.signIn(email, password);
                    if (user != null) {
                      print("User is logged in: ${user.uid}");

                      // Check user authentication state
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        print("User is authenticated, proceeding to Firestore access.");
                        await Future.delayed(const Duration(seconds: 1)); // Ensure complete authentication
                        await testFirestoreAccess();
                      } else {
                        print("User is not authenticated.");
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Hard75Slideshow()),
                      );
                    } else {
                      print("Login Failed");
                    }
                  } else {
                    User? user = await _authService.register(email, password);
                    if (user != null) {
                      print("User registered: ${user.uid}");

                      // Check user authentication state
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        print("User is authenticated, proceeding to Firestore access.");
                        await Future.delayed(const Duration(seconds: 1)); // Ensure complete authentication
                        await testFirestoreAccess();
                      } else {
                        print("User is not authenticated.");
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Hard75Slideshow()),
                      );
                    } else {
                      print("Registration Failed");
                    }
                  }
                },
                child: Text(
                  _isLogin ? 'Login' : 'Register',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to test Firestore access
  Future<void> testFirestoreAccess() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('posts').get();
      if (snapshot.docs.isEmpty) {
        print("No documents found in 'posts' collection.");
      } else {
        for (var doc in snapshot.docs) {
          print("Document data: ${doc.data()}");
        }
      }
    } catch (e) {
      print("Error accessing Firestore: $e");
    }
  }
}
