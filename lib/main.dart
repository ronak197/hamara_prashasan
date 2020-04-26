import 'package:flutter/material.dart';

import 'package:hamaraprashasan/homepage.dart';

void main() => runApp(
  MyApp()
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 24.0,
            color: Colors.black,
            fontFamily: 'OpenSans'
          ),
          headline5: TextStyle(
            fontSize: 22.0,
            color: Colors.black,
            fontFamily: 'OpenSans',
          ),
          headline4: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              fontFamily: 'OpenSans',
          ),
          headline3: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontFamily: 'OpenSans'
          ),
          headline2: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontFamily: 'OpenSans'
          ),
          headline1: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontFamily: 'OpenSans'
          ),
          bodyText1: TextStyle(
            fontSize: 12.0,
            color: Colors.black,
            fontFamily: 'OpenSans'
          ),
        )
      ),
    );
  }
}
