import 'package:flutter/material.dart';
import 'package:newmap/AllWidgets/HistoryItem.dart';
import 'package:newmap/DataHandler/appData.dart';
import 'package:provider/provider.dart';
import 'package:newmap/configMap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'mainscreen.dart';
class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).history,
          style: TextStyle(
              fontFamily: "segoebold", color: textcolor, fontSize: 28),
        ),
        backgroundColor: primary,
        leading: GestureDetector(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, MainScreen.idScreen, (route) => false);
            },
            child: Icon(
              Icons.keyboard_arrow_left,
              color: textcolor,
              size: 45,
            )),
      
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return Provider.of<AppData>(context,listen: false).tripHistoryDataList[index].fares!=null? HistoryItem(
            history: Provider.of<AppData>(context,listen: false).tripHistoryDataList[index],
          ):SizedBox();
        },
       
        itemCount: Provider.of<AppData>(context,listen: false).tripHistoryDataList.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
