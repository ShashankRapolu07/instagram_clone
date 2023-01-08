import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'storage_methods.dart';
import 'package:instagram_clone/models/user_model.dart' as UserModel;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storage = StorageMethods();

  Future<UserModel.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return UserModel.User().fromSnap(snap);
  }

  //signing up user
  Future<String> SignupUser(
      {required String email,
      required String password,
      required String username,
      required String bio,
      required Uint8List? file}) async {
    String res = 'Some error occured signing up.';
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        String ProPicUrl = 'default';
        if (file != null) {
          //if a profile picture is selected then store it in Firebase Storage and
          ProPicUrl = await _storage.uploadImageToStorage(
              // acquire its Url.
              'Profile Pictures',
              file,
              false);
        }
        // creating a user model from the custom class UserModel.User
        UserModel.User user = UserModel.User(
            ProPicUrl: ProPicUrl,
            email: email,
            uid: cred.user!.uid,
            username: username,
            bio: bio,
            followers: [],
            following: []);
        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
        res = 'success';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //login user
  Future<String> Login(
      {required String email, required String password}) async {
    String res = 'Some error occurred logging in.';
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //logout user
  Future<String> Signout() async {
    String res = 'Some error occurred';
    try {
      await _auth.signOut();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
