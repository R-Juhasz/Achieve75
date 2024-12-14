// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart'; // Import Alarm Manager

import '../extras/drawer_menu.dart';
import 'home_screen.dart';
import '../styles/styles.dart'; // Import styles

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
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

  // Reset the challenge progress in SharedPreferences and Firestore
  Future<void> _resetChallenge() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove all saved days' progress
    for (int day = 1; day <= 75; day++) {
      await prefs.remove('day_${day}_completed');
      await prefs.remove('day_${day}_failed');
      await prefs.remove('day_${day}_water_goal');
      await prefs.remove('day_${day}_reading_goal');
      await prefs.remove('day_${day}_diet_goal');
      await prefs.remove('day_${day}_photo_goal');
      await prefs.remove('day_${day}_inside_workout_goal');
      await prefs.remove('day_${day}_outside_workout_goal');
      await prefs.remove('hasShownGoalMessage_day_$day');
    }

    // Reset the start date to now
    final DateTime now = DateTime.now();
    await prefs.setString('startDate', now.toIso8601String());

    // Reset the current day to 1
    await prefs.setInt('currentDay', 1);

    // Clear water intake data
    await _clearWaterIntakeData();

    // Cancel any scheduled alarms
    await _cancelAllAlarms();

    // Optionally, remove alarm-related SharedPreferences keys
    await prefs.remove('alarm_label_1');
    await prefs.remove('alarm_hour_1');
    await prefs.remove('alarm_minute_1');
    await prefs.remove('alarm_label_2');
    await prefs.remove('alarm_hour_2');
    await prefs.remove('alarm_minute_2');

    // Show confirmation to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Challenge has been reset.",
          style: AppTextStyles.body.copyWith(color: AppColors.background),
        ),
        backgroundColor: AppColors.primary,
      ),
    );

    // Navigate to the HomeScreen with reset indicator
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
          (Route<dynamic> route) => false,
    );
  }

  // Function to cancel all scheduled alarms
  Future<void> _cancelAllAlarms() async {
    // Assuming alarm IDs are 1 and 2 for Inside and Outside Workouts
    bool canceled1 = await AndroidAlarmManager.cancel(1);
    bool canceled2 = await AndroidAlarmManager.cancel(2);

;
  }

  // Function to clear water intake data
  Future<void> _clearWaterIntakeData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Handle user not logged in

    final userId = user.uid;
    final CollectionReference waterIntakeCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('waterIntake');

    // Get all documents in the waterIntake collection
    final QuerySnapshot snapshot = await waterIntakeCollection.get();

    // Delete each document
    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Show a confirmation dialog before resetting
  Future<void> _showResetConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            "Reset Challenge",
            style: AppTextStyles.dialogTitle,
          ),
          content: Text(
            "Are you sure you want to reset the challenge? All progress will be lost.",
            style: AppTextStyles.body,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: AppTextStyles.cancelButton,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                "Reset",
                style: AppTextStyles.cancelButton.copyWith(color: AppColors.error),
              ),
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
    // Obtain screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          "Edit Profile",
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
        backgroundColor: AppColors.background,
      ),
      drawer: DrawerMenu(),
      body: GestureDetector(
        // Dismiss keyboard when tapping outside TextField
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          // Ensures the content scrolls if it overflows
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // MainAxisAlignment.spaceBetween ensures spacing between widgets
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Image Section
                GestureDetector(
                  onTap: _pickImage,
                  child: Center(
                    child: CircleAvatar(
                      radius: screenSize.width * 0.2, // Responsive radius
                      backgroundColor: AppColors.primaryDark,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/default_avatar.png') as ImageProvider,
                      child: _profileImage == null
                          ? Icon(
                        Icons.person,
                        color: AppColors.text,
                        size: screenSize.width * 0.2,
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Username TextField
                TextField(
                  controller: _usernameController,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: AppTextStyles.subtitle.copyWith(
                      color: AppColors.primary,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryDark),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Save Profile Button
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: AppButtonStyles.primary.copyWith(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: Text(
                    "Save Profile",
                    style: AppTextStyles.button.copyWith(color: AppColors.background),
                  ),
                ),
                const SizedBox(height: 16),
                // Reset Challenge Button
                ElevatedButton(
                  onPressed: _showResetConfirmationDialog,
                  style: AppButtonStyles.danger.copyWith(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: Text(
                    "Reset Challenge",
                    style: AppTextStyles.button,
                  ),
                ),
                const SizedBox(height: 24),
                // Optional: Add more profile-related widgets here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
