import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../extras/drawer_menu.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
  static const String routeName = '/profile';
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load saved profile information
  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedImagePath = prefs.getString('profileImagePath');

    if (savedUsername != null) {
      _usernameController.text = savedUsername;
    }
    if (savedImagePath != null) {
      setState(() {
        _profileImage = File(savedImagePath);
      });
    }
  }

  // Save profile information and image path locally
  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);

    // Save image path in SharedPreferences
    if (_profileImage != null) {
      await prefs.setString('profileImagePath', _profileImage!.path);
    }

    // Redirect to HomeScreen and reload profile data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  // Pick a profile image from the gallery and save the path
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Reset the challenge progress in SharedPreferences
  Future<void> _resetChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    for (int day = 1; day <= 75; day++) {
      await prefs.remove('day_${day}_completed'); // Remove completion status for each day
    }

    // Reset the current day to 1
    await prefs.setInt('currentDay', 1);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Challenge has been reset.")),
    );

    // Return to the HomeScreen with reset indicator
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  // Show a confirmation dialog before resetting
  Future<void> _showResetConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Challenge"),
          content: const Text(
            "Are you sure you want to reset the challenge? All progress will be lost.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Reset"),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _resetChallenge(); // Perform reset and navigate to HomeScreen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      drawer: DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/default_avatar.png')
                as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Save Profile"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showResetConfirmationDialog,
              child: const Text("Reset Challenge"),
            ),
          ],
        ),
      ),
    );
  }
}

