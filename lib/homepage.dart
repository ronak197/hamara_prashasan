import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamaraprashasan/app_drawer.dart';
import 'package:hamaraprashasan/bookmarks.dart';
import 'package:hamaraprashasan/bottom_bar_icons_icons.dart';
import 'package:hamaraprashasan/departments_page.dart';
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
                  size: 25.0,
                ),
                onPressed: clearSelectedFeed,
              ),
              actions: [
                Container(
                  padding: EdgeInsets.only(right: 5.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark,
                      size: 25.0,
                      color: Color(0xff393A4E),
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
                      size: 25.0,
                    ),
                    onPressed: clearSelectedBookmark,
                  ),
                  actions: [
                    Container(
                      padding: EdgeInsets.only(right: 5.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_forever,
                          size: 25.0,
                          color: Color(0xffea3953),
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
                        Icons.filter_list,
                        size: 20.0,
                      ),
                    )
                  ],
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Welcome Ronak',
                          style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w600)),
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
                                Icons.location_on,
                                size: 12.0,
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
      drawer: MyAppDrawer(),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Color(0xff514A4A), fontWeight: FontWeight.normal),
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
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Color(0xff514A4A), fontWeight: FontWeight.normal),
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
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Color(0xff514A4A), fontWeight: FontWeight.normal),
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
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Color(0xff514A4A), fontWeight: FontWeight.normal),
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
