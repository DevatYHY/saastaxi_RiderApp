import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newmap/AllScreen/loginScreen.dart';
import 'package:newmap/AllScreen/mainscreen.dart';
import 'package:newmap/AllWidgets/progressDialog.dart';
import 'package:newmap/main.dart';

class RegisterationScreen extends StatelessWidget {
  static const String idScreen = "register";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                "Register as Rider",
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
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 18.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextFormField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 18.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextFormField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 18.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextFormField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
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
                    RaisedButton(
                      color: Colors.yellow,
                      textColor: Colors.white,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                              fontFamily: "Brand-Bold",
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (nameTextEditingController.text.length < 3) {
                          displaytostMessage(
                              "name must be atleast 3 Character", context);
                        } else if (!emailTextEditingController.text
                            .contains("@")) {
                          displaytostMessage(
                              "Email address is not Valid", context);
                        } else if (phoneTextEditingController.text.isEmpty) {
                          displaytostMessage(
                              "Phone Number is not Valid", context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          displaytostMessage(
                              "Password must be atleast 6 Character", context);
                        } else {
                          registerNewUser(context);
                        }
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0)),
                    ),
                  ],
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                  },
                  child: Text("Allready have an Account ?Register Here")),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  registerNewUser(BuildContext context) async {
 showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Please wait");
        });

    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((erMsg) {
              Navigator.pop(context);
      displaytostMessage("Error" + erMsg.toString(), context);
    }))
        .user;
    if (firebaseUser != null) //user created
    {
      // save into database

      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text
      };
      userRef.child(firebaseUser.uid).set(userDataMap);
      displaytostMessage(
          "Cogratulation, your account has been created", context);

      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
      //error occurd display msg
      displaytostMessage("User has not been Created ", context);
    }
  }

  displaytostMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
