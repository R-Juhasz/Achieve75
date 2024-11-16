// home_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../extras/progress_section.dart';
import '../utils/progress_utils.dart';
import '../utils/shared_preferences_helper.dart';
import '../extras/drawer_menu.dart';
import 'bulletin_board_screen.dart';
import 'challenge_screen.dart';
import 'picture_library_screen.dart';
import 'weight_tracker_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});
  static const String routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _profileImage;
  String _username = "User";
  int _currentDay = 1;
  int _daysCompleted = 0;
  int _daysFailed = 0;
  DateTime _currentDate = DateTime.now();
  double? _currentWeight;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Combined loading methods into one for better readability and maintainability
  void _loadProfileData() {
    _loadProfileImage();
    _loadUsername();
    _loadCurrentDay();
    _calculateProgress();
    _loadCurrentWeight();
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferencesHelper.prefs;
      String? imagePath = prefs.getString('profileImagePath');
      if (imagePath != null && File(imagePath).existsSync()) {
        if (!mounted) return;
        setState(() {
          _profileImage = File(imagePath);
        });
      } else {
        prefs.remove('profileImagePath');
        if (!mounted) return;
        setState(() {
          _profileImage = null;
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
      // Optionally, show an error message to the user
    }
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await SharedPreferencesHelper.prefs;
      String? username = prefs.getString('username');
      if (username != null) {
        if (!mounted) return;
        setState(() {
          _username = username;
        });
      }
    } catch (e) {
      print('Error loading username: $e');
    }
  }

  Future<void> _loadCurrentDay() async {
    try {
      final prefs = await SharedPreferencesHelper.prefs;
      int currentDay = prefs.getInt('currentDay') ?? 1;
      if (!mounted) return;
      setState(() {
        _currentDay = currentDay;
      });
    } catch (e) {
      print('Error loading current day: $e');
    }
  }

  Future<void> _calculateProgress() async {
    try {
      Map<String, dynamic> progressData =
      await ProgressUtils.calculateProgress(_currentDay);
      if (!mounted) return;
      setState(() {
        _daysCompleted = progressData['daysCompleted'];
        _daysFailed = progressData['daysFailed'];
        _currentDate = DateTime.now();
      });
    } catch (e) {
      print('Error calculating progress: $e');
    }
  }

  Future<void> _loadCurrentWeight() async {
    try {
      final prefs = await SharedPreferencesHelper.prefs;
      final savedWeights = prefs.getStringList('weights') ?? [];
      if (savedWeights.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _currentWeight = double.parse(savedWeights.last);
        });
      } else {
        if (!mounted) return;
        setState(() {
          _currentWeight = null;
        });
      }
    } catch (e) {
      print('Error loading current weight: $e');
    }
  }

  // Note: Removed the _signOut() method since it's now in the drawer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Image.asset(
          'assets/images/achieve75-high-resolution-logo-transparent.png',
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: DrawerMenu(), // DrawerMenu now handles Sign Out
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: constraints.maxHeight > 600
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    // Adjusted ProgressSection
                    ProgressSection(
                      currentDay: _currentDay,
                      daysCompleted: _daysCompleted,
                      daysFailed: _daysFailed,
                      currentDate: _currentDate,
                    ),
                    const SizedBox(height: 10),
                    // Modernized profile section
                    _buildProfileSection(),
                    const SizedBox(height: 10),
                    // Buttons
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModernButton(
                            context,
                            label: 'View Challenge',
                            icon: Icons.flag,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const ChallengeScreen()),
                              ).then((_) {
                                _loadCurrentDay();
                                _calculateProgress();
                              });
                            },
                          ),
                          _buildModernButton(
                            context,
                            label: 'Bulletin Board',
                            icon: Icons.message,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BulletinBoardScreen()),
                              );
                            },
                          ),
                          _buildModernButton(
                            context,
                            label: 'View Progress Pictures',
                            icon: Icons.photo_library,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const PictureLibraryScreen()),
                              );
                            },
                          ),
                          _buildModernButton(
                            context,
                            label: 'Track Weight',
                            icon: Icons.monitor_weight,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const WeightTrackerScreen()),
                              ).then((_) {
                                _loadCurrentWeight(); // Reload current weight
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Removed floatingActionButton
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            // Navigate to profile screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ).then((_) {
              _loadProfileData(); // Reload all profile data
            });
          },
          child: Stack(
            children: [
              // Background Gradient
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                        semanticLabel: 'Profile Picture',
                      )
                          : null,
                      backgroundColor: Colors.transparent,
                      radius: 40,
                    ),
                    const SizedBox(width: 16),
                    // Username and Current Weight
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'Gugi',
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_currentWeight != null)
                            Text(
                              'Current Weight: ${_currentWeight!.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontFamily: 'Gugi',
                              ),
                            )
                          else
                            const Text(
                              'No weight data',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontFamily: 'Gugi',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Icon
              Positioned(
                top: 8,
                right: 8,
                child: const Icon(
                  Icons.edit,
                  color: Colors.white70,
                  semanticLabel: 'Edit Profile',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required VoidCallback onPressed,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                  semanticLabel: label,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gugi',
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

