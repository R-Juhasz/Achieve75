/// lib/providers/post_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostProvider with ChangeNotifier {
  final CollectionReference _postsCollection = FirebaseFirestore.instance.collection('posts');

  // Stream of posts ordered by timestamp descending (newest first)
  Stream<QuerySnapshot> get postsStream {
    return _postsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // Add a new post
  Future<void> addPost({
    required String comment,
    String? imageUrl,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _postsCollection.add({
        'username': user.displayName ?? 'Anonymous',
        'userId': user.uid,
        'comment': comment,
        'imageUrl': imageUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'profileImageUrl': user.photoURL ?? '', // Fetch from user profile
        'likes': {},
      });
    } catch (e) {
      print('Error adding post: $e');
      rethrow;
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _postsCollection.doc(postId).delete();
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  // Toggle like/unlike a post
  Future<void> toggleLike(String postId, String userId, bool isLiked) async {
    try {
      DocumentReference postRef = _postsCollection.doc(postId);
      if (isLiked) {
        // Unlike
        await postRef.update({
          'likes.$userId': FieldValue.delete(),
        });
      } else {
        // Like
        await postRef.update({
          'likes.$userId': true,
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // Add a reply to a post
  Future<void> addReply({
    required String postId,
    required String comment,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _postsCollection.doc(postId).collection('replies').add({
        'username': user.displayName ?? 'Anonymous',
        'userId': user.uid,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'profileImageUrl': user.photoURL ?? '', // Fetch from user profile
      });
    } catch (e) {
      print('Error adding reply: $e');
      rethrow;
    }
  }

  // Stream of replies for a specific post
  Stream<QuerySnapshot> getRepliesStream(String postId) {
    return _postsCollection
        .doc(postId)
        .collection('replies')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
