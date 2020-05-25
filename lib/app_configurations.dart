import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hamaraprashasan/homepage.dart';
import 'package:hamaraprashasan/login_page.dart';
import 'package:hamaraprashasan/send_post_page.dart';
import 'package:hamaraprashasan/bookmarks.dart';
import 'package:hamaraprashasan/news_feed_page.dart';
import 'package:hamaraprashasan/feedInfoPage.dart';
import 'package:hamaraprashasan/classes.dart';

enum UserState{
  none, // State when user launched the app
  initial, // State when the user has fetched user data from firestore
  subscription, // State when the user has subscribed/unsubscribed a department
  feedUpdate // State when the user has updated the feed
}

class AppConfigurations{

  static SharedPreferences prefs;
  static String userType = 'user';

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

  static clearAllLocalData(){
    prefs.clear();
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

class UserConfig{

  static AuthUser signedUser;
  static User user;
  static UserState lastUserState = UserState.none;

  static saveUserAuthInfo(FirebaseUser firebaseUser){
    signedUser = AuthUser(
        displayName: firebaseUser.displayName,
        email: firebaseUser.email,
        phoneNumber: firebaseUser.phoneNumber,
        photoUrl: firebaseUser.photoUrl,
        uid: firebaseUser.uid
    );
    AppConfigurations.prefs.setString('authUserDetails', jsonEncode(signedUser));
  }

  static bool getUserAuthInfo(){
    var jsonData = AppConfigurations.prefs.getString('authUserDetails') ?? false;
    if(jsonData == false){
      return false;
    }
    signedUser = AuthUser.fromJson(jsonDecode(jsonData));
    return true;
  }

  // Saving user data locally in shared pref and also in UserConfig static user variable
  static saveUserData(User data, UserState newUserState){
    user = data;
    lastUserState = newUserState;
    AppConfigurations.prefs.setString('userData', jsonEncode(user.toJson()));
  }

  // To fetch the user data from the shared pref and store it in UserConfig static user variable
  static bool getUserData(){
    var jsonData = AppConfigurations.prefs.getString('userData') ?? false;
    if(jsonData == false){
      return false;
    }
    user = User.fromJson(jsonDecode(jsonData));
    UserConfig.lastUserState = UserState.initial;
    return true;
  }

  // Stream of user state. User states change whenever saving user data i.e calling saveUserData() function.
  // User States define what was the purpose/event to update the user data.
  static Stream<UserState> getUserState(){
//    return UserConfig._controller.stream;
  }
}

class FirebaseMethods{

  /* Fetch user data from the firestore. This function is mainly evoked when
  * app is first started or the user has first time logged in.
  */
  static Future<bool> getFirestoreUserDataInfo() async{
    Firestore db = Firestore.instance;
    await db.collection('users').document(UserConfig.signedUser.uid).get().then((snapshot) async{
      print(snapshot.data);
      if(snapshot.data == null){
        print('user not registered, going to create new user doc');
        return await createNewFirestoreUserDocument();
      } else{
        print('registered user');
        UserConfig.saveUserData(User.fromJson(snapshot.data), UserState.initial);
      }
      return true;
    },
        onError: (e){
      print('Some error occurred');
          return false;
        });
    return UserConfig.lastUserState == UserState.initial;
  }

  // To create new firestore user document when the user first time logged in.
  static Future<bool> createNewFirestoreUserDocument() async{
    Firestore db = Firestore.instance;
    UserConfig.user = User(
        subscribedDepartmentIDs: [],
        lastLocation: LatLng(0,0),
        lastFeedUpdateTime: null,
        bookmarkedFeeds: [],
        userType: 'citizen',
        email: UserConfig.signedUser.email
    );
    await db.collection('users').document(UserConfig.signedUser.uid).setData(
      UserConfig.user.toFirestoreJson(),
    ).then((value){
      UserConfig.saveUserData(UserConfig.user, UserState.initial);
      return true;
    }, onError: (e){
      return false;
    });
    return null;
  }
}