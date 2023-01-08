import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user_model.dart' as UserModel;
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/comment_card.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final snap; //post snapshot and not comments snapshot
  const CommentsScreen({required this.snap});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirestoreMethods _firestore = FirestoreMethods();

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  //function to store current user's comment details in firebase
  Future<void> _postComment(String text, String postId, String? username,
      String? uid, String? ProPicUrl) async {
    String res =
        await _firestore.postComment(text, postId, username!, uid!, ProPicUrl!);
    if (res == 'success') {
      showSnackBar(context, 'Commented successfully!');
    } else {
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserModel.User user = Provider.of<UserProvider>(context).getUser!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      //any changes will automatically reflected back with the stream builder
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: ((context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No comments yet',
                  style: TextStyle(color: secondaryColor),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return CommentCard(snap: snapshot.data!.docs[index]);
                },
              );
            }
          }
        }),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.12,
          margin: const EdgeInsets.only(bottom: 3.0),
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 8.0,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  user.ProPicUrl!,
                ),
                radius: 18.0,
              ),
              const SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 10.0, bottom: 4.0, top: 0.0),
                    decoration: const BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.all(
                        Radius.circular(3.0),
                      ),
                    ),
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                          hintText: 'Comment as ${user.username}',
                          hintStyle: const TextStyle(fontSize: 15.0),
                          border: InputBorder.none),
                      maxLines: 8,
                    ),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    _postComment(_commentController.text, widget.snap['postId'],
                        user.username, user.uid, user.ProPicUrl);
                    setState(
                      () => _commentController.text = '',
                    );
                  },
                  icon: const Icon(Icons.send))
            ],
          ),
        ),
      ),
    );
  }
}
