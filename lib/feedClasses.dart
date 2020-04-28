import 'package:flutter/material.dart';

class ImageData {
  String url;
  ImageData({@required this.url});
}

class TextData {
  String text;
  TextData({@required this.text});
}

class MapData {
  List<double> latitude, longitude;
  List<String> name;
  MapData(
      {@required this.latitude, @required this.longitude, @required this.name});
}

class TableData {
  List<String> headers;
  List<List<String>> contents;
  TableData({@required this.headers, @required this.contents})
      : assert(contents.length == 0 ||
            (contents.length > 0 && headers.length == contents[0].length));
}
