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