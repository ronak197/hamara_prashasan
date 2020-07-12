import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:hamaraprashasan/bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationBloc implements Bloc{

  static String _location;

  static String get currentColor => _location;

  static final StreamController _locationController = StreamController<String>.broadcast();

  static Stream<String> get locationStream => _locationController.stream;

  static getRecentLocation() async {
    print('fetching last location');
    Geolocator geoLocator = Geolocator();
    GeolocationStatus geolocationStatus  = await geoLocator.checkGeolocationPermissionStatus();
    if(geolocationStatus == GeolocationStatus.granted){
      Position position = (await geoLocator.getLastKnownPosition(desiredAccuracy: LocationAccuracy.lowest,)) ?? (await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest));
      List<Placemark> placemark = await geoLocator.placemarkFromPosition(position);
      print(placemark);
      String userLocation = '${placemark[0].subLocality}, ${placemark[0].locality}';
      _locationController.sink.add(userLocation);
    } else {
      await Permission.location.request();
      if(await geoLocator.checkGeolocationPermissionStatus() == GeolocationStatus.granted){
        getRecentLocation();
      }
      print('Permission not granted');
    }
  }

  static getNewLocation() async{
    print('fetching new location');
    Geolocator geoLocator = Geolocator()..forceAndroidLocationManager = true;
    GeolocationStatus geolocationStatus  = await geoLocator.checkGeolocationPermissionStatus();
    if(geolocationStatus == GeolocationStatus.granted){
      print('Permission granted');
      Position position = (await geoLocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest)
          .catchError((e){print(e);})
          .timeout(Duration(seconds: 3),onTimeout: (){
        print('timeout in fetch new location');
        return null;
      }));
      print(position.toString());
      List<Placemark> placemark = await geoLocator.placemarkFromPosition(position).catchError((e){print(e);});
      _locationController.sink.add('${placemark[0].subLocality}, ${placemark[0].locality}');
    } else {
      print('permission not granted');
    }
  }


  @override
  void dispose() {
    _locationController.close();
  }
}
