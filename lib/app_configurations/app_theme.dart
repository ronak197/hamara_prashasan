import 'package:flutter/material.dart';

class AppTheme{
  static ThemeData lightThemeData = ThemeData(
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 24.0, color: Colors.black, fontFamily: 'ProductSans'),
        headline5: TextStyle(fontSize: 22.0, color: Colors.black, fontFamily: 'ProductSans',),
        headline4: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'ProductSans',),
        headline3: TextStyle(color: Colors.black, fontSize: 18.0, fontFamily: 'ProductSans'),
        headline2: TextStyle(color: Colors.black, fontSize: 16.0, fontFamily: 'ProductSans'),
        headline1: TextStyle(color: Colors.black, fontSize: 14.0, fontFamily: 'ProductSans'),
        bodyText2: TextStyle(fontSize: 13.0, color: Colors.black, fontFamily: 'ProductSans'),
        bodyText1: TextStyle(fontSize: 12.0, color: Colors.black, fontFamily: 'ProductSans'),
      ));
}