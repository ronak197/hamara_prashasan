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
