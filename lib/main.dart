import 'package:auth_demo_otp_1/bashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController sendotp = TextEditingController();
  TextEditingController verifyotp = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  String? vId;

  String smsCode = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return DashBoard();
          },
        ));
        print('User is signed in!');
      }
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("OTP"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextField(
                controller: sendotp,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  prefixText: "+91",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            OTPTextField(
              onChanged: (value) {
                setState(() {
                  smsCode = value;
                });
              },
              length: 6,
              width: MediaQuery.of(context).size.width,
              fieldWidth: 45,
              style: TextStyle(
                fontSize: 12,
              ),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.box,
              onCompleted: (pin) {
                print("Complated" + pin);
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: "+91${sendotp.text}",
                    verificationCompleted: (PhoneAuthCredential credential) {},
                    verificationFailed: (FirebaseAuthException e) {
                      if (e.code == 'invalid-phone-number') {
                        print('The provided phone number is  not invalid');
                      }
                    },
                    codeSent: (String verificationId, int? resendToken) {
                      setState(() {
                        vId = verificationId;
                      });
                      print(vId);
                      print(verificationId);
                    },
                    codeAutoRetrievalTimeout: (String verificationId) {},
                  );
                },
                child: Text("Send Otp")),
            ElevatedButton(
                onPressed: () async {
                  // String smsCode = verifyotp.text;

                  // Create a PhoneAuthCredential with the code
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: vId ?? "", smsCode: smsCode);
                  print(smsCode);

                  // Sign the user in (or link) with the credential
                  await auth.signInWithCredential(credential);
                },
                child: Text("Verify Otp")),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                signInWithGoogle().then((value) {
                  print("=============>${value}");
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return DashBoard(
                        userCredential: value,
                      );
                    },
                  ));
                });
              },
              child: Container(
                height: 50,
                width: 50,
                child: Image(image: AssetImage("image/google.png")),
              ),
            ),
            GestureDetector(
              child: Container(
                height: 50,
                width: 50,
                child: IconButton(onPressed: () {
                  signInWithFacebook().then((value) {

                  });
                }, icon: Icon(Icons.facebook)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
