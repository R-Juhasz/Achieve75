import 'package:flutter/material.dart';

import '../screens/bulletin_board_screen.dart';
import '../screens/challenge_screen.dart';
import '../screens/goal_setup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/picture_library_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/weight_tracker_screen.dart';


class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Achieve75',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, HomeScreen.routeName);
            },
          ),
          ListTile(
            title: Text('Bulletin Board'),
            onTap: () {
              Navigator.pushNamed(context, BulletinBoardScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Challenge'),
            onTap: () {
              Navigator.pushNamed(context, ChallengeScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Picture Library'),
            onTap: () {
              Navigator.pushNamed(context, PictureLibraryScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, ProfileScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.line_weight),
            title: Text('Weight Tracker'),
            onTap: () {
              Navigator.pushNamed(context, WeightTrackerScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
