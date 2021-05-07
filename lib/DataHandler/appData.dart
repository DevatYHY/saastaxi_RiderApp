import 'package:flutter/material.dart';
import 'package:newmap/Models/address.dart';
import 'package:newmap/Models/history.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation, dropOffLocation;
  int countTrips = 0;
  List<String> tripHistoryKeys = [];
  List<History> tripHistoryDataList = [];
  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

  



  void updateTripsCounter(int tripCounter) {
    countTrips = tripCounter;
    notifyListeners();
  }

  
  void updateTripkeys(List<String> newKeys) {
    tripHistoryKeys = newKeys;
    notifyListeners();
  }

 
  void updateTripHistoryData(History eachHistory) {
    tripHistoryDataList.add(eachHistory);
    notifyListeners();
  }
}
