import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:newmap/AllScreen/registrationScreen.dart';
import 'package:newmap/AllWidgets/progressDialog.dart';
import 'package:newmap/configMap.dart';
import './registrationScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';
import 'mainscreen.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = "login";
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundcolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 2.0,
              ),
              Image(
                image: AssetImage('images/logo.png'),
                width: 300.0,
                height: 300.0,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 1.0,
              ),
              Text(
                "Login as Rider",
                style: TextStyle(
                  fontFamily: "Brand-Bold",
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    TextFormField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border:OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          ),
                        filled: true,
                        fillColor: bordercolor,
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 18.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border:OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          ),
                        filled: true,
                        fillColor:bordercolor,
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 18.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(height: 50.0,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0))),
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontFamily: "Brand-Bold",
                              fontSize: 18.0,
                             
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (!emailTextEditingController.text.contains("@")) {
                          displaytostMessage(
                              "Email address is not Valid", context);
                        } else if (passwordTextEditingController.text.isEmpty) {
                          displaytostMessage("Enter Password", context);
                        } else {
                          loginAuthenticatUser(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50.0,),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context,
                        RegisterationScreen.idScreen, (route) => false);
                  },
                  child: Text("Do not have an Account ?Register Here",
                  style: TextStyle(color: textcolor),)),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void loginAuthenticatUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Please wait");
        });

    final User firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((erMsg) {
      Navigator.pop(context);
      displaytostMessage(erMsg.noSuchMethod().toString(), context);
    }))
        .user;

    if (firebaseUser != null) {
      userRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);
          displaytostMessage("You are Logged-in now ", context);
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displaytostMessage(
              "User Dose not exists. Please create an Account", context);
        }
      });
    } else {
      Navigator.pop(context);
      displaytostMessage("Error Occured can not SignIn", context);
    }
  }
}

displaytostMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
