import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comments_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  final snap; // document containing single post details
  PostCard({required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLikeAnimating = false;
  bool _smallLike = false;
  final FirestoreMethods _firestore = FirestoreMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _deletePost() async {
    String res = await _firestore.deletePost(widget.snap['postId']);
    if (res == 'success') {
      showSnackBar(context, 'Post deleted sucessfully.');
    } else {
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .snapshots(),
        builder: ((context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          return Container(
            padding: const EdgeInsets.only(bottom: 15.0),
            color: mobileBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 10.0)
                      .copyWith(right: 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(widget.snap['ProPicUrl']),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                      PopupMenuButton(onSelected: (value) {
                        if (value == 0) {
                          setState(
                            () => _deletePost(),
                          );
                        } else if (value == 1) {
                          showSnackBar(context,
                              'We\'er sorry, but this feature is currently not available.');
                        }
                      }, itemBuilder: (context) {
                        List items1 = [
                          const PopupMenuItem(value: 0, child: Text('delete')),
                          const PopupMenuItem(value: 1, child: Text('report'))
                        ];
                        List items2 = [
                          const PopupMenuItem(value: 1, child: Text('report'))
                        ];
                        if (widget.snap['uid'] == _auth.currentUser!.uid) {
                          return items1.cast();
                        } else {
                          return items2.cast();
                        }
                      })
                    ],
                  ),
                ),

                //Image Section
                GestureDetector(
                  onDoubleTap: () async {
                    if (widget.snap['likes'].contains(_auth.currentUser!.uid) ==
                        false) {
                      await _firestore.likePost(widget.snap['postId'],
                          _auth.currentUser!.uid, widget.snap['likes']);
                    }
                    setState(() {
                      _isLikeAnimating = true;
                      _smallLike = true;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.43,
                        child: Container(
                          color: const Color.fromARGB(52, 158, 158, 158),
                          child: Image.network(
                            widget.snap['PostPhotoUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: _isLikeAnimating ? 1 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: LikeAnimation(
                            isAnimating: _isLikeAnimating,
                            duration: const Duration(milliseconds: 150),
                            child: const Icon(
                              Icons.favorite,
                              size: 90,
                              color: Color.fromARGB(255, 236, 10, 10),
                            ),
                            onEnd: () {
                              setState(() {
                                _isLikeAnimating = false;
                              });
                            }),
                      ),
                    ],
                  ),
                ),

                //Like, Comment, Send and Bookmark Section
                Row(
                  children: [
                    LikeAnimation(
                      onEnd: () => setState(() {
                        _isLikeAnimating = false;
                      }),
                      isAnimating: _isLikeAnimating,
                      duration: const Duration(milliseconds: 150),
                      child: IconButton(
                          onPressed: () async {
                            await _firestore.likePost(widget.snap['postId'],
                                _auth.currentUser!.uid, widget.snap['likes']);
                            setState(() {
                              if (widget.snap['likes']
                                  .contains(_auth.currentUser!.uid)) {
                                _isLikeAnimating = true;
                                _smallLike = true;
                              } else {
                                _isLikeAnimating = false;
                                _smallLike = false;
                              }
                            });
                          },
                          icon: Icon(
                            Icons.favorite,
                            size: 26.0,
                            color: widget.snap['likes']
                                    .contains(_auth.currentUser!.uid)
                                ? Colors.red
                                : Colors.white,
                          )),
                    ),
                    IconButton(
                        onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    CommentsScreen(snap: widget.snap),
                              ),
                            ),
                        icon: const Icon(
                          Icons.comment_outlined,
                          size: 26.0,
                        )),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.send,
                          size: 26.0,
                        )),
                    Expanded(
                      child: Align(
                        // for aligning bookmark button to the right of expanded widget
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.bookmark_outline)),
                      ),
                    )
                  ],
                ),

                // Text content part
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.snap['likes'].length} likes',
                          style: const TextStyle(
                              color: secondaryColor, fontSize: 16.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: RichText(
                            text: TextSpan(
                                style: const TextStyle(
                                    color: primaryColor, fontSize: 15.0),
                                children: [
                                  TextSpan(
                                      text: '${widget.snap['username']} ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: widget.snap['description'])
                                ]),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              'View all ${snapshot.hasData ? snapshot.data!.docs.length : 'X'} comments',
                              style: const TextStyle(
                                  color: secondaryColor, fontSize: 16.0),
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              DateFormat.yMMMd().format(
                                  widget.snap['datePublished'].toDate()),
                              style: const TextStyle(color: secondaryColor),
                            ))
                      ],
                    ))
              ],
            ),
          );
        }));
  }
}
