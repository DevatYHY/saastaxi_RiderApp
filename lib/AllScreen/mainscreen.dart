import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:newmap/AllScreen/AboutScreen.dart';
import 'package:newmap/AllScreen/HistoryScreen.dart';
import 'package:newmap/AllScreen/loginScreen.dart';
import 'package:newmap/AllScreen/profileTapPage.dart';
import 'package:newmap/AllScreen/ratingScreen.dart';
import 'package:newmap/AllScreen/searchScreen.dart';
import 'package:newmap/AllWidgets/Divider.dart';
import 'package:newmap/AllWidgets/collectFareDialog.dart';
import 'package:newmap/AllWidgets/noDriverAvailableDialog.dart';
import 'package:newmap/AllWidgets/progressDialog.dart';
import 'package:newmap/Assistants/assistantMethod.dart';
import 'package:newmap/Assistants/geofireAssistant.dart';
import 'package:newmap/DataHandler/appData.dart';
import 'package:newmap/Models/directDetails.dart';
import 'package:newmap/Models/history.dart';
import 'package:newmap/Models/nearybyAvailableDrivers.dart';
import 'package:newmap/configMap.dart';
import 'package:newmap/main.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

  double rideDetailsContanerheigt = 0;
  double searchContainerheigt = 250.0;
  double requstRideContanerheigt = 0;
  double driverDetailsContainerHeight = 0;

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

  @override
  void initState() {
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
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
          String time = details.time.toStringAsFixed(0);
          rideStutes = "Driver is Coming" + time;
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
          String time = details.time.toStringAsFixed(0);
          rideStutes = "Going to Destination" + time;
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
      searchContainerheigt = 300;
      rideDetailsContanerheigt = 0;
      requstRideContanerheigt = 0;
      bottompaddingOfMap = 230.0;
      polyLineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      plineCoordinates.clear();

      statusRide = "";
      driverName = "";
      driverPhone = "";
      carDetailsDriver = "";
      rideStutes = "Driver is Coming";
      driverDetailsContainerHeight = 0.0;
    });
    locaterPosition();
  }

  void displayRequestRideContaner() {
    setState(() {
      requstRideContanerheigt = 250.0;
      rideDetailsContanerheigt = 0;
      bottompaddingOfMap = 230.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  void displayRideDetailsContaner() async {
    await getPlaceDirection();

    setState(() {
      searchContainerheigt = 0;
      rideDetailsContanerheigt = 360.0;
      bottompaddingOfMap = 360.0;
      drawerOpen = false;
    });
  }

  void displayDriverDetailsContainer() {
    setState(() {
      requstRideContanerheigt = 0.0;
      rideDetailsContanerheigt = 0.0;
      bottompaddingOfMap = 290.0;
      driverDetailsContainerHeight = 320.0;
    });
  }

  ///                Get CurrentLocation
  Position currentPosition;
  var geolocator = Geolocator();

  void locaterPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    initGeoFireListner();

    uName = userCurrentInfo.name;

    AssistantMethods.retrieveHistoryInfo(context);
    // print("This is your address " + address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 10.4746,
  );

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        drawer: Container(
          color: backgroundcolor,
          width: 255.0,
          child: Drawer(
            child: ListView(
              children: [
                //Drawer Header
                Container(
                  height: 165.0,
                  child: DrawerHeader(
                    decoration: BoxDecoration(color: primary),
                    child: Row(
                      children: [
                        Image.asset(
                          "images/user_icon.png",
                          height: 65.0,
                          width: 65.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              uName,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: "Brand Bold",
                                  color: textcolor),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProfileTabPage()));
                                },
                                child: Text("Visit Profile",
                                    style: TextStyle(color: textcolor))),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                DividerWidget(),

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
                    leading: Icon(Icons.history),
                    title: Text(
                      "History",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileTabPage()));
                    },
                    child: Text(
                      "Profile",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, AboutScreen.idScreen, (route) => false);
                  },
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text(
                      "About",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                  },
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text(
                      "Sign Out",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
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
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);
                  newGoogleMapController = controller;
                  setState(() {
                    bottompaddingOfMap = 300.0;
                  });
                  locaterPosition();
                },
              ),

              //Drawer Button
              Positioned(
                top: 38.0,
                left: 22.0,
                child: GestureDetector(
                  onTap: () {
                    if (drawerOpen) {
                      scaffoldKey.currentState.openDrawer();
                    } else {
                      resetApp();
                    }
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: secondary,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: secondary,
                              blurRadius: 2.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.2, 0.2),
                            )
                          ]),
                      child: CircleAvatar(
                        backgroundColor: secondary,
                        child: Icon(
                          ((drawerOpen) ? Icons.menu : Icons.close),
                          color: primary,
                        ),
                        radius: 20.0,
                      )),
                ),
              ),
              //Search Ui
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: AnimatedSize(
                  duration: new Duration(microseconds: 160),
                  vsync: this,
                  curve: Curves.bounceIn,
                  child: Container(
                    height: searchContainerheigt,
                    decoration: BoxDecoration(
                        color: backgroundcolor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 16.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            "hi there, ",
                            style: TextStyle(fontSize: 12.0, color: primary),
                          ),
                          Text(
                            "Where to?",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: "Brand Bold",
                                color: secondary),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          GestureDetector(
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
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black87.withOpacity(.3),
                                      blurRadius: 5.0,
                                      spreadRadius: 0.1,
                                      offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: primary,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text("Search Drop Off",
                                        style:
                                            TextStyle(color: secondary))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 24.0,
                          ),
                          Text("Current Location :",
                          style: TextStyle(
                            fontFamily: "Brand Bold",
                            fontSize: 18,
                            color: secondary
                          ),),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Icon(
                                Icons.home,
                                color: primary,
                              ),
                              SizedBox(
                                width: 12.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      Provider.of<AppData>(context)
                                                  .pickUpLocation !=
                                              null
                                          ? Provider.of<AppData>(context)
                                              .pickUpLocation
                                              .placeName
                                          : "Add Home",
                                      style: TextStyle(
                                          color: textcolor,
                                          fontFamily: "Brand Bold",
                                          fontSize: 16)),
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
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: AnimatedSize(
                  duration: new Duration(microseconds: 160),
                  vsync: this,
                  curve: Curves.bounceIn,
                  child: Container(
                    height: rideDetailsContanerheigt,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 16.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17.0),
                      child: Column(
                        children: [
                          //Bick Ride
                          GestureDetector(
                            onTap: () {
                              displaytostMessage("searching Motobike", context);
                              setState(() {
                                state = "requesting";
                                carRideType = "bike";
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
                                      "images/motobike.png",
                                      height: 70.0,
                                      width: 80.0,
                                    ),
                                    SizedBox(
                                      width: 16.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Bike",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: "Brand-Bold",
                                          ),
                                        ),
                                        Text(
                                          ((tripdirectionDetails != null)
                                              ? tripdirectionDetails.time
                                                  .toStringAsFixed(1)
                                              : ''),
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text(
                                      ((tripdirectionDetails != null)
                                          ? '\$${((AssistantMethods.calculateFares(tripdirectionDetails)) / 1.5).toStringAsFixed(1)}'
                                          : ''),
                                      style: TextStyle(
                                        fontFamily: "Brand-Bold",
                                      ),
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
                                      height: 70.0,
                                      width: 80.0,
                                    ),
                                    SizedBox(
                                      width: 16.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "tuk tuk",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: "Brand-Bold",
                                          ),
                                        ),
                                        Text(
                                          ((tripdirectionDetails != null)
                                              ? tripdirectionDetails.time
                                                  .toStringAsFixed(1)
                                              : ''),
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text(
                                      ((tripdirectionDetails != null)
                                          ? '\$${(AssistantMethods.calculateFares(tripdirectionDetails)).toStringAsFixed(1)}'
                                          : ''),
                                      style: TextStyle(
                                        fontFamily: "Brand-Bold",
                                      ),
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
                          ),
                          SizedBox(
                            height: 10.0,
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.moneyCheckAlt,
                                  size: 18.0,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 16.0),
                                Text("Cash"),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black54,
                                  size: 16.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //Request Or Cancel Ui
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 0.5,
                        blurRadius: 16.0,
                        color: Colors.black54,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  height: requstRideContanerheigt,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 12.0,
                        ),
                        Container(
                          width: double.infinity,
                          height: 55.0,
                          child: SizedBox(
                            width: double.infinity,
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Brand-Bold"),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  FadeAnimatedText('Requsting a Ride !'),
                                  FadeAnimatedText('Please wait...'),
                                  FadeAnimatedText('Finding a Driver'),
                                ],
                                onTap: () {
                                  print("Tap Event");
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            cancelRideRequest();
                            resetApp();
                          },
                          child: Container(
                            height: 60.0,
                            width: 60.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26.0),
                              border: Border.all(
                                  width: 2.0, color: Colors.grey[300]),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 26.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22.0,
                        ),
                        Container(
                          width: double.infinity,
                          child: Text(
                            "Cancel Ride",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.0),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              //Display aSign Driver Info
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 0.5,
                        blurRadius: 16.0,
                        color: Colors.black54,
                        offset: Offset(0.7, 0.7),
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
                                  fontSize: 20.0, fontFamily: "Brand-Bold"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 22.0,
                        ),
                        Divider(
                          height: 2.0,
                          thickness: 2.0,
                        ),
                        Text(
                          carDetailsDriver,
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(driverName,
                            style: TextStyle(
                              fontSize: 20.0,
                            )),
                        SizedBox(
                          height: 22.0,
                        ),
                        Divider(
                          height: 2.0,
                          thickness: 2.0,
                        ),
                        SizedBox(
                          height: 22.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //call button
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: ElevatedButton(
                                onPressed: () async {
                                  launch(('tel://${driverPhone}'));
                                },
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.pink)),
                                child: Padding(
                                  padding: EdgeInsets.all(17.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Call Driver",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.call,
                                        color: Colors.white,
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Future getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    var pickUppoints = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffpoints = LatLng(finalPos.latitude, finalPos.longitude);
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
    print("++_+_+_+_+_+_+_+_+_+_+_+_++");
    print(details.points);
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
          color: Colors.orange,
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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "my Location"),
      position: pickUppoints,
      markerId: MarkerId("PickUpId"),
    );
    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
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
      fillColor: Colors.orange,
      center: pickUppoints,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.orangeAccent,
      circleId: CircleId("PickUpId"),
    );
    Circle dropOffLocCircle = Circle(
      fillColor: Colors.red,
      center: dropOffpoints,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.red,
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

            GeofireAssistant.nearByAvailableDriversList
                .add(nearbyAvailableDrivers);
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
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/bikeicon.png.png")
          .then((value) {
        nearbyIcon = value;
      });
    }
  }

  void noDriverFound() {
    showDialog(
        context: context,
        builder: (BuildContext context) => noDriverAvailableDialog());
  }

  void searchNearestDriver() {
    if (availableDrivers.length == 0) {
      cancelRideRequest();
      resetApp();
      noDriverFound();
      return;
    }
    var driver = availableDrivers[0];
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
          availableDrivers.removeAt(0);
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
      var time = Timer.periodic(oneSecondPassed, (timer) {
        if (state != "requesting") {
          driverRef.child(drivers.key).child("newRide").set("cancelled");
          driverRef.child(drivers.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 40;
          timer.cancel();
        }
        driverRequestTimeOut = driverRequestTimeOut - 1;
        driverRef.child(drivers.key).child("newRide").onValue.listen((event) {
          if (event.snapshot.value.toString() == "accepted") {
            driverRef.child(drivers.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 40;
            timer.cancel();
          }
        });
        if (driverRequestTimeOut == 0) {
          driverRef.child(drivers.key).child("newRide").set("timeout");
          driverRef.child(drivers.key).child("newRide").onDisconnect();

          driverRequestTimeOut = 40;
          noDriverFound();
          resetApp();
          timer.cancel();

          // searchNearestDriver();
        }
      });
    });
  }
}
