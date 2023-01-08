import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? uid;
  final String? email;
  final String? username;
  final String? bio;
  final String? ProPicUrl;
  final List? followers;
  final List? following;

  User(
      {this.uid,
      this.email,
      this.username,
      this.ProPicUrl,
      this.bio,
      this.followers,
      this.following});

  // returns a map containing user details for storing in firebase database
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'email': email,
        'ProPicUrl': ProPicUrl,
        'bio': bio,
        'followers': followers,
        'following': following
      };

  //creates a UserModel.User model from a document snapshot
  User fromSnap(DocumentSnapshot snapshot) {
    return User(
        uid: snapshot['uid'],
        email: snapshot['email'],
        username: snapshot['username'],
        ProPicUrl: snapshot['ProPicUrl'],
        bio: snapshot['bio'],
        followers: snapshot['followers'],
        following: snapshot['following']);
  }
}
