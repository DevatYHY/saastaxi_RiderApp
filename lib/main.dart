import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:newmap/AllScreen/AboutScreen.dart';
import 'package:newmap/AllScreen/MainScreen.dart';
import 'package:newmap/AllScreen/loginScreen.dart';
import 'package:newmap/AllScreen/registrationScreen.dart';
import 'package:newmap/DataHandler/appData.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference userRef = FirebaseDatabase.instance.reference().child("user");
DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child("drivers");
    DatabaseReference newRequestsRef =
    FirebaseDatabase.instance.reference().child("Ride Requests");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.idScreen
            : MainScreen.idScreen,
        routes: {
          RegisterationScreen.idScreen: (context) => RegisterationScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) => MainScreen(),
          AboutScreen.idScreen: (context) => AboutScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
