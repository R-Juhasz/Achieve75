import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'bulletin_board_screen.dart';
import 'challenge_screen.dart';
import 'picture_library_screen.dart';
import 'weight_tracker_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart'; // Import your login screen here

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _profileImage;
  String _username = "User"; // Default username

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUsername();
  }

  // Load the profile image from SharedPreferences
  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImagePath');
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  // Load the username from SharedPreferences
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      setState(() {
        _username = username;
      });
    }
  }

  // Sign out the user
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate to login screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '75 Hard Challenge',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ).then((_) {
              _loadProfileImage(); // Reload image after returning from profile screen
              _loadUsername(); // Reload username
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
              backgroundColor: Colors.blue, // Color when no profile image
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _username,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChallengeScreen()),
                );
              },
              child: const Text('View Challenge'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BulletinBoardScreen()),
                );
              },
              child: const Text('Bulletin Board'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PictureLibraryScreen()),
                );
              },
              child: const Text('View Progress Pictures'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeightTrackerScreen()),
                );
              },
              child: const Text('Track Weight'),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          onPressed: _signOut,
          backgroundColor: Colors.red,
          child: const Icon(Icons.logout),
          tooltip: 'Sign Out',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}
