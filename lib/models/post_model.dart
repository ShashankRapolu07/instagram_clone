import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? description;
  final String? uid;
  final String? username;
  final String? postId;
  final datePublished;
  final String? PostPhotoUrl;
  final String? ProPicUrl;
  final likes;

  Post(
      {this.description,
      this.uid,
      this.username,
      this.postId,
      this.datePublished,
      this.PostPhotoUrl,
      this.ProPicUrl,
      this.likes});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'uid': uid,
      'username': username,
      'postId': postId,
      'PostPhotoUrl': PostPhotoUrl,
      'ProPicUrl': ProPicUrl,
      'likes': likes,
      'datePublished': datePublished
    };
  }

  Post fromSnap(DocumentSnapshot snapshot) {
    return Post(
        PostPhotoUrl: snapshot['PostPhotoUrl'],
        ProPicUrl: snapshot['ProPicUrl'],
        datePublished: snapshot['datePublished'],
        likes: snapshot['likes'],
        postId: snapshot['postId'],
        username: snapshot['username'],
        uid: snapshot['uid'],
        description: snapshot['description']);
  }
}
