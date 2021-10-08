import 'package:flutter/material.dart';
import 'package:newmap/configMap.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class RatingScreen extends StatefulWidget {
  final String driverId;

  RatingScreen({this.driverId});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Dialog(
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
              Text(
                 AppLocalizations.of(context).ratedriver,
                style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: "Brand Bold",
                    color: Colors.black54),
              ),
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
              SmoothStarRating(
                rating: starCounter,
                color: Colors.green,
                allowHalfRating: false,
                starCount: 5,
                size: 45,
                onRated: (v) {
                  starCounter = v;
                  if (starCounter == 1) {
                    setState(() {
                      title = "Very Bad";
                    });
                  } else if (starCounter == 2) {
                    setState(() {
                      title = "Bad";
                    });
                  } else if (starCounter == 3) {
                    setState(() {
                      title = "Good";
                    });
                  } else if (starCounter == 4) {
                    setState(() {
                      title = "Very Good";
                    });
                  } else if (starCounter == 5) {
                    setState(() {
                      title = "Excellent";
                    });
                  }
                },
              ),
              SizedBox(
                height: 14.0,
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 55.0,
                    fontFamily: "Signatra",
                    color: Colors.green),
              ),
              SizedBox(
                height: 16.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    DatabaseReference driverRatingRef = FirebaseDatabase
                        .instance
                        .reference()
                        .child('drivers')
                        .child(widget.driverId.toString())
                        .child('ratings');

                    driverRatingRef.once().then((DataSnapshot snap) {
                      if (snap.value != null) {
                        double oldratings = double.parse(snap.value.toString());
                        double addRatings = oldratings + starCounter;
                        double averageRating = addRatings / 2;
                        driverRatingRef.set(averageRating.toString());
                      } else {
                        driverRatingRef.set(starCounter.toString());
                      }
                    });
                    Navigator.pop(context);
                  },
                  // color: Colors.deepPurpleAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations.of(context).submit,
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
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
      ),
    );
  }
}