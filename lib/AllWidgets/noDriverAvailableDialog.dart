import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../configMap.dart';

class NoDriverAvailableDialog extends StatelessWidget {
  static const String idScreen = "dialog";
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
  blurRadius: 10.0,
                            spreadRadius: 0.9,
                            offset: Offset(0.0, 0.0),
                            color: textcolor.withOpacity(0.25)
            ),
            ]
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                 AppLocalizations.of(context).nodriverfound,
                  style: TextStyle(fontSize: 22.0, fontFamily: 'segoebold'),
                ),
                SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                     AppLocalizations.of(context).noavailabledriverfound,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22.0, fontFamily: 'segoebold'),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                   style: ElevatedButton.styleFrom(
                            primary: primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0))),
                    child: Padding(
                      padding: EdgeInsets.all(17.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                                              AppLocalizations.of(context).close,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Icon(
                            Icons.car_repair,
                            color: Colors.white,
                            size: 26.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
