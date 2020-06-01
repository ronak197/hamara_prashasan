//import 'package:flutter/material.dart';
//
//class ImageData {
//  String url;
//  bool isLocal;
//  ImageData({@required this.url, this.isLocal}) {
//    if (this.isLocal == null) this.isLocal = false;
//  }
//}
//
//class TitleData {
//  String title;
//  TitleData({@required this.title});
//}
//
//class ContentData {
//  String text;
//  ContentData({@required this.text});
//}
//
//class MapData {
//  List<double> latitude, longitude;
//  List<String> name;
//  MapData(
//      {@required this.latitude, @required this.longitude, @required this.name});
//}
//
//class TableData {
//  List<String> headers;
//  List<List<String>> contents;
//  TableData({@required this.headers, @required this.contents})
//      : assert(contents.length == 0 ||
//            (contents.length > 0 && headers.length == contents[0].length));
//}
//
//class Feed {
//  DateTime time;
//  TitleData firstTitle;
//  List<dynamic> contents;
//  Department department;
//  LocationData location;
//  Feed({
//    @required this.contents,
//    @required this.location,
//    @required this.time,
//    @required this.department,
//    @required this.firstTitle,
//  });
//}
//
//class LocationData {
//  String city, state, country;
//  LocationData({
//    @required this.city,
//    @required this.country,
//    @required this.state,
//  });
//}
//
//class Department {
//  String name, logoUrl;
//  Department({@required this.logoUrl, @required this.name});
//}
