import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BulletinBoardScreen extends StatefulWidget {
  @override
  _BulletinBoardScreenState createState() => _BulletinBoardScreenState();
}

class _BulletinBoardScreenState extends State<BulletinBoardScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  // Add new post to Firestore
  Future<void> _addPost() async {
    String? imageUrl;

    // If an image is picked, upload it to Firestore Storage and get the URL
    if (_imageFile != null) {
      try {
        // Confirm the file exists
        if (await _imageFile!.exists()) {
          print("Image file exists. Starting upload...");

          // Firebase Storage upload
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('bulletinBoardImages/${DateTime.now().millisecondsSinceEpoch}');
          UploadTask uploadTask = storageRef.putFile(_imageFile!);

          // Monitor task status
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            print('Upload progress: ${snapshot.bytesTransferred} / ${snapshot.totalBytes}');
          }, onError: (e) {
            print("Upload error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error during upload: $e")),
            );
          });

          // Wait for the upload to complete
          TaskSnapshot taskSnapshot = await uploadTask;

          // Confirm upload success and get URL
          if (taskSnapshot.state == TaskState.success) {
            imageUrl = await taskSnapshot.ref.getDownloadURL();
            print("Image uploaded successfully: $imageUrl");
          } else {
            print("Image upload failed with state: ${taskSnapshot.state}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to upload image")),
            );
            return; // Exit if upload fails
          }
        } else {
          print("Selected image file does not exist");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Selected image file does not exist")),
          );
          return;
        }
      } catch (e) {
        print("Error uploading image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading image: $e")),
        );
        return;
      }
    }

    // Add the comment and image URL to Firestore
    try {
      await FirebaseFirestore.instance.collection('bulletinBoardPosts').add({
        'username': 'User', // Replace with actual username
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
      });
      print("Post added successfully");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post added successfully!")),
      );
    } catch (e) {
      print("Error adding post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding post: $e")),
      );
    }

    _commentController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Store the selected image file
      });
      print("Picked image: ${_imageFile!.path}"); // Log the picked image path
    } else {
      print("No image selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulletin Board')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('bulletinBoardPosts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['username']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc['comment']),
                          if (doc['imageUrl'] != null && doc['imageUrl'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Image.network(doc['imageUrl'], height: 100),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Add a comment'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Upload Image'),
                    ),
                    ElevatedButton(
                      onPressed: _addPost,
                      child: const Text('Post'),
                    ),
                  ],
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(_imageFile!, height: 100),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
