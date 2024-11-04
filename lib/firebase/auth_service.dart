import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Sign-in error: ${e.message}");
      return null;
    } catch (e) {
      print("General error: ${e.toString()}");
      return null;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Registration error: ${e.message}");
      return null;
    } catch (e) {
      print("General error: ${e.toString()}");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("User signed out");
    } catch (e) {
      print("Sign-out error: ${e.toString()}");
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent to $email");
    } catch (e) {
      print("Password reset error: ${e.toString()}");
    }
  }
}
