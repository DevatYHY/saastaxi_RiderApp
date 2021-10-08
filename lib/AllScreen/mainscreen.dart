import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:newmap/AllScreen/AboutScreen.dart';
import 'package:newmap/AllScreen/HistoryScreen.dart';
import 'package:newmap/AllScreen/SettingScreen.dart';
import 'package:newmap/AllScreen/loginScreen.dart';
import 'package:newmap/AllScreen/profileTapPage.dart';
import 'package:newmap/AllScreen/ratingScreen.dart';
import 'package:newmap/AllScreen/searchScreen.dart';
import 'package:newmap/AllWidgets/collectFareDialog.dart';
import 'package:newmap/AllWidgets/noDriverAvailableDialog.dart';
import 'package:newmap/AllWidgets/progressDialog.dart';
import 'package:newmap/Assistants/assistantMethod.dart';
import 'package:newmap/Assistants/geofireAssistant.dart';
import 'package:newmap/Assistants/requsestAssistant.dart';
import 'package:newmap/DataHandler/appData.dart';
import 'package:newmap/Models/address.dart';
import 'package:newmap/Models/directDetails.dart';
import 'package:newmap/Models/nearybyAvailableDrivers.dart';
import 'package:newmap/configMap.dart';
import 'package:newmap/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  List<LatLng> plineCoordinates = [];
  Set<Polyline> polyLineSet = {};

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails tripdirectionDetails;

  double bottompaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  //kllo

  double rideDetailsContanerheigt = 0;
  double searchContainerheigt = 50.0;
  double requstRideContanerheigt = 0;
  double driverDetailsContainerHeight = 0;
  double isTappedMapheight = 0;
  double confirmbtnheight = 0.0;
  double bottomContainerheigt = 120.0;
  double serchiconSize = 24.0;

  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded = false;

  DatabaseReference rideRequestRef;

  BitmapDescriptor nearbyIcon;

  List<NearbyAvailableDrivers> availableDrivers;

  String state = "normal";
  // ignore: cancel_subscriptions
  StreamSubscription<Event> ridestreamSubscription;

  bool isRequestingPositionDetails = false;

  String uName = "";
  String phone = "";

  void config() {
    configref.once().then((DataSnapshot snap) {
      if (snap != null) {
        double commission = double.parse(snap.value["commission"]);
        double killometer = double.parse(snap.value["killometer"]);
        Provider.of<AppData>(context, listen: false)
            .get_config(commission, killometer);
        commi = Provider.of<AppData>(context, listen: false).commission;
        killo = Provider.of<AppData>(context, listen: false).killometer;

        print(commission);
        print(killometer);
      } else {
        print("++++++++++++++++++++++++++++++++++++++++++++++++++");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo(context);
    AssistantMethods.loadimage();
    getlocale(context);
    config();
    if (isItDropOff == true) {
      displayconfirmbtn();
    }
  }

  static getlocale(BuildContext context) async {
    preferences = await SharedPreferences.getInstance();
    bool local = preferences.getBool('locale');
    if (local != null) {
      if (local) {
        Provider.of<AppData>(context, listen: false).changeLocale(Locale('ar'));
      } else {
        Provider.of<AppData>(context, listen: false).changeLocale(Locale('en'));
      }
    }
  }

  void saveRideRequest() async {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;

    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString()
    };

    Map dropOffLocMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString()
    };

    Map rideinfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
      "ride_type": carRideType,
    };

    rideRequestRef.set(rideinfoMap);

    ridestreamSubscription = rideRequestRef.onValue.listen((event) async {
      if (event.snapshot.value == null) {
        return;
      }
      if (event.snapshot.value["car_details"] != null) {
        setState(() {
          carDetailsDriver = event.snapshot.value["car_details"].toString();
        });
      }
      if (event.snapshot.value["driver_name"] != null) {
        setState(() {
          driverName = event.snapshot.value["driver_name"].toString();
        });
      }
      if (event.snapshot.value["driver_phone"] != null) {
        setState(() {
          driverPhone = event.snapshot.value["driver_phone"].toString();
        });
      }
      if (event.snapshot.value["driver_location"] != null) {
        double driverlat = double.parse(
            event.snapshot.value["driver_location"]["latitude"].toString());
        double driverlng = double.parse(
            event.snapshot.value["driver_location"]["longitude"].toString());
        LatLng driverCurrentLocation = LatLng(driverlat, driverlng);
        statusRide = event.snapshot.value["status"].toString();
        if (statusRide == 'accepted') {
          updateRideTimeToPickUpLoc(driverCurrentLocation);
        }
        statusRide = event.snapshot.value["status"].toString();
        if (statusRide == 'arrived') {
          setState(() {
            rideStutes = "Driver has Arrived";
          });
        }
        statusRide = event.snapshot.value["status"].toString();
        if (statusRide == 'onride') {
          print("???????????????????????????????????");
          print(statusRide);
          updateRideTimeToDroOffLoc(driverCurrentLocation);
        }
      }
      if (event.snapshot.value["status"] != null) {
        statusRide = event.snapshot.value["status"].toString();
      }
      if (statusRide == "accepted") {
        displayDriverDetailsContainer();
        Geofire.stopListener();
        deleteGeoFileMarker();
      }
      if (statusRide == "ended") {
        if (event.snapshot.value["fares"] != null) {
          int fare = int.parse(event.snapshot.value["fares"].toString());
          var res = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => CollectFareDialog(
                    paymentMethod: "cash",
                    fareAmount: fare,
                  ));
          String driverId = "";
          if (res == "close") {
            if (event.snapshot.value["driver_id"] != null) {
              driverId = event.snapshot.value["driver_id"].toString();
            }
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RatingScreen(driverId: driverId)));
            rideRequestRef.onDisconnect();

            ridestreamSubscription.cancel();
            ridestreamSubscription = null;
            resetApp();
          }
        }
      }
    });
  }

  void deleteGeoFileMarker() {
    markersSet
        .removeWhere((element) => element.markerId.value.contains("driver"));
  }

  void updateRideTimeToPickUpLoc(LatLng driverCurrentLocation) async {
    if (isRequestingPositionDetails == false) {
      isRequestingPositionDetails = true;
      var positionUserLatLng =
          LatLng(currentPosition.latitude, currentPosition.longitude);
      var details = await AssistantMethods.obtainPlaceDirectionDetails(
          driverCurrentLocation, positionUserLatLng);
      if (details == null) {
        return;
      } else {
        setState(() {
          String time = details.time.toStringAsFixed(1);
          rideStutes = "Driver is Coming in " + time + " min";
        });
        isRequestingPositionDetails = false;
      }
    }
  }

  void updateRideTimeToDroOffLoc(LatLng driverCurrentLocation) async {
    if (isRequestingPositionDetails == false) {
      isRequestingPositionDetails = true;
      var dropOff =
          Provider.of<AppData>(context, listen: false).dropOffLocation;

      var dropOffUserLatLng = LatLng(dropOff.latitude, dropOff.longitude);

      var details = await AssistantMethods.obtainPlaceDirectionDetails(
          driverCurrentLocation, dropOffUserLatLng);

      if (details == null) {
        return;
      } else {
        setState(() {
          String time = details.time.toStringAsFixed(1);
          rideStutes = "Going to Destination" + time + " min";
        });
        isRequestingPositionDetails = false;
      }
    }
  }

  void cancelRideRequest() {
    rideRequestRef.remove();
    setState(() {
      state = "normal";
    });
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerheigt = 50;
      rideDetailsContanerheigt = 0;
      requstRideContanerheigt = 0;
      bottompaddingOfMap = 113.0;
      tapedPositions = null;
      polyLineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      plineCoordinates.clear();
      isTappedMap = false;
      statusRide = "";
      driverName = "";
      driverPhone = "";
      carDetailsDriver = "";
      rideStutes = "Driver is Coming ";
      driverDetailsContainerHeight = 0.0;
      bottomContainerheigt = 120.0;
      confirmbtnheight = 0.0;
      serchiconSize = 24;
      print("+_+_+_+_+++_+_+_+_" + setonMap.toString());
      if (setonMap != true) {
        AssistantMethods.searchCoordinateAddress(currentPosition, context);
      }
    });
    locaterPosition();
  }

  void displayRequestRideContaner() {
    setState(() {
      requstRideContanerheigt = 216.0;
      rideDetailsContanerheigt = 0;
      bottompaddingOfMap = 230.0;
      drawerOpen = true;
      confirmbtnheight = 0.0;
      serchiconSize = 0.0;
    });
    saveRideRequest();
  }

  void displayRideDetailsContaner() async {
    await getPlaceDirection();

    setState(() {
      searchContainerheigt = 0;
      rideDetailsContanerheigt = 220.0;
      bottompaddingOfMap = 200.0;
      confirmbtnheight = 0.0;
      serchiconSize = 0.0;
      drawerOpen = false;
      stopfun = false;
    });
  }

  void displayDriverDetailsContainer() {
    setState(() {
      requstRideContanerheigt = 0.0;
      rideDetailsContanerheigt = 0.0;
      bottompaddingOfMap = 290.0;
      driverDetailsContainerHeight = 220.0;
    });
  }

  void displayconfirmbtn() {
    setState(() {
      requstRideContanerheigt = 0.0;
      rideDetailsContanerheigt = 0.0;
      bottompaddingOfMap = 200.0;
      driverDetailsContainerHeight = 0.0;
      confirmbtnheight = 50.0;
      searchContainerheigt = 50.0;
      bottomContainerheigt = 0.0;
      drawerOpen = false;
    });
  }

  ///                Get CurrentLocation
  Position currentPosition;
  var geolocator = Geolocator();

  void locaterPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    currentPosition = position;
    if (isTappedMap == true) {}
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // ignore: unused_local_variable
    String address;
    if (isTappedMap == true) {
      address = await AssistantMethods.searchCoordinateAddressbytaping(
          tapedPositions, context);
    } else if (setonMap != true) {
      address =
          await AssistantMethods.searchCoordinateAddress(position, context);
    }

    initGeoFireListner();
    try {} catch (e) {
      print(e.toString());
    }

    AssistantMethods.retrieveHistoryInfo(context);
    final prefs = await SharedPreferences.getInstance();
    final photo = prefs.getString("photo");
    if (photo == Provider.of<AppData>(context, listen: false).user.image) {
      images = photo;
    } else if (photo !=
        Provider.of<AppData>(context, listen: false).user.image) {
      images = Provider.of<AppData>(context, listen: false).user.image;
    }
    // print("This is your address " + address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(12.8628, 30.2176),
    zoom: 10.4746,
  );

  @override
  Widget build(BuildContext context) {
    createIconMarker();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Saas",
            style: TextStyle(
                fontFamily: "segoebold", color: textcolor, fontSize: 28),
          ),
          backgroundColor: primary,
          leading: GestureDetector(
            onTap: () {
              setState(() {
                setonMap = false;
                isTappedMap = true;
                stopfun = true;
                isItDropOff = false;
              });
              if (drawerOpen) {
                scaffoldKey.currentState.openDrawer();
              } else {
                resetApp();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 14),
              child: FaIcon(
                ((drawerOpen) ? FontAwesomeIcons.bars : Icons.close),
                color: textcolor,
                size: 26,
              ),
            ),
          ),
        ),
        key: scaffoldKey,
        drawer: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15)),
            color: backgroundcolor,
          ),
          width: 255.0,
          child: Drawer(
            child: ListView(
              children: [
                //Drawer Header
                Container(
                  color: textcolor,
                  height: 190.0,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: textcolor,
                      // borderRadius: BorderRadius.only()
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: primary),
                          child: CircleAvatar(
                            backgroundImage: AssetImage("images/user_icon.png"),
                            radius: 45,
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
                        // Image.asset(
                        //   "images/user_icon.png",
                        //   height: 90.0,
                        //   width: 90.0,
                        // ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          Provider.of<AppData>(context, listen: false).user !=
                                  null
                              ? Provider.of<AppData>(context, listen: false)
                                  .user
                                  .name
                              : "",
                          style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: "segoebold",
                              color: bordercolor),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                            Provider.of<AppData>(context, listen: false).user !=
                                    null
                                ? Provider.of<AppData>(context, listen: false)
                                    .user
                                    .phone
                                : "",
                            style: TextStyle(
                                fontFamily: "segoebold", color: bordercolor))
                      ],
                    ),
                  ),
                ),
                // DividerWidget(),

                SizedBox(
                  height: 12.0,
                ),

                //Drawer Body
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HistoryScreen()));
                  },
                  child: ListTile(
                    leading: FaIcon(FontAwesomeIcons.history, color: textcolor),
                    title: Text(
                      AppLocalizations.of(context).history,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: "segoebold",
                          color: textcolor),
                    ),
                  ),
                ),
                Divider(
                  thickness: 0.50,
                  color: textcolor.withOpacity(0.25),
                  endIndent: 20,
                  indent: 20,
                ),
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.user, color: textcolor),
                  title: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileTabPage()));
                    },
                    child: Text(
                      AppLocalizations.of(context).profile,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: "segoebold",
                          color: textcolor),
                    ),
                  ),
                ),
                Divider(
                  thickness: 0.50,
                  color: textcolor.withOpacity(0.25),
                  endIndent: 20,
                  indent: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, AboutScreen.idScreen, (route) => false);
                  },
                  child: ListTile(
                    leading:
                        FaIcon(FontAwesomeIcons.infoCircle, color: textcolor),
                    title: Text(
                      AppLocalizations.of(context).about,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: "segoebold",
                          color: textcolor),
                    ),
                  ),
                ),
                Divider(
                  thickness: 0.50,
                  color: textcolor.withOpacity(0.25),
                  endIndent: 20,
                  indent: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, Setting.idScreen, (route) => false);
                  },
                  child: ListTile(
                    leading: FaIcon(FontAwesomeIcons.cogs, color: textcolor),
                    title: Text(
                      AppLocalizations.of(context).settings,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: "segoebold",
                          color: textcolor),
                    ),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Divider(
                  thickness: 2.0,
                  color: textcolor,
                  endIndent: 20,
                  indent: 20,
                ),

                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                  },
                  child: ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.signOutAlt,
                      color: Color(0xfffe5d33),
                    ),
                    title: Text(
                      AppLocalizations.of(context).logout,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: "segoebold",
                          color: Color(0xfffe5d33)),
                    ),
                  ),
                ),
                // ListTile(
                //   dense: true,
                //   trailing: CupertinoSwitch(
                //     onChanged: (bool value) {
                //       value == false
                //           ? Provider.of<AppData>(context, listen: false)
                //               .changeLocale(Locale('en'))
                //           : Provider.of<AppData>(context, listen: false)
                //               .changeLocale(Locale('ar'));
                //       setState(() {});
                //     },
                //     value:
                //         Provider.of<AppData>(context, listen: false).locale ==
                //                 Locale('en')
                //             ? false
                //             : true,
                //   ),
                //   leading: Icon(Icons.language_sharp),
                //   // title: Text(AppLocalizations.of(context).langa),
                // ),
              ],
            ),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              GoogleMap(
                padding: EdgeInsets.only(bottom: bottompaddingOfMap),
                mapType: MapType.normal,
                myLocationButtonEnabled: true,
                initialCameraPosition: _kGooglePlex,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                polylines: polyLineSet,
                markers: markersSet,
                compassEnabled: true,
                circles: circlesSet,
                onTap: _handleTap,
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);
                  newGoogleMapController = controller;
                  setState(() {
                    bottompaddingOfMap = 113.0;
                  });
                  locaterPosition();
                },
              ),

              //Search box

              Positioned(
                top: 20,
                left: 12,
                right: 12,
                child: Container(
                  height: searchContainerheigt,
                  child: GestureDetector(
                    onTap: () async {
                      var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen()));
                      if (res == "obtainDirection") {
                        displayRideDetailsContaner();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: bordercolor,
                          borderRadius: BorderRadius.circular(25.0),
                          boxShadow: [
                            BoxShadow(
                              color: textcolor.withOpacity(0.25),
                              blurRadius: 10.0,
                              spreadRadius: 0.9,
                              offset: Offset(0.0, 0.0),
                            ),
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.search,
                              size: serchiconSize,
                              color: textcolor,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Container(
                              height: 20,
                              child: VerticalDivider(
                                thickness: 2.0,
                                color: textcolor.withOpacity(0.50),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              placeName != ""
                                  ? "${Provider.of<AppData>(context, listen: false).dropOffLocation.placeName}"
                                  : AppLocalizations.of(context).searchdropoff,
                              style: TextStyle(
                                  color: textcolor,
                                  fontFamily: "segoebold",
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              //Bottom Container
              Positioned(
                left: 12.0,
                right: 12.0,
                bottom: 10.0,
                child: AnimatedSize(
                  duration: new Duration(microseconds: 1000),
                  vsync: this,
                  curve: Curves.bounceIn,
                  child: Container(
                    height: bottomContainerheigt,
                    decoration: BoxDecoration(
                        color: bordercolor,
                        borderRadius: BorderRadius.circular(18.0),
                        boxShadow: [
                          BoxShadow(
                            color: textcolor.withOpacity(0.25),
                            blurRadius: 10.0,
                            spreadRadius: 0.9,
                            offset: Offset(0.0, 0.0),
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(
                          //   height: 6.0,
                          // ),
                          // Text(
                          //   "hi there, ",
                          //   style: TextStyle(fontSize: 12.0, color: primary),
                          // ),
                          // Text(
                          //   "Where to?",
                          //   style: TextStyle(
                          //       fontSize: 20.0,
                          //       fontFamily: "Brand Bold",
                          //       color: secondary),
                          // ),
                          // SizedBox(
                          //   height: 20.0,
                          // ),

                          // SizedBox(
                          //   height: 24.0,
                          // ),
                          Text(
                            AppLocalizations.of(context).currentlocation,
                            style: TextStyle(
                                fontFamily: "segoe",
                                fontSize: 18,
                                color: textcolor),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.home,
                                color: textcolor,
                              ),
                              SizedBox(
                                width: 12.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Provider.of<AppData>(context, listen: false)
                                                    .pickUpLocation !=
                                                null &&
                                            Provider.of<AppData>(context,
                                                        listen: false)
                                                    .pickUpLocation
                                                    .placeName !=
                                                "Botschaft der Bundesrepublik Deutschland"
                                        ? Provider.of<AppData>(context,
                                                listen: false)
                                            .pickUpLocation
                                            .placeName
                                        : "Add Home",
                                    style: TextStyle(
                                        color: textcolor,
                                        fontFamily: "segoebold",
                                        fontSize: 16),
                                    overflow: TextOverflow.visible,
                                  ),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //Ride Details Ui
              Positioned(
                bottom: 5.0,
                left: 12.0,
                right: 12.0,
                child: AnimatedSize(
                  duration: new Duration(microseconds: 160),
                  vsync: this,
                  curve: Curves.bounceIn,
                  child: Container(
                    height: rideDetailsContanerheigt,
                    decoration: BoxDecoration(
                        color: bordercolor,
                        borderRadius: BorderRadius.circular(18.0),
                        boxShadow: [
                          BoxShadow(
                            color: textcolor.withOpacity(0.25),
                            blurRadius: 10.0,
                            spreadRadius: 0.9,
                            offset: Offset(0.0, 0.0),
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17.0),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context).choosetype,
                            style: TextStyle(
                              color: textcolor,
                              fontFamily: "segoebold",
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          //Bick Ride
                          GestureDetector(
                            onTap: () async {
                              displaytostMessage("searching Motobike", context);
                              setState(() {
                                state = "requesting";
                                carRideType = "bike";
                              });
                              displayRequestRideContaner();

                              // availableDrivers = GeofireAssistant
                              //     .nearByAvailableDriversList
                              //     .toSet()
                              //     .toList();
                              availableDrivers = [
                                ...{
                                  ...GeofireAssistant.nearByAvailableDriversList
                                }
                              ];

                              print(
                                  '${GeofireAssistant.nearByAvailableDriversList}>> first');

                              searchNearestDriver();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: bordercolor,
                                  borderRadius: BorderRadius.circular(15)),
                              width: MediaQuery.of(context).size.width * 0.95,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      "images/motobike.png",
                                      height: 50.0,
                                      width: 50.0,
                                    ),
                                    SizedBox(
                                      width: 30.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).bike,
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "segoebold",
                                              color: textcolor),
                                        ),
                                        Text(
                                          ((tripdirectionDetails != null)
                                              ? tripdirectionDetails.time
                                                      .toStringAsFixed(0) +
                                                  AppLocalizations.of(context)
                                                      .min
                                              : ''),
                                          style: TextStyle(
                                            fontFamily: "segoebold",
                                            fontSize: 16.0,
                                            color: Color(0xff01e554),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text(
                                      ((tripdirectionDetails != null)
                                          ? '\SDG ${((AssistantMethods.calculateFares(tripdirectionDetails)) / 1.5).toStringAsFixed(1)}'
                                          : ''),
                                      style: TextStyle(
                                          fontFamily: "segoebold",
                                          color: Color(0xfffe5d33)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Divider(
                            height: 2.0,
                            thickness: 2.0,
                            indent: 20,
                            endIndent: 20,
                            color: textcolor.withOpacity(.25),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),

                          GestureDetector(
                            onTap: () {
                              displaytostMessage("searching TukTuk", context);
                              setState(() {
                                state = "requesting";
                                carRideType = "tuktuk";
                              });
                              displayRequestRideContaner();
                              availableDrivers =
                                  GeofireAssistant.nearByAvailableDriversList;
                              searchNearestDriver();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "images/tuktuk1.png",
                                      height: 50.0,
                                      width: 50.0,
                                    ),
                                    SizedBox(
                                      width: 30.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).tuktuk,
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "segoebold",
                                              color: textcolor),
                                        ),
                                        Text(
                                          ((tripdirectionDetails != null)
                                              ? tripdirectionDetails.time
                                                      .toStringAsFixed(0) +
                                                  AppLocalizations.of(context)
                                                      .min
                                              : ''),
                                          style: TextStyle(
                                            fontFamily: "segoebold",
                                            fontSize: 16.0,
                                            color: Color(0xff01e554),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text(
                                      ((tripdirectionDetails != null)
                                          ? '\SDG ${(AssistantMethods.calculateFares(tripdirectionDetails)).toStringAsFixed(1)}'
                                          : ''),
                                      style: TextStyle(
                                          fontFamily: "segoebold",
                                          color: Color(0xfffe5d33)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(height: 10.0),
                          //  Divider(
                          //     height: 2.0,
                          //     thickness: 2.0,
                          //     indent: 20,
                          //     endIndent: 20,
                          //     color: textcolor.withOpacity(.25),
                          //   ),
                          // SizedBox(
                          //   height: 10.0,
                          // ),

                          // Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 16.0),
                          //   child: Row(
                          //     children: [
                          //       Icon(
                          //         FontAwesomeIcons.moneyCheckAlt,
                          //         size: 18.0,
                          //         color: Colors.black54,
                          //       ),
                          //       SizedBox(width: 16.0),
                          //       Text("Cash"),
                          //       SizedBox(
                          //         width: 6.0,
                          //       ),
                          //       Icon(
                          //         Icons.keyboard_arrow_down,
                          //         color: Colors.black54,
                          //         size: 16.0,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //Request Or Cancel Ui
              Positioned(
                bottom: 5.0,
                left: 12.0,
                right: 12.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: textcolor.withOpacity(0.25),
                        blurRadius: 10.0,
                        spreadRadius: 0.9,
                        offset: Offset(0.0, 0.0),
                      ),
                    ],
                  ),
                  height: requstRideContanerheigt,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          width: double.infinity,
                          height: 40.0,
                          child: SizedBox(
                            width: double.infinity,
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "segoebold"),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  FadeAnimatedText(
                                      AppLocalizations.of(context).requstin),
                                  FadeAnimatedText(
                                      AppLocalizations.of(context).pleasewait),
                                  FadeAnimatedText(AppLocalizations.of(context)
                                      .findingadriver),
                                ],
                                onTap: () {
                                  print("Tap Event");
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            cancelRideRequest();
                            resetApp();
                          },
                          child: Container(
                            height: 60.0,
                            width: 100.0,
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(26.0),
                              border: Border.all(width: 2.0, color: textcolor),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 26.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          width: double.infinity,
                          child: Text(
                            AppLocalizations.of(context).cancelride,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: "segoebold"),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              //Display aSign Driver Info
              Positioned(
                bottom: 5.0,
                left: 12.0,
                right: 12.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: textcolor.withOpacity(0.25),
                        blurRadius: 10.0,
                        spreadRadius: 0.9,
                        offset: Offset(0.0, 0.0),
                      ),
                    ],
                  ),
                  height: driverDetailsContainerHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              rideStutes,
                              style: TextStyle(
                                  fontSize: 20.0, fontFamily: "segoebold"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 1.0,
                          indent: 45,
                          endIndent: 45,
                          color: textcolor.withOpacity(0.25),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              driverName,
                              style: TextStyle(
                                  fontFamily: "segoebold",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 32.0,
                                  color: textcolor
                                  //   Color(0xff01e554)
                                  ),
                            ),
                            Container(
                              height: 45,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: bordercolor,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: textcolor.withOpacity(0.25),
                                      blurRadius: 10.0,
                                      spreadRadius: 0.9,
                                      offset: Offset(0.0, 0.0),
                                    )
                                  ]),
                              child: Center(
                                child: Text(
                                  carDetailsDriver,
                                  style: TextStyle(
                                      color: Color(0xfffe5d33),
                                      fontFamily: "segoe",
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Divider(
                          height: 2.0,
                          thickness: 1.0,
                          indent: 45,
                          endIndent: 45,
                          color: textcolor.withOpacity(0.25),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //call button
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: ElevatedButton(
                                onPressed: () async {
                                  // ignore: unnecessary_brace_in_string_interps
                                  launch(('tel://${driverPhone}'));
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: textcolor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
                                child: Padding(
                                  padding: EdgeInsets.all(17.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).calldriver,
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: primary),
                                      ),
                                      Icon(
                                        Icons.call,
                                        color: primary,
                                        size: 26.0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              //From search Screen
              Positioned(
                bottom: 10.0,
                left: 12.0,
                right: 12.0,
                child: Container(
                  height: confirmbtnheight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: textcolor.withOpacity(0.25),
                        blurRadius: 10.0,
                        spreadRadius: 0.9,
                        offset: Offset(0.0, 0.0),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      getPlaceDirection();
                      displayRideDetailsContaner();
                    },
                    style: ElevatedButton.styleFrom(
                        primary: textcolor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50.0,
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).cdropoffloc,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: "segoebold",
                              fontSize: 18.0,
                              color: primary),
                        ),
                      ),
                    ),
                  ),
                ),
                // child: IconButton(
                //   onPressed: () async {
                //     getPlaceDirection();
                //     displayRideDetailsContaner();
                //   },
                //   icon: Icon(Icons.ac_unit),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getPlaceDirection() async {
    var pickUppoints;
    var dropOffpoints;
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    tapedPositions != null
        ? pickUppoints =
            LatLng(tapedPositions.latitude, tapedPositions.longitude)
        : pickUppoints = LatLng(initialPos.latitude, initialPos.longitude);
    tapedPositions != null
        ? LatLng(tapedPositions.latitude, tapedPositions.longitude)
        : dropOffpoints = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "please wait...",
            ));

    print('initial point is $dropOffpoints');
    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUppoints, dropOffpoints);

    setState(() {
      tripdirectionDetails = details;
    });

    Navigator.pop(context);
    // print("++_+_+_+_+_+_+_+_+_+_+_+_++");
    // print(details.points);
    PolylinePoints polylinePoints = PolylinePoints();
    // List<PointLatLng> decodePolyLinesResult =
    //     polylinePoints.decodePolyline(details.points[0].toString());
    print(polylinePoints);
    plineCoordinates.clear();
    if (details.points.isNotEmpty) {
      details.points.forEach((dynamic pointss) {
        plineCoordinates.add(LatLng(pointss[1], pointss[0]));
      });
      print(plineCoordinates);
    }
    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: Color(0xfffe5d33),
          polylineId: PolylineId("PolylineID"),
          jointType: JointType.round,
          points: plineCoordinates,
          consumeTapEvents: true,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);
      polyLineSet.add(polyline);
    });

    LatLngBounds latLagBounds;

    if (pickUppoints.latitude > dropOffpoints.latitude &&
        pickUppoints.longitude > dropOffpoints.longitude) {
      latLagBounds =
          LatLngBounds(southwest: dropOffpoints, northeast: pickUppoints);
    } else if (pickUppoints.longitude > dropOffpoints.longitude) {
      latLagBounds = LatLngBounds(
          southwest: LatLng(pickUppoints.latitude, dropOffpoints.longitude),
          northeast: LatLng(dropOffpoints.latitude, pickUppoints.longitude));
    } else if (pickUppoints.latitude > dropOffpoints.latitude) {
      latLagBounds = LatLngBounds(
          southwest: LatLng(dropOffpoints.latitude, pickUppoints.longitude),
          northeast: LatLng(pickUppoints.latitude, pickUppoints.longitude));
    } else {
      latLagBounds =
          LatLngBounds(southwest: pickUppoints, northeast: dropOffpoints);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLagBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(0.2, 0.2)), "images/marker1.png"),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "my Location"),
      position: pickUppoints,
      markerId: MarkerId("PickUpId"),
    );
    Marker dropOffLocMarker = Marker(
      icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(0.2, 0.2)), "images/marker1.png"),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "Dropoff Location"),
      position: dropOffpoints,
      markerId: MarkerId("DropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });
    Circle pikupLocCircle = Circle(
      fillColor: primary,
      center: pickUppoints,
      radius: 12,
      strokeWidth: 4,
      strokeColor: textcolor,
      circleId: CircleId("PickUpId"),
    );
    Circle dropOffLocCircle = Circle(
      fillColor: textcolor,
      center: dropOffpoints,
      radius: 12,
      strokeWidth: 4,
      strokeColor: primary,
      circleId: CircleId("DropOffId"),
    );
    setState(() {
      circlesSet.add(pikupLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }

  void initGeoFireListner() {
    Geofire.initialize("availableDrivers");
    //
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 10)
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            // if (GeofireAssistant.nearByAvailableDriversList != null) {
            //   GeofireAssistant.nearByAvailableDriversList.clear();
            // }
            GeofireAssistant.nearByAvailableDriversList.toSet().toList();

            bool filterEntry = GeofireAssistant.nearByAvailableDriversList
                .any((element) => element.key == nearbyAvailableDrivers.key);
            if (!filterEntry) {
              GeofireAssistant.nearByAvailableDriversList
                  .add(nearbyAvailableDrivers);
            }

            // int index = 0;
            //  GeofireAssistant.nearByAvailableDriversList.forEach((element) {
            //   if (element.key == nearbyAvailableDrivers.key) {
            //     GeofireAssistant.nearByAvailableDriversList.removeAt(index);
            //     print(GeofireAssistant.nearByAvailableDriversList[index].key);
            //   }
            //   index++;
            // });
            // index = 0;
            GeofireAssistant.nearByAvailableDriversList = [
              ...{...GeofireAssistant.nearByAvailableDriversList}
            ];

            if (nearbyAvailableDriverKeysLoaded == true) {
              updateAvailableDriversOnMap();
            }

            break;

          case Geofire.onKeyExited:
            GeofireAssistant.removeDriverFromList(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];

            GeofireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();

            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriversOnMap();
            break;
        }
      }

      setState(() {});
    });
    //
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });
    Set<Marker> tMarkers = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeofireAssistant.nearByAvailableDriversList) {
      LatLng driverAvailePosition = LatLng(driver.latitude, driver.longitude);

      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverAvailePosition,
        icon: nearbyIcon,
        rotation: AssistantMethods.createRandomNumber(360),
      );
      tMarkers.add(marker);
    }
    setState(() {
      markersSet = tMarkers;
    });
  }

  void createIconMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/bikeicon.png")
          .then((value) {
        nearbyIcon = value;
      });
    }
  }

  void noDriverFound() {
    showDialog(
        context: context,
        builder: (BuildContext context) => NoDriverAvailableDialog());
  }

  void searchNearestDriver() {
    if (availableDrivers.length == 0) {
      cancelRideRequest();
      resetApp();
      noDriverFound();
      return;
    }
    // List<NearbyAvailableDrivers> x = [
    //   ...{...availableDrivers}
    // ];
    availableDrivers.toSet().toList();
    availableDrivers = [
      ...{...availableDrivers}
    ];
    print(availableDrivers.length);
    Map<String, NearbyAvailableDrivers> mp = {};
    for (var item in availableDrivers) {
      mp[item.key] = item;
    }
    var filteredList = [
      ...{...mp.values}
    ];

    print("+++++++++++++++++++++++++");

    print(filteredList.length);

    var driver = filteredList[0];
    filteredList.removeAt(0);
    availableDrivers.removeAt(0);
    print("+++++++++++++++++++++++++");

    print(filteredList.length);

    driverRef
        .child(driver.key)
        .child("car_details")
        .child("type")
        .once()
        .then((DataSnapshot snap) async {
      if (await snap.value != null) {
        String carType = snap.value.toString();
        if (carType == carRideType) {
          notifyDriver(driver);
        } else {
          displaytostMessage(
              carRideType + "drivers not available. Try again", context);
        }
      } else {
        displaytostMessage("No car found. Try again", context);
      }
    });
  }

  void notifyDriver(NearbyAvailableDrivers drivers) {
    driverRef.child(drivers.key).child("newRide").set(rideRequestRef.key);
    driverRef
        .child(drivers.key)
        .child("token")
        .once()
        .then((DataSnapshot snap) {
      if (snap.value != null) {
        String token = snap.value.toString();
        AssistantMethods.sendNotificationtoDriver(
            token, context, rideRequestRef.key);
      } else {
        return;
      }
      const oneSecondPassed = Duration(seconds: 1);

      // ignore: unused_local_variable
      var timer = Timer.periodic(oneSecondPassed, (timer) {
        if (state != "requesting") {
          driverRef.child(drivers.key).child("newRide").set("cancelled");
          driverRef.child(drivers.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 15;
          timer.cancel();
        }
        driverRequestTimeOut = driverRequestTimeOut - 1;
        driverRef.child(drivers.key).child("newRide").onValue.listen((event) {
          if (event.snapshot.value.toString() == "accepted") {
            driverRef.child(drivers.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 15;
            timer.cancel();
          }
        });
        if (driverRequestTimeOut == 0) {
          driverRef.child(drivers.key).child("newRide").set("timeout");
          driverRef.child(drivers.key).child("newRide").onDisconnect();

          driverRequestTimeOut = 15;

          timer.cancel();

          searchNearestDriver();
        }
      });
    });
  }

  double tapedlat;
  double tapedlog;
  LatLng tapedPositions;
  bool isTappedMap = false;
  bool stopfun = true;

  _handleTap(LatLng tapedPosition) async {
    if (stopfun == true) {
      if (isItDropOff == false) {
        print(tapedPosition);
        tapedPositions = tapedPosition;
        tapedlat = tapedPosition.latitude;
        tapedlog = tapedPosition.longitude;
        Marker tapedPickUpLocMarker = Marker(
          icon: await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(0.2, 0.2)), "images/marker1.png"),
          position: tapedPositions,
          markerId: MarkerId("PickUpId"),
        );

        setState(() {
          drawerOpen = false;

          markersSet.add(tapedPickUpLocMarker);

          isTappedMap = true;
          AssistantMethods.searchCoordinateAddressbytaping(
              tapedPosition, context);
        });
      } else if (isItDropOff == true) {
        getpredictionfromMap(tapedPosition);
      }
    } else {
      return;
    }
  }

  String placeName = "";
  void getpredictionfromMap(LatLng tapmap) async {
    String url =
        "https://api.geoapify.com/v1/geocode/reverse?lat=${tapmap.latitude}&lon=${tapmap.longitude}&apiKey=$keyOfMap";

    var res = await RequstAssistant.getRequest(url);

    if (res == "failed") {
      return;
    }
    if (res != "failed") {
      print("+++++++++++++" + res.toString());
      Address address = Address();
      if (res["features"][0]["properties"]["name"] != null) {
        address.placeName = res["features"][0]["properties"]["name"];
      } else {
        address.placeName = res["features"][0]["properties"]["suburb"];
      }

      address.placrId = res["features"][0]["properties"]["place_id"];
      address.latitude = res["features"][0]["properties"]["lat"];
      address.longitude = res["features"][0]["properties"]["lon"];
      print(address);
      if (placeName != null) {
        placeName = address.placeName;
      }
      Marker tapedPickUpLocMarker = Marker(
        icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(0.2, 0.2)), "images/marker1.png"),
        position: LatLng(address.latitude, address.longitude),
        markerId: MarkerId("dropoffId"),
      );

      setState(() {
        markersSet.add(tapedPickUpLocMarker);

        isTappedMap = true;
      });

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);
    }
  }
}
