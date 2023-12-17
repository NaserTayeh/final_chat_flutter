// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:chat_finaly/api/apis.dart';
import 'package:chat_finaly/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../widget/my_button.dart';

import '../widget/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String pass;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Container(
              //   height: 180,
              //   child: Image.asset(
              //     'images/logo.png',
              //     errorBuilder: (context, error, stackTrace) {
              //       return Icon(Icons.sim_card_alert_outlined);
              //     },
              //   ),
              // ),
              SizedBox(height: 50),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your Email',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.orange,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  pass = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.orange,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              MyButton(
                color: Colors.blue[800]!,
                title: 'register',
                onPressed: () async {
                  // log(email);
                  // log(pass);
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    _auth
                        .signInWithEmailAndPassword(
                            email: email, password: pass)
                        .then((value) async {
                      if (value != null) {
                        log('\n User : ${value.user}');
                        log('\n User Add info : ${value.additionalUserInfo}');

                        if ((await APIs.userExsist())) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return HomeScreen();
                            },
                          ));
                        } else {
                          APIs.createUser().then((value) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return HomeScreen();
                              },
                            ));
                          });
                        }
                      }
                    });
                    // final newUser = await _auth.createUserWithEmailAndPassword(
                    //     email: email, password: pass);
                    // showSpinner = false;
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (context) {
                    //     return HomeScreen();
                    //   },
                    // ));

                    setState(() {});
                  } on Exception catch (e) {
                    // print
                    log('exc occur');
                    print(e);

                    setState(() {
                      showSpinner = false;
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
