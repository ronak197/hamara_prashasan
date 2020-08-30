import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hamaraprashasan/home_page/app_drawer/app_drawer.dart';
import 'package:hamaraprashasan/home_page/bookmarks_tab/bookmarks_page.dart';
import 'package:hamaraprashasan/helper_classes/app_icons/bottom_bar_icons_icons.dart';
import 'package:hamaraprashasan/home_page/chat_page/chat_page.dart';
import 'package:hamaraprashasan/home_page/departments_tab/departments_page.dart';
import 'package:hamaraprashasan/blocs/location_bloc.dart';
import 'package:hamaraprashasan/home_page/feed_tab/news_feed_page.dart';
import 'package:hamaraprashasan/app_configurations/app_configurations.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool imageLoadFailed = false;

  int _currentIndex = 0;
  List<Widget> _children;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (User.authUser.localPhotoLoc == null) {
      storeProfilePic();
    } else {
      print("Profile Pic already stored!!");
    }
    setBottomNavigationChildren();
  }

  void setBottomNavigationChildren() {
    _children = [
      NewsFeedPage(
        showBottomSheet: showBottomSheet,
      ),
      DepartmentsPage(),
      BookmarkPage(
        showBottomSheet: showBottomSheet,
      ),
      ChatPage(),
    ];

    LocationBloc.getRecentLocation();
  }

  void showBottomSheet(Widget Function(BuildContext) builder,
      {double elevation, ShapeBorder shape, Color backgroundColor}) async {
    if (_scaffoldKey.currentState.isDrawerOpen) Navigator.pop(context);
    showModalBottomSheet(
        context: context,
        builder: builder,
        elevation: elevation,
        shape: shape,
        backgroundColor: backgroundColor);
  }

  void storeProfilePic() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    await Directory(documentDirectory.path + "/images").create(recursive: true);
    var profilePicPath = documentDirectory.path + "/images/profilePic.jpg";
    var resp = await http.get(User.authUser.photoUrl);
    File profilePic = File(profilePicPath);
    await profilePic.writeAsBytes(resp.bodyBytes);
    User.authUser.setPhotoLoc(profilePicPath);
    setState(() {
      setBottomNavigationChildren();
    });
    print("Profile Pic Stored");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: MyAppDrawer(
          showBottomSheet: showBottomSheet,
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 10.0,
          showSelectedLabels: true,
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() {
              _currentIndex = i;
            });
          },
          items: [
            BottomNavigationBarItem(
                activeIcon: Icon(
                  Icons.rss_feed,
                  color: Color(0xff02CCFF),
                  size: 23.0,
                ),
                icon: Icon(
                  Icons.rss_feed,
                  color: Color(0xff393A4E),
                  size: 24.0,
                ),
                title: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    'News Feed',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Color(0xff514A4A),
                        fontWeight: FontWeight.normal),
                  ),
                )),
            BottomNavigationBarItem(
              activeIcon: Icon(
                BottomBarIcons.building,
                color: Color(0xffEAAC00),
                size: 23.0,
              ),
              icon: Icon(
                BottomBarIcons.building,
                color: Color(0xff393A4E),
                size: 22.0,
              ),
              title: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  'Departments',
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Color(0xff514A4A), fontWeight: FontWeight.normal),
                ),
              ),
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.bookmark_border,
                color: Color(0xff01E14C),
                size: 23.0,
              ),
              icon: Icon(
                Icons.bookmark_border,
                color: Color(0xff393A4E),
                size: 24.0,
              ),
              title: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  'Bookmarks',
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Color(0xff514A4A), fontWeight: FontWeight.normal),
                ),
              ),
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.chat_bubble_outline,
                color: Color(0xffF3E47A),
                size: 22.0,
              ),
              icon: Icon(
                Icons.chat_bubble_outline,
                color: Color(0xff393A4E),
                size: 21.0,
              ),
              title: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  'Chat Page',
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Color(0xff514A4A), fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          children: _children,
          index: _currentIndex,
        ),
      ),
    );
  }
}
