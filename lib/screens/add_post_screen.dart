import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/models/user_model.dart' as UserModel;
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  bool from_profile;
  AddPostScreen({required this.from_profile});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  final FirestoreMethods _firestore = FirestoreMethods();
  bool _isLoading = false;

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
              title: const Text('Upload photo from'),
              children: [
                SimpleDialogOption(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20.0),
                    child: Row(children: const [
                      Icon(Icons.camera),
                      SizedBox(width: 10.0),
                      Text('Camera',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 16.0))
                    ]),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Uint8List? file = await pickImage(ImageSource.camera);
                      setState(() => _file = file);
                    }),
                SimpleDialogOption(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20.0),
                    child: Row(children: const [
                      Icon(Icons.browse_gallery),
                      SizedBox(width: 10.0),
                      Text('Gallery',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 16.0))
                    ]),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Uint8List? file = await pickImage(ImageSource.gallery);
                      setState(() => _file = file);
                    })
              ]);
        });
  }

  _postImage(
      // function for uploading a post to firestore database and storage
      String description,
      String username,
      String uid,
      String ProPicUrl) async {
    setState(() => _isLoading = true);

    String res = await _firestore.uploadPost(
        _file!, description, username, uid, ProPicUrl);

    if (res == 'success') {
      setState(() {
        _isLoading = false;
        _file = null;
        _descriptionController.text = '';
      });
      showSnackBar(context, 'Posted!');
    } else {
      setState(() => _isLoading = false);
      showSnackBar(context, res);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel.User user = Provider.of<UserProvider>(context).getUser!;

    return _file == null
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: widget.from_profile
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back))
                  : Container(),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 60.0,
                      child: IconButton(
                          icon: const Icon(Icons.upload),
                          onPressed: () => _selectImage(context),
                          iconSize: 40.0)),
                  const Text('Upload an image',
                      style: TextStyle(fontWeight: FontWeight.normal))
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: TextButton(
                  child: const Text('Cancel',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0,
                          color: Colors.redAccent)),
                  onPressed: () => setState(() => _file = null)),
              title: const Text('Add Post'),
              centerTitle: true,
              actions: [
                TextButton(
                    child: const Text('Post',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: blueColor)),
                    onPressed: () => _postImage(_descriptionController.text,
                        user.username!, user.uid!, user.ProPicUrl!))
              ],
            ),
            body: Column(
              children: [
                _isLoading
                    ? const LinearProgressIndicator(
                        color: blueColor, backgroundColor: secondaryColor)
                    : Container(),
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      radius: 25.0,
                      backgroundColor: const Color.fromARGB(168, 255, 255, 255),
                      child: CircleAvatar(
                          backgroundImage: NetworkImage('${user.ProPicUrl}'),
                          radius: 23.0),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                              hintText: 'Write a caption...',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondaryColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)))),
                          maxLines: 8),
                    ),
                    SizedBox(
                      width: 95,
                      height: 95,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: MemoryImage(_file!),
                        )),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
  }
}
