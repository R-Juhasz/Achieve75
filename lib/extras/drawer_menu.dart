import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/bulletin_board_screen.dart';
import '../screens/challenge_screen.dart';
import '../screens/home_screen.dart';
import '../screens/picture_library_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/weight_tracker_screen.dart';
import '../screens/login_screen.dart';
import '../screens/water_tracker_screen.dart';
import '../styles/styles.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cardBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/achieve75-high-resolution-logo-transparent.png',
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error,
                      color: AppColors.error,
                      size: 60,
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Achieve75',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.text,
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
          _buildDrawerItem(
            context,
            icon: Icons.local_drink,
            title: 'Water Tracker',
            routeName: WaterTrackerScreen.routeName,
          ),
          const Divider(),
          _buildSignOutItem(context),
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
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(color: AppColors.text),
      ),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        // Navigate to the route
        Navigator.pushNamedAndRemoveUntil(
          context,
          routeName,
              (route) => false,
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
    );
  }

  Widget _buildSignOutItem(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout, color: AppColors.error),
      title: Text(
        'Sign Out',
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
      onTap: () async {
        bool? confirmSignOut = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: Text('Sign Out', style: AppTextStyles.title),
              content: Text(
                'Are you sure you want to sign out?',
                style: AppTextStyles.body,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel', style: AppTextStyles.button),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Sign Out',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            );
          },
        );

        if (confirmSignOut == true) {
          try {
            await FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginScreen.routeName,
                  (route) => false,
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error signing out. Please try again.',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
    );
  }
}

