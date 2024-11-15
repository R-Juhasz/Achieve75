import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import '../extras/drawer_menu.dart';
import 'bulletin_board_screen.dart';
import 'challenge_screen.dart';
import 'picture_library_screen.dart';
import 'weight_tracker_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _profileImage;
  String _username = "User"; // Default username
  int _currentDay = 1; // Default to day 1

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUsername();
    _loadCurrentDay();
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

  // Load the current day from SharedPreferences
  Future<void> _loadCurrentDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? currentDay = prefs.getInt('currentDay') ?? 1;
    setState(() {
      _currentDay = currentDay;
    });
  }

  // Sign out the user
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Achieve75',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: DrawerMenu(),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Progress bar for 75-Day Challenge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _currentDay / 75,
                    backgroundColor: Colors.grey.shade800,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Day $_currentDay of 75',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Profile section: picture above the username
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                    backgroundColor: Colors.blue,
                    radius: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _username,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
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
      floatingActionButton: Stack(
        children: [
          // Sign Out Button (bottom left)
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              onPressed: _signOut,
              backgroundColor: Colors.red,
              child: const Icon(Icons.logout),
              tooltip: 'Sign Out',
            ),
          ),
          // Profile Button (bottom right)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                ).then((_) {
                  _loadProfileImage();
                  _loadUsername();
                });
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.person),
              tooltip: 'Go to Profile',
            ),
          ),
        ],
      ),
    );
  }
}



