import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:newmap/AllScreen/otpValidation.dart';
import 'package:newmap/Assistants/requsestAssistant.dart';
import 'package:newmap/DataHandler/appData.dart';
import 'package:newmap/Models/address.dart';
import 'package:newmap/Models/allUsers.dart';
import 'package:newmap/Models/directDetails.dart';
import 'package:newmap/Models/history.dart';
import 'package:newmap/configMap.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";

    String url =
        "https://api.geoapify.com/v1/geocode/reverse?lat=${position.latitude}&lon=${position.longitude}&lang=de&limit=10&apiKey=$keyOfMap";

    var response = await RequstAssistant.getRequest(url);

    if (response != "failed") {
      placeAddress = response["features"][0]["properties"]["address_line1"];
      Address userPickUpAddress = new Address();
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<String> searchCoordinateAddressbytaping(
      LatLng tapedposition, context) async {
    String placeAddress = "";

    String url =
        "https://api.geoapify.com/v1/geocode/reverse?lat=${tapedposition.latitude}&lon=${tapedposition.longitude}&lang=de&limit=10&apiKey=$keyOfMap";

    var response = await RequstAssistant.getRequest(url);

    if (response != "failed") {
      placeAddress = response["features"][0]["properties"]["address_line1"];
      Address userPickUpAddress = new Address();
      userPickUpAddress.latitude = tapedposition.latitude;
      userPickUpAddress.longitude = tapedposition.longitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    print(placeAddress);
    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://api.geoapify.com/v1/routing?waypoints=${initialPosition.latitude},${initialPosition.longitude}|${finalPosition.latitude},${finalPosition.longitude}&mode=drive&apiKey=$keyOfMap";

    var res = await RequstAssistant.getRequest(directionUrl);
    if (res == "failed") {
      return null;
    }
    //***********change valu */
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.points = res["features"][0]["geometry"]["coordinates"][0];
    directionDetails.distanceValue =
        res["features"][0]["properties"]["distance"];
    directionDetails.time = (res["features"][0]["properties"]["time"] / 60);

    return directionDetails;
  }  
 

  static int calculateFares(DirectionDetails directionDetails) {
  
    double timeTraveledFare = (directionDetails.time / 60) * 0.20;
    double distancTraveledFare = (directionDetails.distanceValue / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distancTraveledFare;
    double totlaLoalAmont = totalFareAmount * killo;

    return totlaLoalAmont.toInt();
  }

  static void getCurrentOnlineUserInfo(context) async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("user").child(userId);
    reference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        userCurrentInfo = Users.fromSnapshot(dataSnapshot);
        Provider.of<AppData>(context, listen: false)
            .updateProfile(userCurrentInfo);
      }
    });
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int radNumber = random.nextInt(num);
    return radNumber.toDouble();
  }

  static sendNotificationtoDriver(
      // ignore: non_constant_identifier_names
      String token,
      context,
      String ride_request_id) async {
    // var destination =
    //     Provider.of<AppData>(context, listen: false).dropOffLocation;
    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverToken,
    };

    Map notificationMap = {
      'body': 'New Ride Request',
      'title': 'New Ride Request'
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_request_id': ride_request_id,
    };
    Map sendNotificationMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token
    };

    // ignore: unused_local_variable
    var res = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headerMap, body: jsonEncode(sendNotificationMap));
  }

  static String formatTripDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        "${DateFormat.MMMd().format(dateTime)},${DateFormat.y().format(dateTime)}-${DateFormat.jm().format(dateTime)}";

    return formattedDate;
  }

  static void retrieveHistoryInfo(context) {
    //retrieve and display Trip History
    newRequestsRef
        .orderByChild("rider_name")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        //update total number of trip count to provider
        Map<dynamic, dynamic> keys = dataSnapshot.value;
        int tripCounter = keys.length;
        Provider.of<AppData>(context, listen: false)
            .updateTripsCounter(tripCounter);
//update tripkeys to provider
        List<String> tripHistoryKeys = [];
        keys.forEach((key, value) {
          tripHistoryKeys.add(key);
        });
        Provider.of<AppData>(context, listen: false)
            .updateTripkeys(tripHistoryKeys);
        obtainTripRequestsHistoryData(context);
      }
    });
  }

  static obtainTripRequestsHistoryData(context) {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;
    for (String key in keys) {
      newRequestsRef.child(key).once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          newRequestsRef
              .child(key)
              .child("rider_name")
              .once()
              .then((DataSnapshot dSnap) {
            String name = dSnap.value.toString();
            if (name == userCurrentInfo.name) {
              var history = History.fromSnapshot(snapshot);
              Provider.of<AppData>(context, listen: false)
                  .updateTripHistoryData(history);
            }
          });
        }
      });
    }
  }

  static void loadimage() async {
    // ignore: unused_local_variable
    var photo = "";

    userRef
        .child(firebaseUser.uid)
        .child("photo")
        .once()
        .then((DataSnapshot snapshot) async {
      if (snapshot.value != null) {
        photo = snapshot.value;
      }
    });
  }

  String photos = "";
  loadFromPrf() async {
    final prefs = await SharedPreferences.getInstance();
    final photo = prefs.getString("photo");
    photos = photo;
  }

   static Future otpmesseage(int phone, String mes, BuildContext context) async {
    String otpurl =
        "https://mazinhost.com/smsv1/sms/api?action=send-sms&api_key=YWxhbWluc29mdDpOaWxlcG93cjU2MjY=&to=${phone}&from=SAASTAXI&sms=$mes";
    var res = await RequstAssistant.getRequest(otpurl);
    if (res == "failed") {
      return null;
    } else {
      var x = res['code'];

      if (x == 'ok') {
        Navigator.pushNamed(context, OtpValidation.idScreen);
      }
    }
  }
}
