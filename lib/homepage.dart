import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hamaraprashasan/app_drawer.dart';
import 'package:hamaraprashasan/bookmarks.dart';
import 'package:hamaraprashasan/bottom_bar_icons_icons.dart';
import 'package:hamaraprashasan/departments_page.dart';
import 'package:hamaraprashasan/news_feed_page.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool imageLoadFailed = false;
  bool bottomSheetOpen = false;

  int _currentIndex = 0;
  List<Widget> _children;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (User.authUser.photoString == null) {
      storeProfilePic();
    }
    _children = [
      NewsFeedPage(
        showBottomSheet: showBottomSheet,
      ),
      DepartmentsPage(),
      BookmarkPage(
        showBottomSheet: showBottomSheet,
      ),
      Center(
        child: Text('Chat Page'),
      ),
    ];
  }

  void showBottomSheet(Widget Function(BuildContext) builder,
      {double elevation, ShapeBorder shape, Color backgroundColor}) async {
    if (_scaffoldKey.currentState.isDrawerOpen) Navigator.pop(context);
    var _bottomSheetController = _scaffoldKey.currentState.showBottomSheet(
        builder,
        elevation: elevation,
        shape: shape,
        backgroundColor: backgroundColor);
    setState(() {
      bottomSheetOpen = true;
    });
    await _bottomSheetController.closed;
    setState(() {
      bottomSheetOpen = false;
    });
  }

  void storeProfilePic() async {
    var resp = await http.get(User.authUser.photoUrl);
    final bytes = resp.bodyBytes;
    var encStr = base64.encode(bytes);
    User.authUser.setPhotoString(encStr);
    User.saveUserData(User.userData, User.lastUserState);
    print("Profile Pic Stored");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyAppDrawer(
        showBottomSheet: showBottomSheet,
      ),
      bottomNavigationBar: bottomSheetOpen
          ? null
          : BottomNavigationBar(
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
                          color: Color(0xff514A4A),
                          fontWeight: FontWeight.normal),
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
                          color: Color(0xff514A4A),
                          fontWeight: FontWeight.normal),
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
                          color: Color(0xff514A4A),
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ],
            ),
      body: IndexedStack(
        children: _children,
        index: _currentIndex,
      ),
    );
  }
}
