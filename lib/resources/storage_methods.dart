import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    String downloadUrl = 'Some error occured.';
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    if (isPost) {
      String id = Uuid()
          .v1(); //to generate unique id that can be used as a unique name to store the post image
      ref = ref.child(id);
    }
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}
