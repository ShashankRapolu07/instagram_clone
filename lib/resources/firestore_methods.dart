import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/models/post_model.dart' as PostModel;
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storage = StorageMethods();

  Future<String> uploadPost(Uint8List file, String description, String username,
      String uid, String ProPicUrl) async {
    String res = 'Some error occurred';
    try {
      String PostPhotoUrl =
          await _storage.uploadImageToStorage('posts', file, true);

      String postId = const Uuid().v1(); // to generate unique id for each post
      PostModel.Post post = PostModel.Post(
          description: description,
          username: username,
          uid: uid,
          postId: postId,
          PostPhotoUrl: PostPhotoUrl,
          ProPicUrl: ProPicUrl,
          datePublished: Timestamp.now(),
          likes: []);

      await _firestore.collection('posts').doc(postId).set(post.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    //method to both like and dislike
    //here uid is of the current user and not of the post owner
    if (likes.contains(uid)) {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  Future<void> likeComment(
      String postId, String commentId, List likes, String uid) async {
    if (likes.contains(uid)) {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  Future<String> postComment(String text, String postId, String username,
      String uid, String ProPicUrl) async {
    String res = '';
    try {
      String commentId = const Uuid().v1();
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set({
        'postId': postId,
        'text': text,
        'datePublished': DateTime.now(),
        'likes': [],
        'uid': uid,
        'username': username,
        'ProPicUrl': ProPicUrl,
        'commentId': commentId
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deletePost(String postId) async {
    String res = 'Some error occurred.';
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteComment(String postId, String commentId) async {
    String res = 'Some error occurred.';
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> Follow_Unfollow(
      String other_uid, String current_uid, List followers) async {
    String res = 'Some error occurred';
    try {
      if (followers.contains(current_uid)) {
        await _firestore.collection('users').doc(other_uid).update({
          'followers': FieldValue.arrayRemove([current_uid])
        });
        await _firestore.collection('users').doc(current_uid).update({
          'following': FieldValue.arrayRemove([other_uid])
        });
      } else {
        await _firestore.collection('users').doc(other_uid).update({
          'followers': FieldValue.arrayUnion([current_uid])
        });
        await _firestore.collection('users').doc(current_uid).update({
          'following': FieldValue.arrayUnion([other_uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
