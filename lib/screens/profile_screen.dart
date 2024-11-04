import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
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

  // Upload profile image to Firebase Storage
  Future<String?> _uploadProfileImage() async {
    if (_profileImage != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profileImages/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageRef.putFile(_profileImage!);
        TaskSnapshot taskSnapshot = await uploadTask;

        if (taskSnapshot.state == TaskState.success) {
          return await taskSnapshot.ref.getDownloadURL();
        }
      } catch (e) {
        print("Error uploading profile image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading profile image: $e")),
        );
      }
    }
    return null; // Return null if no image to upload
  }

  // Save profile information
  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);

    // Upload image and get URL
    String? imageUrl = await _uploadProfileImage();
    if (imageUrl != null) {
      // Store image URL in Firestore
      String userId = "user_${prefs.getString('userId') ?? "defaultId"}"; // Ensure you have a unique user ID
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': _usernameController.text,
        'profileImageUrl': imageUrl,
      }, SetOptions(merge: true)); // Use merge to prevent overwriting other fields

      // Save the local image path to SharedPreferences
      await prefs.setString('profileImagePath', _profileImage!.path);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully!")),
    );
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Store the selected image file
      });
      // Save the selected image path to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

