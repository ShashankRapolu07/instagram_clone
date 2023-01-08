import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/user_profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/screens/others_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchbarController = TextEditingController();
  bool _showUsers = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    _searchbarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 70.0,
              backgroundColor: mobileBackgroundColor,
              title: Row(
                children: [
                  _showUsers
                      ? Padding(
                          padding: const EdgeInsets.only(right: 13.0),
                          child: InkWell(
                            onTap: () => setState(() {
                              _showUsers = false;
                              _searchbarController.text = '';
                            }),
                            child: const Icon(Icons.arrow_back),
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.only(right: 13.0),
                          child: Icon(Icons.search),
                        ),
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.white,
                      onSubmitted: (value) => setState(() => _showUsers = true),
                      controller: _searchbarController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.0,
                        ),
                        hintText: 'Search for a user',
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                                topLeft: Radius.circular(15.0),
                                bottomLeft: Radius.circular(15.0))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                                topLeft: Radius.circular(15.0),
                                bottomLeft: Radius.circular(15.0))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: _showUsers
                ? FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .where(
                          'username',
                          isGreaterThanOrEqualTo: _searchbarController.text,
                        ) //note that .where filtering is case-sensitive!!!
                        .get(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No results found'),
                          );
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              if (snapshot.data!.docs[index]['uid'] ==
                                  _auth.currentUser!.uid) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const UserProfileScreen()));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => OtherUserProfile(
                                        uid: snapshot.data!.docs[index]
                                            ['uid'])));
                              }
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    snapshot.data!.docs[index]['ProPicUrl']),
                                radius: 18.0,
                              ),
                              title: Text(
                                snapshot.data!.docs[index]['username'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle:
                                  Text(snapshot.data!.docs[index]['email']),
                            ),
                          ),
                        );
                      }
                      return const Center(
                        child: Text('Some error occurred'),
                      );
                    },
                  )
                : FutureBuilder(
                    future:
                        FirebaseFirestore.instance.collection('posts').get(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text('No content to display'),
                          );
                        }
                        return GridView.custom(
                          gridDelegate: SliverQuiltedGridDelegate(
                            crossAxisCount: 4,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            repeatPattern: QuiltedGridRepeatPattern.inverted,
                            pattern: const [
                              QuiltedGridTile(2, 2),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 2),
                            ],
                          ),
                          childrenDelegate: SliverChildBuilderDelegate(
                              childCount: snapshot.data!.docs.length,
                              (context, index) {
                            try {
                              return Image.network(
                                snapshot.data!.docs[index]['PostPhotoUrl'],
                                fit: BoxFit.cover,
                              );
                            } catch (err) {
                              return Container();
                            }
                          }),
                        );
                      }
                      return const Center(child: Text('Some error occurred'));
                    },
                  )));
  }
}
