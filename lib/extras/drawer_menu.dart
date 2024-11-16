// drawer_menu.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/bulletin_board_screen.dart';
import '../screens/challenge_screen.dart';
import '../screens/home_screen.dart';
import '../screens/picture_library_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/weight_tracker_screen.dart';
import '../screens/login_screen.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white, // Set drawer background to white
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/achieve75-high-resolution-logo-transparent.png',
                  height: 60,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Achieve75',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Gugi',
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            routeName: HomeScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.message,
            title: 'Bulletin Board',
            routeName: BulletinBoardScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.check_circle,
            title: 'Challenge',
            routeName: ChallengeScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.photo_library,
            title: 'Picture Library',
            routeName: PictureLibraryScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Profile',
            routeName: ProfileScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.monitor_weight,
            title: 'Weight Tracker',
            routeName: WeightTrackerScreen.routeName,
          ),
          const Divider(), // Add a divider before Sign Out
          _buildSignOutItem(context), // Added Sign Out option
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String routeName,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black, // Text color for white background
          fontFamily: 'Gugi',
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
    );
  }

  Widget _buildSignOutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Sign Out',
        style: TextStyle(
          fontSize: 16,
          color: Colors.red,
          fontFamily: 'Gugi',
        ),
      ),
      onTap: () async {
        // Confirm Sign Out
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
          // Perform Sign Out
          try {
            await FirebaseAuth.instance.signOut();
            // Navigate to Login Screen
            Navigator.pushReplacementNamed(context, LoginScreen.routeName);
          } catch (e) {
            print('Error signing out: $e');
            // Optionally, show an error message to the user
          }
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
    );
  }
}
