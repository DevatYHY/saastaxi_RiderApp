import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newmap/AllScreen/loginScreen.dart';
import 'package:newmap/AllScreen/mainscreen.dart';
import 'package:newmap/AllScreen/otpScreen.dart';
import 'package:newmap/AllWidgets/progressDialog.dart';
import 'package:newmap/Assistants/assistantMethod.dart';
import 'package:newmap/DataHandler/appData.dart';
import 'package:newmap/main.dart';
import 'package:newmap/configMap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'otpValidation.dart';

// ignore: must_be_immutable
class RegisterationScreen extends StatefulWidget {
  static const String idScreen = "register";

  @override
  _RegisterationScreenState createState() => _RegisterationScreenState();
}

class _RegisterationScreenState extends State<RegisterationScreen> {
  TextEditingController nameTextEditingController = TextEditingController();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

    TextEditingController confirmpasswordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/mainblurred.jpg"),
                fit: BoxFit.cover)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 80.0,
                ),
                Image(
                  image: AssetImage('images/logo.png'),
                  width: 100.0,
                  height: 100.0,
                  alignment: Alignment.center,
                ),
                SizedBox(
                  height: 1.0,
                ),
                Text(
                  "Saas Taxi",
                  style: TextStyle(
                      fontFamily: "segoebold", fontSize: 28, color: primary),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 14.0,
                      ),
                      TextFormField(
                        controller: nameTextEditingController,
                        keyboardType: TextInputType.text,
                        cursorColor: primary,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                  color: primary, style: BorderStyle.solid)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: primary)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: primary)),
                          labelText: AppLocalizations.of(context).name,
                          labelStyle: TextStyle(
                              fontSize: 14.0,
                              color: backgroundcolor,
                              fontFamily: "segoe"),
                          hintStyle: TextStyle(
                              color: backgroundcolor,
                              fontSize: 18.0,
                              fontFamily: "segoe"),
                        ),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: backgroundcolor,
                            fontFamily: "segoe"),
                      ),
                      SizedBox(
                        height: 14.0,
                      ),
                      TextFormField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: primary,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                  color: primary, style: BorderStyle.solid)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: primary)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: primary)),
                          labelText: AppLocalizations.of(context).email,
                          labelStyle: TextStyle(
                              fontSize: 14.0,
                              color: backgroundcolor,
                              fontFamily: "segoe"),
                          hintStyle: TextStyle(
                              color: backgroundcolor,
                              fontSize: 18.0,
                              fontFamily: "segoe"),
                        ),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: backgroundcolor,
                            fontFamily: "segoe"),
                      ),
                      SizedBox(
                        height: 14.0,
                      ),
                      TextFormField(
                        // onChanged: (String newVal) {
                        // if (newVal.length == 9) {

                        // }
                        maxLength: 9,
                        controller: phoneTextEditingController,
                        
                        keyboardType: TextInputType.phone,
                        cursorColor: primary,
                        decoration: InputDecoration(
                           prefixText: "+249 ",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                  color: primary, style: BorderStyle.solid)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: primary)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: primary)),
                          labelText: AppLocalizations.of(context).phonenumbere,
                          labelStyle: TextStyle(
                              fontSize: 14.0,
                              color: backgroundcolor,
                              fontFamily: "segoe"),
                                hintText: "9 XXX XXXXX",
                  hintStyle: TextStyle(
                      letterSpacing: 2.0,
                      color: backgroundcolor,
                      fontSize: 14.0,
                      fontFamily: "segoe"),
                        
                        ),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: backgroundcolor,
                            fontFamily: "segoe"),
                      ),
                      SizedBox(
                        height: 14.0,
                      ),
                      TextFormField(
                        controller: passwordTextEditingController,
                        obscureText: true,
                        cursorColor: primary,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                  color: primary, style: BorderStyle.solid)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: primary)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: primary)),
                          labelText: AppLocalizations.of(context).password,
                          labelStyle: TextStyle(
                              fontSize: 14.0,
                              color: backgroundcolor,
                              fontFamily: "segoe"),
                          hintStyle: TextStyle(
                              color: backgroundcolor,
                              fontSize: 18.0,
                              fontFamily: "segoe"),
                        ),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: backgroundcolor,
                            fontFamily: "segoe"),
                      ),
                      SizedBox(
                        height: 14.0,
                      ),
                       TextFormField(
                        controller: confirmpasswordTextEditingController,
                        obscureText: true,
                        cursorColor: primary,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                  color: primary, style: BorderStyle.solid)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: primary)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: primary)),
                          labelText: AppLocalizations.of(context).confirmpassword,
                          labelStyle: TextStyle(
                              fontSize: 14.0,
                              color: backgroundcolor,
                              fontFamily: "segoe"),
                          hintStyle: TextStyle(
                              color: backgroundcolor,
                              fontSize: 18.0,
                              fontFamily: "segoe"),
                        ),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: backgroundcolor,
                            fontFamily: "segoe"),
                      ),
                      SizedBox(
                        height: 36.0,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0))),
                        child: Container(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context).createaccount,
                              style: TextStyle(
                                  fontFamily: "segoebold",
                                  fontSize: 18.0,
                                  color: textcolor),
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
                          } else if (phoneTextEditingController.text.length>9) {
                            displaytostMessage(
                                "Phone Number is not Valid", context);
                          }else if (phoneTextEditingController.text.length<9) {
                            displaytostMessage(
                                "Phone Number is not Valid", context);
                          } else if (passwordTextEditingController.text.length <
                              6) {
                            displaytostMessage(
                                "Password must be atleast 6 Character",
                                context);
                          }
                           else if (passwordTextEditingController.text != confirmpasswordTextEditingController.text) {
                            displaytostMessage(
                                "password msut be match",
                                context);
                          } else {
                            registerNewUser(context);
                          }
                        },
                      ),
                      SizedBox(
                        height: 24,
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).haveanaccount,
                      style: TextStyle(
                          fontFamily: "segoe", color: backgroundcolor),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, LoginScreen.idScreen, (route) => false);
                        },
                        child: Text(
                          " " + AppLocalizations.of(context).login,
                          style: TextStyle(
                              fontFamily: "segoebold", color: primary),
                        )),
                  ],
                ),
              ],
            ),
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
 int x = int.parse('249' + phoneTextEditingController.text);
      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text
      };
      userRef.child(firebaseUser.uid).set(userDataMap);
      displaytostMessage(
          "Cogratulation, your account has been created", context);
      Provider.of<AppData>(context, listen: false)
          .getphone(int.parse('249'+phoneTextEditingController.text));
      // Navigator.pushNamedAndRemoveUntil(
      //     context, MainScreen.idScreen, (route) => false);
                  isNumberExist();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, OtpValidation.idScreen);
                    await AssistantMethods.otpmesseage(
                        x, "SAASTAXI Verification Code : $ran", context);
    } else {
      Navigator.pop(context);
      //error occurd display msg
      displaytostMessage("User has not been Created ", context);
    }
  }

  displaytostMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }

   int ran = 0;

  void isNumberExist() {
    var rnd = new Random();
    var next = rnd.nextDouble() * 1000;
    while (next < 1000) {
      next *= 10;
    }
    ran = next.toInt();
    Provider.of<AppData>(context, listen: false).getRandomNumber(next.toInt());
    print("+++++++++++++");
    print(Provider.of<AppData>(context, listen: false).randomNumber);
    print("+++++++++++++");
  }
}
