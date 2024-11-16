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
  String _username = "User";
  int _currentDay = 1;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUsername();
    _loadCurrentDay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCurrentDay();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImagePath');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    } else {
      prefs.remove('profileImagePath');
      setState(() {
        _profileImage = null;
      });
    }
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      setState(() {
        _username = username;
      });
    }
  }

  Future<void> _loadCurrentDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? currentDay = prefs.getInt('currentDay') ?? 1;
    setState(() {
      _currentDay = currentDay;
    });
  }

  Future<void> _signOut() async {
    bool? confirmSignOut = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Sign Out',
            style: TextStyle(fontFamily: 'Gugi'),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(fontFamily: 'Gugi'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Gugi'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontFamily: 'Gugi'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmSignOut == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Hamburger icon in white
        title: Image.asset(
          'assets/images/achieve75-high-resolution-logo-transparent.png',
          height: 40,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Welcome back, $_username!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Gugi',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
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
                    _currentDay >= 75
                        ? 'Challenge Complete!'
                        : 'Day $_currentDay of 75',
                    style: TextStyle(
                      color: _currentDay >= 75 ? Colors.green : Colors.white,
                      fontSize: 18,
                      fontFamily: 'Gugi',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                border: Border.all(color: Colors.blue, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, color: Colors.white, size: 40)
                        : null,
                    backgroundColor: Colors.blue,
                    radius: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Gugi',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            _buildModernButton(
              context,
              label: 'View Challenge',
              icon: Icons.flag,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChallengeScreen()),
                ).then((_) => _loadCurrentDay());
              },
            ),
            const SizedBox(height: 20),
            _buildModernButton(
              context,
              label: 'Bulletin Board',
              icon: Icons.message,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BulletinBoardScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildModernButton(
              context,
              label: 'View Progress Pictures',
              icon: Icons.photo_library,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PictureLibraryScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildModernButton(
              context,
              label: 'Track Weight',
              icon: Icons.monitor_weight,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WeightTrackerScreen()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'signOutButton',
              onPressed: _signOut,
              backgroundColor: Colors.red,
              child: const Icon(Icons.logout),
              tooltip: 'Sign Out',
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'profileButton',
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

  Widget _buildModernButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        minimumSize: const Size(200, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Modern rounded corners
        ),
        side: const BorderSide(color: Colors.white, width: 1), // Thin white border
        elevation: 4, // Subtle shadow for depth
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontFamily: 'Gugi'),
      ),
    );
  }
}
