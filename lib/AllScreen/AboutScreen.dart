
import 'package:flutter/material.dart';
import 'package:newmap/AllScreen/mainscreen.dart';

class AboutScreen extends StatefulWidget {
  static const String idScreen = "about";
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          //car Icon

          Container(
            height: 220,
            child: Center(
              child: Image.asset(
                  'images/gratis-png-auto-rickshaw-dibujo-arte-bosquejo-tuk-tuk-taxi.png'),
            ),
          ),

          //app name +info

          Padding(
            padding: EdgeInsets.only(top: 30, left: 24, right: 24),
            child: Column(
              children: [
                Text(
                  "SaasTaxi",
                  style: TextStyle(fontSize: 90, fontFamily: 'Signatra'),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'This App has been Developed by MinaSave international Company.'
                  ' This App offer cheap ride at cheap rates,',
                  style: TextStyle(
                    fontFamily: 'Brand Bold',
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),

          SizedBox(
            height: 40,
          ),
          //Go Back button

          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, MainScreen.idScreen, (route) => false);
            },
            child: const Text(
              "Go Back",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }
}
