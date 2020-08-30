import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamaraprashasan/app_configurations/app_configurations.dart';
import 'package:hamaraprashasan/app_configurations/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String startUpPage = await AppConfigs.getStartUpPage();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  /* SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    //statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  )); */

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white,
          /* set Status bar color in Android devices. */

          statusBarIconBrightness: Brightness.dark,
          /* set Status bar icons color in Android devices.*/

          statusBarBrightness:
              Brightness.dark) /* set Status bar icon color in iOS. */
      );

  runApp(MyApp(startUpPage));
}

class MyApp extends StatelessWidget {
  final String _defaultHome;

  MyApp(this._defaultHome);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: _defaultHome,
      onGenerateRoute: (settings) => AppConfigs.getUserRoutes(settings),
      theme: AppTheme.lightThemeData,
    );
  }
}
