import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/profile_buttons.dart';

class OtherUserProfile extends StatefulWidget {
  final uid; //a snap containing respective user details
  const OtherUserProfile({super.key, required this.uid});

  @override
  State<OtherUserProfile> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _buildStatsColumn(int num, String label) {
    return Column(
      children: [
        Text(
          '$num',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
        ),
        const SizedBox(
          height: 7.0,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w400),
        )
      ],
    );
  }

  Future<void> _followUnfollow(
      String other_uid, String current_uid, List followers) async {
    String res = await FirestoreMethods()
        .Follow_Unfollow(other_uid, current_uid, followers);
    if (res != 'success') {
      showSnackBar(context, res);
    } else {
      print(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                profile_snapshot) {
          if (profile_snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: mobileBackgroundColor,
                leading: IconButton(
                  onPressed: () => setState(
                    () => Navigator.of(context).pop(),
                  ),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Text(
                  profile_snapshot.data!['username'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
              ),
              body: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .where('uid', isEqualTo: widget.uid)
                    .get(),
                builder: ((context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        post_snapshot) {
                  if (post_snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (post_snapshot.connectionState ==
                      ConnectionState.done) {
                    return ListView(
                      children: [
                        Column(
                          children: [
                            const SizedBox(
                              height: 5.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        profile_snapshot.data!['ProPicUrl']),
                                    radius: 40.0,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildStatsColumn(
                                            post_snapshot.data!.docs.length,
                                            'Posts'),
                                        _buildStatsColumn(
                                            profile_snapshot
                                                .data!['followers'].length,
                                            'Followers'),
                                        _buildStatsColumn(
                                            profile_snapshot
                                                .data!['following'].length,
                                            'Following')
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile_snapshot.data!['email'],
                                    style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    profile_snapshot.data!['bio'],
                                    style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w300),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ).copyWith(bottom: 5.0),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  profile_snapshot.data!['followers']
                                          .contains(_auth.currentUser!.uid)
                                      ? ProfileButton(
                                          label: 'Following',
                                          barColor: mobileBackgroundColor,
                                          textColor: Colors.white,
                                          borderColor: Colors.white,
                                          width: 165.0,
                                          height: 35.0,
                                          onPressed: () => setState(() =>
                                              _followUnfollow(
                                                  widget.uid,
                                                  _auth.currentUser!.uid,
                                                  profile_snapshot
                                                      .data!['followers'])),
                                        )
                                      : ProfileButton(
                                          width: 165.0,
                                          height: 35.0,
                                          label: 'Follow',
                                          barColor: blueColor,
                                          textColor: Colors.white,
                                          borderColor: blueColor,
                                          onPressed: () => setState(() =>
                                              _followUnfollow(
                                                  widget.uid,
                                                  _auth.currentUser!.uid,
                                                  profile_snapshot
                                                      .data!['followers'])),
                                        ),
                                  const SizedBox(
                                    width: 13.0,
                                  ),
                                  ProfileButton(
                                    width: 165.0,
                                    height: 35.0,
                                    label: 'Message',
                                    barColor:
                                        const Color.fromARGB(255, 79, 75, 75),
                                    textColor: Colors.white,
                                    borderColor:
                                        const Color.fromARGB(255, 79, 75, 75),
                                    onPressed: () => showSnackBar(context,
                                        'We\'re sorry, but this feature is currently not available.'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            post_snapshot.data!.docs.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.only(top: 75.0),
                                    child: const Center(
                                      child: Text('No posts yet'),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: post_snapshot.data!.docs.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 1.5,
                                      childAspectRatio: 1,
                                    ),
                                    itemBuilder: (context, index) {
                                      return Image.network(
                                        post_snapshot.data!.docs[index]
                                            ['PostPhotoUrl'],
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                          ],
                        )
                      ],
                    );
                  }
                  return const Center(
                    child: Text('Some error occurred'),
                  );
                }),
              ),
            ),
          );
        });
  }
}
