import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamaraprashasan/send_post_page.dart';
import 'package:hamaraprashasan/bookmarks.dart';
import 'package:hamaraprashasan/bottom_bar_icons_icons.dart';
import 'package:hamaraprashasan/app_bar_icons_icons.dart';
import 'package:hamaraprashasan/departments_page.dart';
import 'package:hamaraprashasan/drawer_icons_icons.dart';
import 'package:hamaraprashasan/news_feed_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget> _children;
  NewsFeedPage newsFeedPage;
  DepartmentsPage departmentsPage;
  BookmarkPage bookmarkPage;
  bool feedSelected = false, bookmarkSelected = false;

  void anyFeedSelected() {
    setState(() {
      feedSelected = true;
    });
  }

  void allSelectedFeedCleared() {
    setState(() {
      feedSelected = false;
    });
  }

  void clearSelectedFeed() {
    setState(() {
      feedSelected = false;
    });
    newsFeedPage.clearSelectedFeed();
  }

  void anyBookmarkSelected() {
    setState(() {
      bookmarkSelected = true;
    });
  }

  void allSelectedBookmarkCleared() {
    setState(() {
      bookmarkSelected = false;
    });
  }

  void clearSelectedBookmark() {
    setState(() {
      bookmarkSelected = false;
    });
    bookmarkPage.clearSelectedBookmark();
  }

  @override
  void initState() {
    super.initState();
    newsFeedPage = new NewsFeedPage(
      anyFeedSelected: anyFeedSelected,
      allSelectedFeedCleared: allSelectedFeedCleared,
    );
    bookmarkPage = new BookmarkPage(
      anyBookmarkSelected: anyBookmarkSelected,
      allSelectedBookmarkCleared: allSelectedBookmarkCleared,
    );
    departmentsPage = new DepartmentsPage();
    _children = [
      newsFeedPage,
      departmentsPage,
      bookmarkPage,
      Center(
        child: Text('Chat Page'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: feedSelected && _currentIndex == 0
          ? AppBar(
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
              elevation: 5.0,
              titleSpacing: 0.0,
              leading: IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 30.0,
                ),
                onPressed: clearSelectedFeed,
              ),
              actions: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      size: 30.0,
                    ),
                    onPressed: () {},
                  ),
                )
              ],
            )
          : bookmarkSelected && _currentIndex == 2
              ? AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.white,
                  elevation: 5.0,
                  titleSpacing: 0.0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 30.0,
                    ),
                    onPressed: clearSelectedBookmark,
                  ),
                  actions: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 30.0,
                          color: Colors.red,
                        ),
                        onPressed: () {},
                      ),
                    )
                  ],
                )
              : AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black,
                  ),
                  automaticallyImplyLeading: true,
                  backgroundColor: Colors.white,
                  elevation: 0.0,
                  titleSpacing: 0.0,
                  actions: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        AppBarIcons.filter,
                        size: 20.0,
                      ),
                    )
                  ],
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Welcome Ronak',
                          style: Theme.of(context).textTheme.headline4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              height: 16.0,
                              alignment: Alignment.bottomCenter,
                              child: Center(
                                  child: Icon(
                                AppBarIcons.location,
                                size: 10.0,
                                color: Color(0xff6D6D6D),
                              ))),
                          Container(
                              height: 16.0,
                              alignment: Alignment.topLeft,
                              child: Center(
                                  child: Text('Surat',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(color: Color(0xff6D6D6D)))))
                        ],
                      )
                    ],
                  ),
                ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                radius: 50.0,
                child: Text('RJ',
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: Colors.white)),
              ),
              decoration: BoxDecoration(color: Color(0xff02CCFF)),
              accountEmail: Text(
                'jain.ronak197@gmail.com',
                style: Theme.of(context)
                    .textTheme
                    .headline1
                    .copyWith(color: Colors.white),
              ),
              accountName: Text('Ronak Jain',
                  style: Theme.of(context).textTheme.headline1.copyWith(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context){
                      return SendPostPage();
                    }
                  )
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(
                        DrawerIcons.paper_plane,
                        color: Colors.black,
                        size: 18.0,
                      )),
                  Text(
                    'Make a Public Post',
                    style: Theme.of(context).textTheme.headline2,
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(
                        DrawerIcons.notifications,
                        color: Colors.black,
                        size: 18.0,
                      )),
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.headline2,
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(
                        DrawerIcons.general,
                        color: Colors.black,
                        size: 18.0,
                      )),
                  Text(
                    'General',
                    style: Theme.of(context).textTheme.headline2,
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(
                        DrawerIcons.account,
                        color: Colors.black,
                        size: 18.0,
                      )),
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.headline2,
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(
                        DrawerIcons.privacy,
                        color: Colors.black,
                        size: 18.0,
                      )),
                  Text(
                    'Privacy',
                    style: Theme.of(context).textTheme.headline2,
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(
                        DrawerIcons.blacklist,
                        color: Colors.black,
                        size: 18.0,
                      )),
                  Text(
                    'Block',
                    style: Theme.of(context).textTheme.headline2,
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(
                        DrawerIcons.help,
                        color: Colors.black,
                        size: 18.0,
                      )),
                  Text(
                    'Help',
                    style: Theme.of(context).textTheme.headline2,
                  )
                ],
              ),
            )
          ],
        ),
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
                BottomBarIcons.feed,
                color: Color(0xff02CCFF),
                size: 20.0,
              ),
              icon: Icon(
                BottomBarIcons.feed,
                color: Color(0xffD9D9D9),
                size: 21.0,
              ),
              title: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  'News Feed',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Color(0xff514A4A)),
                ),
              )),
          BottomNavigationBarItem(
            activeIcon: Icon(
              BottomBarIcons.department,
              color: Color(0xffEAAC00),
              size: 23.0,
            ),
            icon: Icon(
              BottomBarIcons.department,
              color: Color(0xffD9D9D9),
              size: 22.0,
            ),
            title: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                'Departments',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Color(0xff514A4A)),
              ),
            ),
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(
              BottomBarIcons.bookmark,
              color: Color(0xff01E14C),
              size: 22.0,
            ),
            icon: Icon(
              BottomBarIcons.bookmark,
              color: Color(0xffD9D9D9),
              size: 21.0,
            ),
            title: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                'Bookmarks',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Color(0xff514A4A)),
              ),
            ),
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(
              BottomBarIcons.chat_bubble,
              color: Color(0xffF3E47A),
              size: 21.0,
            ),
            icon: Icon(
              BottomBarIcons.chat_bubble,
              color: Color(0xffD9D9D9),
              size: 19.0,
            ),
            title: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                'Chat Page',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Color(0xff514A4A)),
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
