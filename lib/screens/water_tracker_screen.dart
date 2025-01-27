// lib/screens/water_tracker_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/water_tracker_provider.dart';
import '../styles/styles.dart';
import '../utils/image_helper.dart';
import 'goal_setup_screen.dart'; // Import GoalSetupScreen
import 'home_screen.dart'; // Import HomeScreen for navigation

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});
  static const String routeName = '/waterTracker';

  @override
  WaterTrackerScreenState createState() => WaterTrackerScreenState();
}

class WaterTrackerScreenState extends State<WaterTrackerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _waterController = TextEditingController();
  final double _dailyGoal = 3000.0; // Daily water intake goal in milliliters

  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _hasShownGoalMessage = false; // Flag to ensure the message shows only once
  DateTime? _startDate; // To calculate the current day

  @override
  void initState() {
    super.initState();

    // Initialize data sequentially to ensure proper loading
    _initializeData();

    // Initialize AnimationController for entry animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Define the animation curve
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    // Initialize goal status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WaterTrackerProvider>(context, listen: false)
          .getTotalWaterIntake();
    });
  }

  // Method to initialize data sequentially
  void _initializeData() async {
    await _loadStartDate();
    await _loadHasShownGoalMessage();
  }

  // Load the start date from SharedPreferences
  Future<void> _loadStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    String? startDateString = prefs.getString('startDate');
    if (startDateString != null) {
      setState(() {
        _startDate = DateTime.parse(startDateString);
      });
    } else {
      setState(() {
        _startDate = DateTime.now();
        prefs.setString('startDate', _startDate!.toIso8601String());
      });
    }
  }

  // Load whether the goal message has been shown for the current day
  Future<void> _loadHasShownGoalMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getHasShownGoalMessageKey();
    setState(() {
      _hasShownGoalMessage = prefs.getBool(key) ?? false;
    });
  }

  // Save that the goal message has been shown for the current day
  Future<void> _saveHasShownGoalMessage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getHasShownGoalMessageKey();
    prefs.setBool(key, value);
  }

  // Get the key for storing the goal message flag in SharedPreferences
  String _getHasShownGoalMessageKey() {
    int currentDay = _getCurrentDay();
    return 'hasShownGoalMessage_day_$currentDay';
  }

  // Calculate the current day based on the start date
  int _getCurrentDay() {
    if (_startDate == null) {
      // _startDate should not be null here, but in case it is, return 1
      return 1;
    }
    final now = DateTime.now();
    final difference = now.difference(_startDate!).inDays + 1;
    return difference.clamp(1, 75);
  }

  @override
  void dispose() {
    _waterController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the WaterTrackerProvider
    final waterProvider = Provider.of<WaterTrackerProvider>(context);

    // Check if the daily goal is reached and the message hasn't been shown yet
    // Only perform this check if totalWaterIntake is greater than zero
    if (waterProvider.totalWaterIntake >= _dailyGoal &&
        !_hasShownGoalMessage &&
        waterProvider.totalWaterIntake > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _hasShownGoalMessage = true;
        });
        _saveHasShownGoalMessage(true);
        _showGoalAchievedDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context); // Navigate back if possible
            } else {
              // Navigate to HomeScreen or another default screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          },
        ),
        title: Text('Water Tracker', style: AppTextStyles.title),
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.text),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure full width
          children: <Widget>[
            _buildProgressSection(waterProvider),
            const SizedBox(height: 30),
            _buildAddWaterSection(waterProvider),
            const SizedBox(height: 30),
            _buildHistorySection(waterProvider),
            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWaterDialog(waterProvider);
        },
        backgroundColor: AppColors.primary,
        tooltip: 'Add Water Intake',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Progress Section: Displays total intake and circular progress bar
  Widget _buildProgressSection(WaterTrackerProvider provider) {
    double totalIntake = provider.totalWaterIntake;
    double progress = (totalIntake / _dailyGoal).clamp(0.0, 1.0);

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 150.0,
          lineWidth: 15.0,
          animation: true,
          percent: progress,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${totalIntake.toStringAsFixed(0)} ml',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 5),
              Text(
                'of ${_dailyGoal.toStringAsFixed(0)} ml',
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: Colors.grey[300]!,
          animationDuration: 1000,
          rotateLinearGradient: false,
          linearGradient: const LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        const SizedBox(height: 20),
        Lottie.asset(
          'assets/animations/water_drop.json',
          width: 100,
          height: 100,
          repeat: true,
        ),
      ],
    );
  }

  // Add Water Intake Section: Button to add water intake
  Widget _buildAddWaterSection(WaterTrackerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Water Intake',
          style: AppTextStyles.body.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            _showAddWaterDialog(provider);
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Intake'),
          style: AppButtonStyles.primary,
        ),
      ],
    );
  }

  // History Section: Lists all water intake entries for the day
  Widget _buildHistorySection(WaterTrackerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intake History',
          style: AppTextStyles.body.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: provider.getTodayWaterIntakeStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: AppTextStyles.error,
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No water intake logged today.',
                  style: AppTextStyles.body,
                ),
              );
            }

            final waterEntries = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: waterEntries.length,
              itemBuilder: (context, index) {
                final entry = waterEntries[index];
                Timestamp timestamp = entry['timestamp'] ?? Timestamp.now();
                DateTime time = timestamp.toDate();
                String formattedTime =
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.water_drop,
                      color: AppColors.primary,
                      size: 30,
                    ),
                    title: Text(
                      '${entry['amount']} ml',
                      style: AppTextStyles.body,
                    ),
                    subtitle: Text(
                      formattedTime,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Dialog to add water intake
  void _showAddWaterDialog(WaterTrackerProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text("Add Water Intake", style: AppTextStyles.dialogTitle),
          content: TextField(
            controller: _waterController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter amount in ml',
              hintStyle: AppTextStyles.hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel", style: AppTextStyles.cancelButton),
            ),
            ElevatedButton(
              onPressed: () async {
                double? amount = double.tryParse(_waterController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Please enter a valid amount.',
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                try {
                  await provider.addWaterIntake(amount);
                  _waterController.clear();
                  Navigator.of(context).pop(); // Close the dialog

                  // Trigger entry animation
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Water intake added successfully!',
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Error adding water intake: $e',
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Add", style: AppTextStyles.button),
            ),
          ],
        );
      },
    );
  }

  // Show dialog when daily goal is achieved
  void _showGoalAchievedDialog() async {
    final currentDay = _getCurrentDay();

    // Set 'day_{currentDay}_water_goal' to true in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('day_${currentDay}_water_goal', true);

    // Show congratulatory dialog
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!', style: AppTextStyles.dialogTitle),
          content: Text(
            'Well done! You achieved your daily water intake.',
            style: AppTextStyles.body,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: AppTextStyles.button),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog

                // Navigate to GoalSetupScreen with the current day
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalSetupScreen(day: currentDay),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}



