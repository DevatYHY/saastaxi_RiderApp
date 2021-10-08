import 'package:firebase_database/firebase_database.dart';

class Users {
  String id;
  String name;
  String email;
  String phone;
  String image;
  Users({this.id, this.email, this.name, this.phone, this.image});
  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    if (dataSnapshot != null) {
      id = dataSnapshot.key;
      email = dataSnapshot.value["email"];
      name = dataSnapshot.value["name"];
      phone = dataSnapshot.value["phone"];
      image = dataSnapshot.value["photo"];
    } else {
      return;
    }
  }
}
