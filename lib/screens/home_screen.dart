import 'dart:developer';

import 'package:chat_finaly/api/apis.dart';
import 'package:chat_finaly/auth/profile_screen.dart';
import 'package:chat_finaly/model/chat_user.dart';
import 'package:chat_finaly/widget/chat_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../helper/dialogs.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> list = [];
  // for storing searched users
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('message :$message');
      if (APIs.firebaseAuth.currentUser != null) {
        if (message!.contains('pause')) {
          APIs.updateActiveStatus(false);
        }
        if (message!.contains('resume')) {
          APIs.updateActiveStatus(true);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            backgroundColor: Colors.white38,
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Name, Email, ...'),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    //when search text changes then updated search list
                    onChanged: (val) {
                      //search logic
                      _searchList.clear();
                      log(val.isNotEmpty.toString());
                      for (var i in list) {
                        if ((i.name.toLowerCase().contains(val.toLowerCase()) ||
                                i.email
                                    .toLowerCase()
                                    .contains(val.toLowerCase())) &&
                            val.isNotEmpty) {
                          log('im here');
                          _searchList.add(i);
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    },
                  )
                : const Text('ميد باي ناصر التايه'),
            actions: [
              //search user button
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              IconButton(
                  onPressed: () {
                    // setState(() {
                    //   _isSearching = !_isSearching;
                    // });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: APIs.me,
                                )));
                  },
                  icon: Icon(Icons.more_vert)),
            ],
          ),
          body: StreamBuilder(
            // stream: FirebaseFirestore.instance.collection('users').snapshots(),
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                // if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                // if some or all data is loadde then show it
                case ConnectionState.active:
                case ConnectionState.done:

                  // if (snapshot.hasData) {
                  final data = snapshot.data!.docs;
                  // data here is all the document in collectoin"user"
                  // i here represent one document in the collection user
                  // for (var i in data) {
                  //   log('Data: ${i.data()}');
                  //   list.add(i.data()['name']);
                  // }
                  // }
                  list = data.map((e) => ChatUser.fromJson(e.data())).toList();
                  if (list.isNotEmpty) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user: _isSearching ? _searchList[index] : list[index],
                        );
                      },
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02),
                      itemCount:
                          _isSearching ? _searchList.length : list.length,
                      physics: const BouncingScrollPhysics(),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'No Connections Found!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                    );
                  }
              }
            },
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
                onPressed: () async {
                  _addChatUserDialog();
                },
                child: const Icon(Icons.add_comment_rounded)),
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackbar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
