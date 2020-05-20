import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hamaraprashasan/homepage.dart';
import 'package:hamaraprashasan/login_page.dart';
import 'package:hamaraprashasan/send_post_page.dart';
import 'package:hamaraprashasan/bookmarks.dart';
import 'package:hamaraprashasan/news_feed_page.dart';
import 'package:hamaraprashasan/feedInfoPage.dart';

class AppConfigurations{

  static SharedPreferences prefs;
  static String userType = 'user';
  static AuthUser signedUser;

  static Future<SharedPreferences> get getSharedPrefInstance async{
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  static SharedPreferences get getSharedPref{
    if(prefs == null){
      getSharedPrefInstance;
    }
    return prefs;
  }

  static set setSigningState(bool value){
    prefs.setBool('signingState', value);
  }

  static bool get getSigningState{
    return prefs.getBool('signingState') ?? false;
  }

  static saveUserDetails(String displayName, String email, String phoneNumber, String photoUrl, String uid){
    signedUser = AuthUser(
      displayName: displayName,
      email: email,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      uid: uid
    );
    prefs.setString('displayName', displayName);
    prefs.setString('email', email);
    prefs.setString('phoneNumber', phoneNumber);
    prefs.setString('photoUrl', photoUrl);
    prefs.setString('uid', uid);
  }

  static getUserDetails(){
    signedUser = AuthUser(
      displayName : prefs.getString('displayName'),
      email : prefs.getString('email'),
      phoneNumber : prefs.getString('phoneNumber'),
      photoUrl : prefs.getString('photoUrl'),
      uid : prefs.getString('uid'),
    );
  }

  static get getUserRoutes{
    if(userType == 'admin'){
      return {
        '/home' : (context) => HomePage(),
        '/login' : (context) => LoginPage(),
        '/sendPost' : (context) => SendPostPage(),
        '/newsFeed' : (context) => NewsFeedPage(),
        '/feedInfo' : (context) => FeedInfoPage(),
        '/bookmarks' : (context) => BookmarkPage()
      };
    }
    return {
      '/home' : (context) => HomePage(),
      '/login' : (context) => LoginPage(),
      '/sendPost' : (context) => SendPostPage(),
      '/newsFeed' : (context) => NewsFeedPage(),
      '/feedInfo' : (context) => FeedInfoPage(),
      '/bookmarks' : (context) => BookmarkPage(),
    };
  }
}

class AuthUser{
  String displayName;
  String email;
  String phoneNumber;
  String photoUrl;
  String uid;

  AuthUser({this.displayName,this.email,this.phoneNumber,this.photoUrl,this.uid});
}