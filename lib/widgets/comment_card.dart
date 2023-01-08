import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final snap; //snap containing single user comment details
  const CommentCard({super.key, required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLikeAnimating = false;

  void _deleteComment() async {
    String res = await FirestoreMethods()
        .deleteComment(widget.snap['postId'], widget.snap['commentId']);
    if (res == 'success') {
      showSnackBar(context, 'Comment deleted.');
    } else {
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.snap['ProPicUrl']),
            radius: 18.0,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: '${widget.snap['username']}  ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${widget.snap['text']}')
                ])),
                const SizedBox(
                  height: 3.0,
                ),
                Text(
                  DateFormat.yMMMd()
                      .format(widget.snap['datePublished'].toDate())
                      .toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 10.0),
                )
              ],
            ),
          ),
          widget.snap['uid'] == FirebaseAuth.instance.currentUser!.uid
              ? PopupMenuButton(
                  iconSize: 25.0,
                  onSelected: (value) {
                    if (value == 0) {
                      _deleteComment();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 0,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Text(
                            'delete',
                            style: TextStyle(fontSize: 17.0),
                          ),
                        ))
                  ],
                )
              : Container(),
          Column(
            children: [
              LikeAnimation(
                isAnimating: _isLikeAnimating,
                duration: const Duration(milliseconds: 150),
                onEnd: () => setState(() => _isLikeAnimating = false),
                child: IconButton(
                    onPressed: () async {
                      await FirestoreMethods().likeComment(
                          widget.snap['postId'],
                          widget.snap['commentId'],
                          widget.snap['likes'],
                          _auth.currentUser!.uid);
                      setState(() {
                        if (widget.snap['likes']
                            .contains(_auth.currentUser!.uid)) {
                          _isLikeAnimating = true;
                        } else {
                          _isLikeAnimating = false;
                        }
                      });
                    },
                    icon: Icon(
                      Icons.favorite,
                      size: 25.0,
                      color:
                          widget.snap['likes'].contains(_auth.currentUser!.uid)
                              ? Colors.red
                              : Colors.white,
                    )),
              ),
              Text(
                '${widget.snap['likes'].length} likes',
                style: const TextStyle(color: secondaryColor, fontSize: 12.0),
              )
            ],
          )
        ],
      ),
    );
  }
}
