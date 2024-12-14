import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in method
  Future<User?> signIn(String email, String password) async {
    try {
      // Attempt to sign in with provided email and password
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        print("Sign-in successful: ${result.user!.email}");
        return result.user;
      } else {
        print("Sign-in failed: User not found");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("Sign-in error: ${e.message}");
      return null;
    } catch (e) {
      print("General error: ${e.toString()}");
      return null;
    }
  }

  // Register method
  Future<User?> register(String email, String password) async {
    try {
      // Attempt to create a new user with the provided email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        print("Registration successful: ${result.user!.email}");
        return result.user;
      } else {
        print("Registration failed: User not created");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("Registration error: ${e.message}");
      return null;
    } catch (e) {
      print("General error: ${e.toString()}");
      return null;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("User signed out");
    } catch (e) {
      print("Sign-out error: ${e.toString()}");
    }
  }

  // Password reset method
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent to $email");
    } catch (e) {
      print("Password reset error: ${e.toString()}");
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }
}
