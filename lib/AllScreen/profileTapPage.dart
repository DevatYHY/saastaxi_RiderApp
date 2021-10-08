// ignore: unused_import
import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';

import 'package:newmap/AllScreen/loginScreen.dart';
import 'package:newmap/Assistants/assistantMethod.dart';
import 'package:newmap/DataHandler/appData.dart';
import 'package:newmap/configMap.dart';
import 'package:newmap/main.dart';
import 'package:provider/provider.dart';
import 'package:newmap/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'mainscreen.dart';

class ProfileTabPage extends StatefulWidget {
  @override
  _ProfileTabPageState createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  File _image;
  String uname = "";

  final picker = ImagePicker();
  TextEditingController name = TextEditingController();

  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  // TextEditingController password = TextEditingController();
  double profileContiner = 322.0;
  double profileEditContiner = 0.0;
  bool profileEdit = false;
  double editIcon = 0.0;
  double editIconsize = 0.0;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  saveToPrf() async {
    preferences = await SharedPreferences.getInstance();

    Provider.of<AppData>(context, listen: false).updateProfile(userCurrentInfo);
    preferences.setString(
        "photo", Provider.of<AppData>(context, listen: false).user.image);
    preferences.setString(
        "name", Provider.of<AppData>(context, listen: false).user.name);
    preferences.setString(
        "phone", Provider.of<AppData>(context, listen: false).user.phone);
    preferences.setString(
        "email", Provider.of<AppData>(context, listen: false).user.email);
  }

  @override
  initState() {
    super.initState();

    AssistantMethods.loadimage();
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            elevation: 0.5,
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context).profile,
              style: TextStyle(
                  fontFamily: "segoebold", color: textcolor, fontSize: 28),
            ),
            backgroundColor: primary,
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, MainScreen.idScreen, (route) => false);
                },
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: textcolor,
                  size: 45,
                )),
          ),
          backgroundColor: bordercolor,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Positioned(
                  top: 0.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: textcolor,
                        width: MediaQuery.of(context).size.width,
                        height: 90.0,
                      ),
                      SizedBox(
                        height: 65,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * .25,
                  right: MediaQuery.of(context).size.width * .25,
                  top: 65,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: primary),
                      child: CircleAvatar(
                        backgroundImage: AssetImage("images/user_icon.png"),
                        radius: 50,
                        child: ClipOval(
                            child: images != null
                                ? Image.memory(
                                    base64Decode(images),
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                    alignment: Alignment.center,
                                  )
                                : Image.asset("images/user_icon.png")),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * .25,
                  right: MediaQuery.of(context).size.width * .07,
                  top: 55,
                  child: Container(
                    height: editIcon,
                    child: GestureDetector(
                      onTap: () async {
                        await getImage();
                        await updatephoto();
                      },
                      child: CircleAvatar(
                        child: Icon(
                          Icons.edit,
                          color: primary,
                          size: editIconsize,
                        ),
                        backgroundColor: textcolor,
                        radius: 15,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 175,
                  left: 24,
                  right: 24,
                  bottom: 0.0,
                  child: Container(
                    height: profileContiner,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(
                              Provider.of<AppData>(context, listen: false)
                                          .user !=
                                      null
                                  ? Provider.of<AppData>(context, listen: false)
                                      .user
                                      .name
                                  : "",
                              style: TextStyle(
                                  color: textcolor,
                                  fontSize: 26,
                                  fontFamily: "segoe",
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          // SizedBox(
                          //   height: 25,
                          // ),

                          SizedBox(
                            height: 10,
                          ),
                          Card(
                            child: ListTile(
                              leading: Text(
                                AppLocalizations.of(context).email,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: "segoebold",
                                    fontSize: 14),
                              ),
                              title: Text(
                                Provider.of<AppData>(context, listen: false)
                                            .user !=
                                        null
                                    ? Provider.of<AppData>(context,
                                            listen: false)
                                        .user
                                        .email
                                    : "",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  fontFamily: "segoebold",
                                ),
                              ),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Text(
                                AppLocalizations.of(context).phonenumbere,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: "segoebold",
                                    fontSize: 14),
                              ),
                              title: Text(
                                Provider.of<AppData>(context, listen: false)
                                            .user !=
                                        null
                                    ? Provider.of<AppData>(context,
                                            listen: false)
                                        .user
                                        .phone
                                    : "",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  fontFamily: "segoebold",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 80,
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  profileContiner = 0.0;
                                  profileEditContiner = 322.0;
                                  profileEdit = false;
                                  editIcon = 30.0;
                                  editIconsize = 20;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: textcolor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                              child: Container(
                                width: 60,
                                height: 40.0,
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context).edit,
                                    style: TextStyle(
                                        fontFamily: "segoebold",
                                        fontSize: 18.0,
                                        color: primary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.30,
                  left: 24,
                  right: 24,
                  child: Center(
                    child: AnimatedContainer(
                      height: profileEditContiner,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: bordercolor,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10.0,
                                spreadRadius: 0.9,
                                offset: Offset(0.0, 0.0),
                                color: profileEdit == true
                                    ? Colors.transparent
                                    : textcolor.withOpacity(.25))
                          ]),
                      duration: Duration(
                        milliseconds: 500,
                      ),
                      curve: Curves.linearToEaseOut,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Card(
                              child: ListTile(
                                leading: Text(
                                  AppLocalizations.of(context).name,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "segoebold",
                                      fontSize: 14),
                                ),
                                title: TextField(
                                  onChanged: (val) {},
                                  controller: name,
                                  decoration: InputDecoration(
                                    focusColor: primary,
                                    hoverColor: primary,
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: textcolor)),
                                    hintText: userCurrentInfo.name,
                                    hintStyle: TextStyle(
                                        color: textcolor.withOpacity(0.25),
                                        fontFamily: "segoe"),
                                    labelStyle: TextStyle(
                                        fontSize: 14.0, color: textcolor),
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 11.0, top: 8.0, bottom: 8.0),
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              child: ListTile(
                                leading: Text(
                                  AppLocalizations.of(context).phonenumbere,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "segoebold",
                                      fontSize: 14),
                                ),
                                title: TextField(
                                  onChanged: (val) {},
                                  maxLength: 10,
                                  keyboardType: TextInputType.phone,
                                  controller: phone,
                                  decoration: InputDecoration(
                                    focusColor: primary,
                                    hoverColor: primary,
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: textcolor)),
                                    hintText: userCurrentInfo.phone,
                                    hintStyle: TextStyle(
                                        color: textcolor.withOpacity(0.25),
                                        fontFamily: "segoe"),
                                    labelStyle: TextStyle(
                                        fontSize: 14.0, color: textcolor),
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 11.0, top: 8.0, bottom: 8.0),
                                  ),
                                ),
                              ),
                            ),
                            // Card(
                            //   child: ListTile(
                            //     leading: Text(
                            //       "Email",
                            //       style: TextStyle(
                            //           color: Colors.grey,
                            //           fontFamily: "segoebold",
                            //           fontSize: 14),
                            //     ),
                            //     title: TextField(
                            //       onChanged: (val) {},
                            //       controller: email,
                            //       decoration: InputDecoration(
                            //         focusColor: primary,
                            //         hoverColor: primary,
                            //         focusedBorder: UnderlineInputBorder(
                            //             borderSide:
                            //                 BorderSide(color: textcolor)),
                            //         hintText: userCurrentInfo.email,
                            //         hintStyle: TextStyle(
                            //             color: textcolor.withOpacity(0.25),
                            //             fontFamily: "segoe"),
                            //         labelStyle: TextStyle(
                            //             fontSize: 14.0, color: textcolor),
                            //         isDense: true,
                            //         contentPadding: EdgeInsets.only(
                            //             left: 11.0, top: 8.0, bottom: 8.0),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                              height: 50,
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    profileContiner = 322.0;
                                    profileEditContiner = 0.0;
                                    profileEdit = true;
                                    editIcon = 0.0;
                                    editIconsize = 0.0;
                                    // x = x;
                                  });

                                  updateuser();
                                  // updateUser(context, email.text.toString());
                                  updatephoto();
                                  saveToPrf();
                                  print("+++++++++++++++++++++");
                                  // print(preferences.getString(firebaseUser.uid));
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: textcolor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
                                child: Container(
                                  width: 60,
                                  height: 40.0,
                                  child: Center(
                                    child: Text(
                                      "Save",
                                      style: TextStyle(
                                          fontFamily: "segoebold",
                                          fontSize: 18.0,
                                          color: primary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  updateuser() {
    try {
      if (firebaseUser != null) {
        if (name.text != null && name.text != "") {
          userRef.child(firebaseUser.uid).child("name").set(name.text);
          userCurrentInfo.name = name.text;
        } else {
          displaytostMessage("Enter name", context);
        }
        if (phone.text != null && phone.text != "") {
          if (phone.text.contains('09') || phone.text.contains('01')) {
            userRef.child(firebaseUser.uid).child("phone").set(phone.text);
            userCurrentInfo.phone = phone.text;
          }
        } else {
          displaytostMessage("Enter phone Number", context);
        }

        // if (email.text != null &&
        //     email.text.contains("@") &&
        //     email.text.contains(".com")) {
        //   userRef.child(firebaseUser.uid).child("email").set(email.text);
        //   userCurrentInfo.email = email.text;

        //   displaytostMessage("profile Updated", context);
        //   Provider.of<AppData>(context, listen: false)
        //       .updateProfile(userCurrentInfo);
        // } else {
        //   displaytostMessage("Enter the Email", context);
        // }
      }
    } catch (e) {
      print(e.toString());
    }
    email.clear();
    phone.clear();
    name.clear();
  }

  updatephoto() {
    userRef
        .child(firebaseUser.uid)
        .child("photo")
        .set(Utility.base64String(_image.readAsBytesSync()));

    images = Utility.base64String(_image.readAsBytesSync());
  }
}
