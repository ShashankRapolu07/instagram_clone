import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/add_post_screen.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/profile_buttons.dart';

class UserProfileScreen extends StatefulWidget {
  //a snap containing respective user details
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    String res = await AuthMethods().Signout();
    if (res == 'success') {
      showSnackBar(context, 'Signed out successfully');
    } else {
      showSnackBar(context, res);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
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
                title: Text(
                  profile_snapshot.data!['username'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                actions: [
                  IconButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddPostScreen(from_profile: true))),
                      icon: const Icon(Icons.add_a_photo)),
                  const SizedBox(
                    width: 5.0,
                  ),
                ],
              ),
              body: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .where('uid', isEqualTo: _auth.currentUser!.uid)
                    .get(),
                builder: ((context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done) {
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
                                  profile_snapshot.data!['ProPicUrl'] !=
                                          'default'
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              profile_snapshot
                                                  .data!['ProPicUrl']),
                                          radius: 40.0,
                                        )
                                      : const CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              'https://media.istockphoto.com/vectors/default-profile-picture-avatar-photo-placeholder-vector-illustration-vector-id1223671392?k=6&m=1223671392&s=170667a&w=0&h=zP3l7WJinOFaGb2i1F4g8IS2ylw0FlIaa6x3tP9sebU='),
                                          radius: 40.0,
                                        ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildStatsColumn(
                                            snapshot.data!.docs.length,
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
                                    width: 75.0,
                                  ),
                                  ProfileButton(
                                    width: 225.0,
                                    height: 36.0,
                                    label: 'Edit profile',
                                    barColor: mobileBackgroundColor,
                                    textColor: Colors.white,
                                    borderColor: Colors.white,
                                    onPressed: () => showSnackBar(context,
                                        'We\'er sorry, currently this feature is not available.'),
                                  ),
                                  const SizedBox(
                                    width: 15.0,
                                  ),
                                  Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 7.0),
                                      height: 36.0,
                                      width: 40.0,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5.0)),
                                          color: mobileBackgroundColor,
                                          border:
                                              Border.all(color: Colors.white)),
                                      child: IconButton(
                                          onPressed: () async {
                                            await _signOut();
                                            Navigator.of(context).pushReplacement(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen()));
                                          },
                                          icon: const Icon(
                                            Icons.logout,
                                            size: 20.0,
                                          )))
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            snapshot.data!.docs.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.only(top: 75.0),
                                    child: const Center(
                                      child: Text('No posts yet'),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.docs.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 1.5,
                                      childAspectRatio: 1,
                                    ),
                                    itemBuilder: (context, index) {
                                      return Image.network(
                                        snapshot.data!.docs[index]
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
