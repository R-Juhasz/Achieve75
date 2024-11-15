import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

import '../extras/drawer_menu.dart';

class PictureLibraryScreen extends StatefulWidget {
  const PictureLibraryScreen({Key? key}) : super(key: key);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Progress Pictures',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.black,
      ),
      body: progressPictures.isEmpty
          ? Center(
        child: Text(
          'No progress pictures yet!',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
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
              );
            },
            child: GridTile(
              footer: Container(
                color: Colors.black54,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Day ${picture['day']}',
                    style: const TextStyle(color: Colors.blue, fontSize: 16),
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
    );
  }
}

class FullScreenImageScreen extends StatelessWidget {
  final String imagePath;
  final int day;

  const FullScreenImageScreen({Key? key, required this.imagePath, required this.day})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Day $day',
          style: const TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.black,
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
