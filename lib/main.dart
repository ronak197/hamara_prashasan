import 'package:flutter/material.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:hamaraprashasan/homepage.dart';
import 'package:hamaraprashasan/login_page.dart';
import 'package:hamaraprashasan/send_post_page.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  String startUpPage;
  await AppConfigurations.getSharedPrefInstance;
  if(AppConfigurations.getSigningState){
    startUpPage = '/home';
  } else {
    startUpPage = '/login';
  }

  runApp(
      MyApp(startUpPage)
  );
}

class MyApp extends StatelessWidget {

  String _defaultHome;

  MyApp(this._defaultHome);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: _defaultHome,
      routes: AppConfigurations.getUserRoutes,
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
