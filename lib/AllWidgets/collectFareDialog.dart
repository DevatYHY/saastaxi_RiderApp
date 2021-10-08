import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CollectFareDialog extends StatelessWidget {
  final String paymentMethod;
  final int fareAmount;
  CollectFareDialog({this.paymentMethod, this.fareAmount});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 22.0,
            ),
            Text( AppLocalizations.of(context).tripfare,),
            SizedBox(
              height: 22.0,
            ),
            Divider(
              height: 2.0,
              thickness: 2.0,
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              "\$$fareAmount",
              style: TextStyle(
                fontSize: 55.0,
                fontFamily: "segoebold",
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
               AppLocalizations.of(context).thetotalamount,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context,"close");

                },
                 style: ElevatedButton.styleFrom(
                primary:  Colors.deepPurpleAccent,
              ),
                
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                    AppLocalizations.of(context).paycash,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Icon(
                      Icons.attach_money,
                      color: Colors.white,
                      size: 26.0,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            )
          ],
        ),
      ),
    );
  }

}
