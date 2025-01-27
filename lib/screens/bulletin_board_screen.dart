// lib/screens/bulletin_board_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../extras/drawer_menu.dart';
import '../providers/auth_provider.dart';
import '../styles/styles.dart'; // Import styles

import '../providers/post_provider.dart';
import '../utils/time_util.dart'; // Import the timeAgo function
import 'package:firebase_storage/firebase_storage.dart';

class BulletinBoardScreen extends StatefulWidget {
  const BulletinBoardScreen({super.key});
  static const String routeName = '/bulletinBoard';

  @override
  _BulletinBoardScreenState createState() => _BulletinBoardScreenState();
}

class _BulletinBoardScreenState extends State<BulletinBoardScreen> {
  final TextEditingController _commentController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          'Bulletin Board',
          style: AppTextStyles.title,
        ),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.text),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: Column(
        children: [
          Expanded(child: _buildPostList(postProvider)),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.image, color: AppColors.background),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _commentController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Enter your comment',
                hintStyle: AppTextStyles.hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _isUploading
              ? CircularProgressIndicator(color: AppColors.primary)
              : GestureDetector(
            onTap: _addPost,
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.send, color: AppColors.background),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error picking image: $e',
            style: AppTextStyles.body,
          ),
        ),
      );
    }
  }

  Future<void> _addPost() async {
    if (_commentController.text.trim().isNotEmpty || _imageFile != null) {
      try {
        setState(() {
          _isUploading = true;
        });

        String? imageUrl;
        if (_imageFile != null) {
          // Upload image to Firebase Storage and get URL
          imageUrl = await _uploadImage(_imageFile!);
          if (imageUrl == null) throw Exception('Image upload failed');
        }

        await Provider.of<PostProvider>(context, listen: false).addPost(
          comment: _commentController.text.trim(),
          imageUrl: imageUrl,
        );

        _commentController.clear();
        setState(() {
          _imageFile = null;
        });
        FocusScope.of(context).unfocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Post added successfully!',
              style: AppTextStyles.body,
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      } catch (e) {
        print('Error adding post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error adding post: $e',
              style: AppTextStyles.body,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a comment or select an image.',
            style: AppTextStyles.body,
          ),
        ),
      );
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Define the file path in Firebase Storage
      String fileName = 'posts/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      // Upload the file
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Widget _buildPostList(PostProvider postProvider) {
    return StreamBuilder<QuerySnapshot>(
      stream: postProvider.postsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
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
              'No posts available.',
              style: AppTextStyles.body,
            ),
          );
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
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    final isLiked = post['likes'] != null && post['likes'].containsKey(currentUser?.uid ?? '');
    final likeCount = post['likes'] != null ? post['likes'].length : 0;

    Timestamp timestamp = post['timestamp'] ?? Timestamp.now();
    DateTime postTime = timestamp.toDate();
    String formattedTime = timeAgo(postTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info and Timestamp
            Row(
              children: [
                post['profileImageUrl'] != null && post['profileImageUrl'].isNotEmpty
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(post['profileImageUrl']),
                  radius: 20,
                )
                    : CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: AppColors.text),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['username'],
                      style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formattedTime,
                      style: AppTextStyles.hint.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                if (currentUser != null && currentUser.uid == post['userId'])
                  IconButton(
                    icon: Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _deletePost(post.id),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Comment
            Text(
              post['comment'],
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 10),
            // Image (if any)
            if (post['imageUrl'] != null && post['imageUrl'].isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: Image.network(
                  post['imageUrl'],
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 10),
            // Like and Reply Buttons
            Row(
              children: [
                GestureDetector(
                  onTap: currentUser != null
                      ? () => Provider.of<PostProvider>(context, listen: false)
                      .toggleLike(post.id, currentUser.uid, isLiked)
                      : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You need to be logged in to like posts.',
                          style: AppTextStyles.body,
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: isLiked ? AppColors.primary : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$likeCount',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    _showReplyDialog(post.id);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Reply',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Display Replies
            StreamBuilder<QuerySnapshot>(
              stream: Provider.of<PostProvider>(context, listen: false).getRepliesStream(post.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blue));
                }
                if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: AppTextStyles.error,
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SizedBox.shrink();
                }

                final replies = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply = replies[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          reply['profileImageUrl'] != null && reply['profileImageUrl'].isNotEmpty
                              ? CircleAvatar(
                            backgroundImage: NetworkImage(reply['profileImageUrl']),
                            radius: 15,
                          )
                              : CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.person, color: AppColors.text, size: 15),
                            radius: 15,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reply['username'],
                                  style: AppTextStyles.subtitle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  reply['comment'],
                                  style: AppTextStyles.body.copyWith(fontSize: 14),
                                ),
                                Text(
                                  timeAgo(reply['timestamp'].toDate()),
                                  style: AppTextStyles.hint.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      await Provider.of<PostProvider>(context, listen: false).deletePost(postId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Post deleted successfully.',
            style: AppTextStyles.body,
          ),
        ),
      );
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting post: $e',
            style: AppTextStyles.body,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showReplyDialog(String postId) {
    TextEditingController _replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reply', style: AppTextStyles.subtitle),
          content: TextField(
            controller: _replyController,
            decoration: InputDecoration(
              hintText: 'Enter your reply',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: AppTextStyles.body.copyWith(color: AppColors.error)),
            ),
            TextButton(
              onPressed: () async {
                if (_replyController.text.trim().isNotEmpty) {
                  final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
                  final currentUser = authProvider.user;

                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You need to be logged in to reply.',
                          style: AppTextStyles.body,
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  try {
                    await Provider.of<PostProvider>(context, listen: false).addReply(
                      postId: postId,
                      comment: _replyController.text.trim(),
                    );

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Reply added successfully!',
                          style: AppTextStyles.body,
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  } catch (e) {
                    print('Error adding reply: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error adding reply: $e',
                          style: AppTextStyles.body,
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text('Reply', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }
}

