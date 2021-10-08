import 'package:flutter/material.dart';
import 'package:newmap/Models/address.dart';
import 'package:newmap/Models/allUsers.dart';
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

  Users user;
  void updateProfile(Users users) {
    user = users;
    notifyListeners();
  }

  void userinfo(allUs) {}

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

  Locale _locale;
  Locale get locale => _locale ?? Locale('en');
  void changeLocale(Locale newLocale) {
    if (newLocale == Locale('ar')) {
      _locale = Locale('ar');
    } else {
      _locale = Locale('en');
    }
    notifyListeners();
  }

  double commission, killometer;
  void get_config(double commissions, double killometers) {
    commission = commissions;
    killometer = killometers;
    notifyListeners();
  }
    int randomNumber;
  void getRandomNumber(int ran) {
    randomNumber = ran;
    notifyListeners();
  }
int phone;
  void getphone(int phones) {
    phone = phones;
  }
}
