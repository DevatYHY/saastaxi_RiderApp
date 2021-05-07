import 'package:flutter/material.dart';
import 'package:newmap/AllWidgets/Divider.dart';
import 'package:newmap/AllWidgets/progressDialog.dart';
import 'package:newmap/Assistants/requsestAssistant.dart';
import 'package:newmap/DataHandler/appData.dart';
import 'package:newmap/Models/address.dart';
import 'package:newmap/Models/placePrediction.dart';
import 'package:newmap/configMap.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOfTextEditingController = TextEditingController();
  List<Properties> placePredictionsList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress;
    if (Provider.of<AppData>(context).pickUpLocation.placeName != null) {
      placeAddress = Provider.of<AppData>(context).pickUpLocation.placeName;
    } else {
      placeAddress = "";
    }
   
    pickUpTextEditingController.text = placeAddress;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Container(
              height: 202.0,
              decoration: BoxDecoration(color: backgroundcolor, boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6.0,
                  spreadRadius: 0.05,
                  offset: Offset(0.7, 0.7),
                )
              ]),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 25.0, top: 25.0, right: 25.0, bottom: 20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          child: Icon(Icons.arrow_back,color: primary,),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        Center(
                          child: Text(
                            "Search for Place",
                            style:
                                TextStyle(fontSize: 18, fontFamily: "Brand Bold",color: textcolor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/pickicon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(6.0),
                              child: TextField(
                                controller: pickUpTextEditingController,
                                decoration: InputDecoration(
                                  hintText: "PickUp Location",
                                 
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/desticon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(6.0),
                              child: TextField(
                                onChanged: (val) {
                                  findPlace(val);
                                },
                                controller: dropOfTextEditingController,
                                decoration: InputDecoration(
                                  hintText: "Where to ?",
                                   hintStyle: TextStyle(color:textcolor),
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            //SEARCH RES+++++++++++++++++++++++++
            SizedBox(
              height: 10.0,
            ),
            (placePredictionsList.length > 0)
                ? SingleChildScrollView(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                      child: ListView.separated(
                        padding: EdgeInsets.all(0.0),
                        itemBuilder: (context, index) {
                          return PredictionTitle(
                            placePredictions: placePredictionsList[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            DividerWidget(),
                        itemCount: placePredictionsList.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                      ),
                    ),
                )
                : Container()
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleterUrl =
          "https://api.geoapify.com/v1/geocode/autocomplete?text=$placeName&limit=5&apiKey=$keyOfMap";

      var res = await RequstAssistant.getRequest(autoCompleterUrl);

      if (res == "failed") {
        return;
      }
      if (res != "failed") {
        var prediction = res["features"];

        var placeList =
            (prediction as List).map((e) => Properties.fromJson(e)).toList();
        print(placeList.length);
        setState(() {
          placePredictionsList = placeList;
        });
        print(prediction);
      }
    }
  }
}

class PredictionTitle extends StatelessWidget {
  final Properties placePredictions;

  const PredictionTitle({Key key, this.placePredictions}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceAddressDetails(placePredictions.placeId, context);
      },
      child: Container(
        decoration: BoxDecoration(color: bordercolor,
        borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            SizedBox(
              width: 10.0,
            ),
            Row(
              children: [
                Icon(Icons.add_location,color: primary,),
                SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.0),
                      Text(
                        placePredictions.name.toString(),
                        style: TextStyle(fontSize: 16,color: secondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        placePredictions.street.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              width: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Setting Dropoff",
            ));

    String placeDetailsUrl =
        "https://api.geoapify.com/v2/place-details?id=$placeId&apiKey=$keyOfMap";

    var res = await RequstAssistant.getRequest(placeDetailsUrl);

    Navigator.pop(context);

    if (res == "failed") {
      return;
    }
    if (res != "failed") {
      Address address = Address();
      address.placeName = res["features"][0]["properties"]["name"];
      address.placrId = placeId;
      address.latitude = res["features"][0]["properties"]["lat"];
      address.longitude = res["features"][0]["properties"]["lon"];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);
      print("++++++++++++++++++++++++++++++++++++++++");
      print(address.placeName);
      print(address.latitude);
      print(address.longitude);
      Navigator.pop(context, "obtainDirection");
    }
  }
}
