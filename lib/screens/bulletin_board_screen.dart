import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BulletinBoardScreen extends StatefulWidget {
  const BulletinBoardScreen({super.key});

  @override
  _BulletinBoardScreenState createState() => _BulletinBoardScreenState();
}

class _BulletinBoardScreenState extends State<BulletinBoardScreen> {
  final TextEditingController _commentController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String _username = 'Anonymous';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Anonymous';
      _profileImagePath = prefs.getString('profileImagePath'); // Load profile image path
    });
  }

  Future<void> _saveProfileImagePath(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulletin Board'),
      ),
      body: Column(
        children: [
          Expanded(child: _buildPostList()),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Enter your comment',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _addPost,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Save the image path in SharedPreferences
      _saveProfileImagePath(pickedFile.path);
    }
  }

  Future<void> _addPost() async {
    if (_commentController.text.trim().isNotEmpty || _imageFile != null) {
      String imageUrl = '';

      try {
        setState(() {
          _isUploading = true;
        });

        // Add post to Firestore
        await FirebaseFirestore.instance.collection('posts').add({
          'username': _username,
          'comment': _commentController.text,
          'imageUrl': _imageFile != null ? _imageFile!.path : '', // Store local image path
          'timestamp': FieldValue.serverTimestamp(),
          'profileImagePath': _profileImagePath ?? '', // Use local profile image path
        });

        _commentController.clear();
        setState(() {
          _imageFile = null;
        });
        FocusScope.of(context).unfocus();

      } catch (e) {
        print('Error adding post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding post: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment or select an image.')),
      );
    }
  }

  Widget _buildPostList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts') // Update with your actual collection name
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No posts available.'));
        }

        final posts = snapshot.data!.docs;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildPostItem(post);
          },
        );
      },
    );
  }

  Widget _buildPostItem(DocumentSnapshot post) {
    return ListTile(
      leading: post['profileImagePath'] != null && post['profileImagePath'].isNotEmpty
          ? CircleAvatar(
        backgroundImage: FileImage(File(post['profileImagePath'])), // Display the local image
      )
          : const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(post['username']),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post['comment']),
          if (post['imageUrl'] != null && post['imageUrl'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.file(File(post['imageUrl'])), // Display the local image
            ),
        ],
      ),
      trailing: _username == post['username']
          ? IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _deletePost(post.id),
      )
          : null,
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete(); // Ensure correct collection name
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully.')),
      );
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }
}

