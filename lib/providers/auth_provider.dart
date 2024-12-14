import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  String? get userId => _user?.uid;

  /// Expose the `authStateChanges` stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  MyAuthProvider() {
    // Listen for authentication state changes
    _auth.authStateChanges().listen((User? user) {
      if (_user != user) {
        _user = user;
        notifyListeners(); // Notify listeners of changes
      }
    });
  }

  /// Sign in method
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Register method
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
