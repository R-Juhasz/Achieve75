// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import '../extras/hard75_slideshow.dart';
import '../extras/progress_section.dart';
import '../utils/progress_utils.dart';
import '../utils/shared_preferences_helper.dart';
import '../extras/drawer_menu.dart';
import 'bulletin_board_screen.dart';
import 'challenge_screen.dart';
import 'diet_screen.dart';
import 'picture_library_screen.dart';
import 'weight_tracker_screen.dart';
import 'profile_screen.dart';
import 'water_tracker_screen.dart'; // <-- Import the WaterTrackerScreen
import '../styles/styles.dart'; // Importing styles

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
  int _daysCompleted = 0;
  int _daysFailed = 0;
  DateTime _currentDate = DateTime.now();
  double? _currentWeight;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    _loadProfileImage();
    _loadUsername();
    _loadCurrentDay();
    _calculateProgress();
    _loadCurrentWeight();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferencesHelper.prefs;
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
    final prefs = await SharedPreferencesHelper.prefs;
    String? username = prefs.getString('username');
    if (username != null) {
      setState(() {
        _username = username;
      });
    }
  }

  Future<void> _loadCurrentDay() async {
    final prefs = await SharedPreferencesHelper.prefs;
    setState(() {
      _currentDay = prefs.getInt('currentDay') ?? 1;
    });
  }

  Future<void> _calculateProgress() async {
    Map<String, dynamic> progressData =
    await ProgressUtils.calculateProgress(_currentDay);
    setState(() {
      _daysCompleted = progressData['daysCompleted'];
      _daysFailed = progressData['daysFailed'];
      _currentDate = DateTime.now();
    });
  }

  Future<void> _loadCurrentWeight() async {
    final prefs = await SharedPreferencesHelper.prefs;
    final savedWeights = prefs.getStringList('weights') ?? [];
    setState(() {
      _currentWeight = savedWeights.isNotEmpty
          ? double.parse(savedWeights.last)
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.text),
        title: Image.asset(
          'assets/images/achieve75-high-resolution-logo-transparent.png',
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.rule, color: AppColors.text), // Choose an appropriate icon
            tooltip: 'Challenge Rules',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Hard75Slideshow()),
              );
            },
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure full width
          children: [
            Text(
              'Welcome back, $_username!',
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ProgressSection(
              currentDay: _currentDay,
              daysCompleted: _daysCompleted,
              daysFailed: _daysFailed,
              currentDate: _currentDate,
            ),
            const SizedBox(height: 20),
            _buildProfileSection(),
            const SizedBox(height: 20),
            _buildModernButton(
              label: 'View Challenge',
              icon: Icons.flag,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChallengeScreen(),
                  ),
                ).then((_) {
                  _loadCurrentDay();
                  _calculateProgress();
                });
              },
            ),
            _buildModernButton(
              label: 'Bulletin Board',
              icon: Icons.message,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BulletinBoardScreen(),
                  ),
                );
              },
            ),
            _buildModernButton(
              label: 'View Progress Pictures',
              icon: Icons.photo_library,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PictureLibraryScreen(),
                  ),
                );
              },
            ),
            _buildModernButton(
              label: 'Track Weight',
              icon: Icons.monitor_weight,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeightTrackerScreen(),
                  ),
                ).then((_) {
                  _loadCurrentWeight();
                });
              },
            ),
            _buildModernButton(
              label: 'Track Water Intake',
              icon: Icons.local_drink, // Choose an appropriate icon
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WaterTrackerScreen(),
                  ),
                );
              },
            ),
            _buildModernButton(
              label: 'View Workouts',
              icon: Icons.fitness_center,
              onPressed: () {
                Navigator.pushNamed(context, '/workouts');
              },
            ),
            _buildModernButton(
              label: 'Diet Tracker',
              icon: Icons.restaurant_menu,
              onPressed: () {
                Navigator.pushNamed(context, DietScreen.routeName); // Use routeName
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ).then((_) {
              _loadProfileData();
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  backgroundColor: Colors.transparent,
                  radius: 40,
                  child: _profileImage == null
                      ? Icon(Icons.person, color: AppColors.text, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username,
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: 8),
                      if (_currentWeight != null)
                        Text(
                          'Current Weight: ${_currentWeight!.toStringAsFixed(1)} kg',
                          style: AppTextStyles.bodySecondary,
                        )
                      else
                        Text(
                          'No weight data',
                          style: AppTextStyles.bodySecondary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: AppButtonStyles.primary.copyWith(
          minimumSize: WidgetStateProperty.all<Size>(
            const Size(double.infinity, 50),
          ), // Ensures full width and height
        ),
        icon: Icon(icon, color: AppColors.text, size: 24),
        label: Text(
          label,
          style: AppTextStyles.button,
        ),
      ),
    );
  }
}
