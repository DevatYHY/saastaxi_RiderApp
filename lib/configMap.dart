import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newmap/Models/allUsers.dart';
import 'package:shared_preferences/shared_preferences.dart';

String mapKey = "AIzaSyCOgbUkHnHCmwKQkyQ1X85xv-d7ZJ3dZuI";
String keyOfMap = "9d0571678703425a9c0c24d0573ae6c7";

User firebaseUser;
Users userCurrentInfo;

String serverToken =
    "key=AAAAb2cjVVU:APA91bEzWsrqc8-hZQ2uE3MJ_u1J9ADmqTfrIM5KZLGOqRxibdmnlk95avKzYC8dSSh8Y1KWMfZ79wQiLzEIBEHw_z9k72rKsWlfAQvmzRYTywS-2KO1_tGymgqjzY3O2r_7vXaniILm";

int driverRequestTimeOut = 15;

String statusRide = "";
String carDetailsDriver = "";
String driverName = "";
String driverPhone = "";
String rideStutes = "Driver is Coming ";

double starCounter = 0.0;
String title = "";

String carRideType = "";

Color primary = Color(0xfffdff00);
Color secondary = Color(0xff10316b);
Color backgroundcolor = Color(0xffffffe6);

Color textcolor = Color(0xff191a00);
Color bordercolor = Color(0xfff8f8f8);

String images = "";

bool setonMap = false;
bool isItDropOff = false;

double killo = 0.0;
double commi = 0.0;
SharedPreferences preferences;
