import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hamaraprashasan/myFeeds.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hamaraprashasan/homepage.dart';
import 'package:hamaraprashasan/login_page.dart';
import 'package:hamaraprashasan/send_post_page.dart';
import 'package:hamaraprashasan/bookmarks.dart';
import 'package:hamaraprashasan/news_feed_page.dart';
import 'package:hamaraprashasan/feedInfoPage.dart';
import 'package:hamaraprashasan/classes.dart';

enum UserState {
  none, // State when user launched the app
  initial, // State when the user has fetched user data from firestore
  subscription, // State when the user has subscribed/unsubscribed a department
  feedUpdate, // State when the user has updated the feed
  bookmark //State when the user has updated the bookmark id list
}

class AppConfigs {
  static SharedPreferences prefs;
  static String userType = 'user';

  static Future<SharedPreferences> get initializeSharedPref async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  static SharedPreferences get getSharedPref {
    if (prefs == null) {
      initializeSharedPref;
    }
    return prefs;
  }

  static set setSigningState(bool value) {
    prefs.setBool('signingState', value);
  }

  static bool get getSigningState {
    return prefs.getBool('signingState') ?? false;
  }

  static clearAllLocalData() {
    prefs.clear();
  }

  static Future<String> getStartUpPage() async {
    String startUpPage;
    await AppConfigs.initializeSharedPref;
    if (AppConfigs.getSigningState &&
        User.getUserAuthInfo() &&
        User.getUserData()) {
      print('perfect credential combo');
      startUpPage = '/home';
    } else {
      print('credentials not enough, loading loginpage');
//    signOutGoogle(); TODO: Check into firebase if below line really has any effects
      startUpPage = '/login';
    }
    return startUpPage;
  }

  static get getUserRoutes {
    if (userType == 'admin') {
      return {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/sendPost': (context) => SendPostPage(),
        '/newsFeed': (context) => NewsFeedPage(),
        '/feedInfo': (context) => FeedInfoPage(),
        '/bookmarks': (context) => BookmarkPage()
      };
    }
    return {
      '/home': (context) => HomePage(),
      '/login': (context) => LoginPage(),
      '/sendPost': (context) => SendPostPage(),
      '/newsFeed': (context) => NewsFeedPage(),
      '/feedInfo': (context) => FeedInfoPage(),
      '/bookmarks': (context) => BookmarkPage(),
      '/myfeeds': (context) => MyFeedsPage(),
    };
  }
}

class User {
  static AuthUser authUser;
  static UserData userData;
  static UserState lastUserState = UserState.initial;

  // Saving authentication credentials received from google_sign_in into shared pref and authUser
  static saveUserAuthInfo(FirebaseUser firebaseUser) {
    authUser = AuthUser(
        displayName: firebaseUser.displayName,
        email: firebaseUser.email,
        phoneNumber: firebaseUser.phoneNumber,
        photoUrl: firebaseUser.photoUrl,
        uid: firebaseUser.uid);
    AppConfigs.prefs.setString('authUserDetails', jsonEncode(authUser));
  }

  // Fetching authentication credentials received from google_sign_in from shared pref
  static bool getUserAuthInfo() {
    var jsonData = AppConfigs.prefs.getString('authUserDetails') ?? false;
    if (jsonData == false) {
      return false;
    }
    authUser = AuthUser.fromJson(jsonDecode(jsonData));
    return true;
  }

  // Saving user data locally in shared pref and also in UserConfig static user variable
  static saveUserData(UserData data, UserState newUserState) {
    userData = data;
    lastUserState = newUserState;
    AppConfigs.prefs.setString('userData', jsonEncode(userData.toJson()));
  }

  // To fetch the user data from the shared pref and store it in UserConfig static user variable
  static bool getUserData() {
    var jsonData = AppConfigs.prefs.getString('userData') ?? false;
    if (jsonData == false) {
      return false;
    }
    userData = UserData.fromJson(jsonDecode(jsonData));
    lastUserState = UserState.initial;
    return true;
  }
}

class FirebaseMethods {
  /* Fetch user data from the firestore. This function is mainly evoked when
  * app is first started or the user has first time logged in.
  */
  static Future<bool> getFirestoreUserDataInfo() async {
    Firestore db = Firestore.instance;
    bool val = await db
        .collection('users')
        .document(User.authUser.uid)
        .get()
        .then((snapshot) async {
      print('User doc Exists : ${snapshot.exists}');
      if (snapshot.data != null) {
        print('Registered user data: ${snapshot.data}');
        User.saveUserData(
            UserData.fromFirestoreJson(snapshot.data), UserState.initial);
      } else {
        print('user not registered, going to create new user doc');
        return await createNewFirestoreUserDocument();
      }
      return true;
    }, onError: (e) {
      print('Some error occurred');
      return false;
    });
    print('Got outside of query, gonna return $val');
    return val;
  }

  // To create new firestore user document when the user first time logged in.
  static Future<bool> createNewFirestoreUserDocument() async {
    Firestore db = Firestore.instance;
    UserData userData = UserData(
        subscribedDepartmentIDs: [],
        lastLocation:
            LatLng(0, 0), // TODO: To change this to more suitable value
        lastUserState: 'initial',
        lastUpdateTime: DateTime.now(),
        bookmarkedFeeds: [],
        userType: 'citizen',
        email: User.authUser.email);
    bool val = await db
        .collection('users')
        .document(User.authUser.uid)
        .setData(
          userData.toFirestoreJson(),
        )
        .then((value) {
      print('successfully created new user doc in firestore');
      User.saveUserData(userData, UserState.initial);
      return true;
    }, onError: (e) {
      print('ERROR: could not create new user doc in firestore');
      return false;
    });
    return val;
  }

  static Future<bool> saveBookmarks(List<String> allBookmarkedFeedIds) async {
    Firestore db = Firestore.instance;
    bool val = await db
        .collection('users')
        .document(User.authUser.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.data != null) {
        print('User doc Exists : ${snapshot.exists}');
        bool error = false;
        await snapshot.reference.updateData(
            {"bookmarkedFeeds": allBookmarkedFeedIds}).catchError((e) {
          error = true;
        });
        return !error;
      } else {
        return false;
      }
    }, onError: (e) {
      print('Some error occurred');
      return false;
    });
    if (val) {
      User.userData.bookmarkedFeeds = allBookmarkedFeedIds;
      User.saveUserData(User.userData, User.lastUserState);
    }
    return val;
  }

  static Future<bool> deleteMyFeeds(List<String> deletedFeedIds) async {
    Firestore db = Firestore.instance;
    bool val = await db
        .collection('feeds')
        .where("feedId", whereIn: deletedFeedIds)
        .getDocuments()
        .then((snapshot) async {
      if (snapshot.documents.isNotEmpty) {
        snapshot.documents.forEach((doc) async {
          bool error = false;
          try {
            FeedInfo feedInfo = FeedInfo.fromFirestoreJson(doc.data);
            if (feedInfo.departmentUid == User.authUser.email) {
              await doc.reference.delete();
            } else {
              print("User email not equal to departmentUid of feed");
            }
          } catch (e) {
            error = true;
          }
          return !error;
        });
      }
      return false;
    });
    return val;
  }
}
