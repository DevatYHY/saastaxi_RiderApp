import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:newmap/AllScreen/AboutScreen.dart';
import 'package:newmap/AllScreen/MainScreen.dart';
import 'package:newmap/AllScreen/SettingScreen.dart';
import 'package:newmap/AllScreen/loginScreen.dart';
import 'package:newmap/AllScreen/otpScreen.dart';
import 'package:newmap/AllScreen/otpValidation.dart';
import 'package:newmap/AllScreen/registrationScreen.dart';
import 'package:newmap/AllWidgets/noDriverAvailableDialog.dart';
import 'package:newmap/DataHandler/appData.dart';
import 'package:provider/provider.dart';
import 'package:newmap/AllScreen/welcomeScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

DatabaseReference avaiableDriverRef =
    FirebaseDatabase.instance.reference().child("availableDrivers");

DatabaseReference configref =
    FirebaseDatabase.instance.reference().child("config");


class MyApp extends StatelessWidget {
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: Consumer<AppData>(
        builder: (context, locale, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Provider.of<AppData>(context).locale,
            supportedLocales: const [
              Locale('en', ''), // English, no country code
              Locale('ar', ''), // Spanish, no country code
            ],
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            initialRoute: FirebaseAuth.instance.currentUser == null
                ? WelcomeScreen.idScreen
                : MainScreen.idScreen,
            routes: {
              RegisterationScreen.idScreen: (context) => RegisterationScreen(),
              LoginScreen.idScreen: (context) => LoginScreen(),
              MainScreen.idScreen: (context) => MainScreen(),
              AboutScreen.idScreen: (context) => AboutScreen(),
              WelcomeScreen.idScreen: (context) => WelcomeScreen(),
              NoDriverAvailableDialog.idScreen: (context) =>
                  NoDriverAvailableDialog(),
              Setting.idScreen: (context) => Setting(),
              OtpValidation.idScreen:(context)=>OtpValidation(),
              Otpscreen.idScreen:(context)=>Otpscreen()
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
