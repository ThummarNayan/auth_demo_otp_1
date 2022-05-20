import 'package:auth_demo_otp_1/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DashBoard extends StatefulWidget {
  UserCredential? userCredential;

  DashBoard({this.userCredential});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () async {
              if(widget.userCredential?.credential?.providerId == "google.com"){
                 await FirebaseAuth.instance.signOut();
                 await GoogleSignIn().signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return MyApp();
                },));
              }
              else{
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return MyApp();
                },));
              }
            },

            child: Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [Text("Log Out")],
      ),
    );
  }
}
