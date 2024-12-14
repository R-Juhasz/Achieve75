import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:achieve75/screens/home_screen.dart';
import 'package:achieve75/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../styles/styles.dart'; // Import styles

class Hard75Slideshow extends StatefulWidget {
  const Hard75Slideshow({super.key});

  @override
  _Hard75SlideshowState createState() => _Hard75SlideshowState();
}

class _Hard75SlideshowState extends State<Hard75Slideshow> {
  final PageController _pageController = PageController();
  late Timer _timer;
  int _currentPage = 0;

  final List<Map<String, dynamic>> goals = [
    {
      'title': 'Goal 1: Two Workouts a Day',
      'description': 'Complete two 45-minute workouts a day, one of which must be outdoors.',
      'icon': Icons.fitness_center,
    },
    {
      'title': 'Goal 2: Drink a Gallon of Water',
      'description': 'Drink 1 gallon of water every day to stay hydrated.',
      'icon': Icons.local_drink,
    },
    {
      'title': 'Goal 3: Follow a Diet',
      'description': 'Stick to a diet plan of your choice. No cheat meals or alcohol allowed.',
      'icon': Icons.no_meals,
    },
    {
      'title': 'Goal 4: Read 10 Pages',
      'description': 'Read at least 10 pages of a non-fiction or self-development book every day.',
      'icon': Icons.book,
    },
    {
      'title': 'Goal 5: Take a Progress Picture',
      'description': 'Take a progress photo every day to track your fitness journey.',
      'icon': Icons.camera_alt,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlideShow();
  }

  void _startAutoSlideShow() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < goals.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _onContinuePressed() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLogin = prefs.getBool('isFirstLogin') ?? true;

    if (isFirstLogin) {
      await prefs.setBool('isFirstLogin', false); // Set it to false after first login
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          '75 Hard Challenge Goals',
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: goals.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return GoalSlide(
                title: goals[index]['title']!,
                description: goals[index]['description']!,
                icon: goals[index]['icon']!,
              );
            },
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: AppButtonStyles.primary,
                onPressed: _onContinuePressed,
                child: Text(
                  'Continue',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: goals.length,
                effect: ExpandingDotsEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.cardBackground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoalSlide extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const GoalSlide({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTextStyles.title.copyWith(color: AppColors.text),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
