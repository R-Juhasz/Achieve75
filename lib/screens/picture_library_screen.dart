// lib/screens/picture_library_screen.dart

import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../extras/drawer_menu.dart';
import '../styles/styles.dart'; // Import styles

class PictureLibraryScreen extends StatefulWidget {
  const PictureLibraryScreen({super.key});
  static const String routeName = '/pictureLibrary';

  @override
  _PictureLibraryScreenState createState() => _PictureLibraryScreenState();
}

class _PictureLibraryScreenState extends State<PictureLibraryScreen> {
  List<Map<String, dynamic>> progressPictures = [];

  @override
  void initState() {
    super.initState();
    _loadProgressPictures();
  }

  Future<void> _loadProgressPictures() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPictures = prefs.getStringList('progressPictures') ?? [];

    setState(() {
      progressPictures = savedPictures
          .map((pictureData) => jsonDecode(pictureData) as Map<String, dynamic>)
          .toList();

      // Optional: Sort pictures by day or date
      progressPictures.sort((a, b) => a['day'].compareTo(b['day']));
    });
  }

  Future<void> _refreshPictures() async {
    await _loadProgressPictures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Progress Pictures',
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
        backgroundColor: AppColors.background,
      ),
      drawer: DrawerMenu(),
      body: RefreshIndicator(
        onRefresh: _refreshPictures,
        child: progressPictures.isEmpty
            ? ListView(
          // Allows RefreshIndicator to work with empty state
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(
                child: Text(
                  'No progress pictures yet!',
                  style: AppTextStyles.body.copyWith(color: AppColors.text),
                ),
              ),
            ),
          ],
        )
            : GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: progressPictures.length,
          itemBuilder: (context, index) {
            final picture = progressPictures[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageScreen(
                      imagePath: picture['filePath'],
                      day: picture['day'],
                    ),
                  ),
                ).then((_) {
                  _loadProgressPictures(); // Reload pictures after returning
                });
              },
              child: GridTile(
                footer: Container(
                  color: AppColors.cardBackground.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'Day ${picture['day']}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                child: Image.file(
                  File(picture['filePath']),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FullScreenImageScreen extends StatelessWidget {
  final String imagePath;
  final int day;

  const FullScreenImageScreen({
    super.key,
    required this.imagePath,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          'Day $day',
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
        backgroundColor: AppColors.background,
      ),
      drawer: DrawerMenu(),
      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

