import 'dart:convert';
import 'package:hamaraprashasan/app_configurations/app_configurations.dart';

class AuthUser {
  String displayName;
  String email;
  String phoneNumber;
  String photoUrl;
  String localPhotoLoc;
  String uid;

  AuthUser(
      {this.displayName,
        this.email,
        this.phoneNumber,
        this.photoUrl,
        this.localPhotoLoc,
        this.uid});

  void setPhotoLoc(String s) {
    this.localPhotoLoc = s;
    AppConfigs.prefs.setString('authUserDetails', jsonEncode(this));
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    displayName: json["displayName"],
    email: json["email"],
    phoneNumber: json["phoneNumber"],
    photoUrl: json["photoUrl"],
    uid: json["uid"],
    localPhotoLoc: json['localPhotoLoc'],
  );

  Map<String, dynamic> toJson() => {
    "displayName": displayName,
    "email": email,
    "phoneNumber": phoneNumber,
    "photoUrl": photoUrl,
    "uid": uid,
    "localPhotoLoc": localPhotoLoc,
  };
}
