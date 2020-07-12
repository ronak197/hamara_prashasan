import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:hamaraprashasan/classes.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hamaraprashasan/location_bloc.dart';
import 'package:hamaraprashasan/news_feed_page.dart';
import 'package:rxdart/subjects.dart';

class BookmarkPage extends StatefulWidget {
  final Function(Widget Function(BuildContext) builder,
      {double elevation,
      ShapeBorder shape,
      Color backgroundColor}) showBottomSheet;
  BookmarkPage({this.showBottomSheet});
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<Feed> bookmarks = [];
  Set<String> selectedBookmarks = new Set<String>();

  bool bookmarkSelected = false;
  bool isRunning = false;
  BehaviorSubject<Feeds> resultStream = BehaviorSubject<Feeds>();
  List<Map<String, dynamic>> feedData = List<Map<String, dynamic>>();
  DocumentSnapshot lastFeedDetails;
  Map<String, dynamic> departmentDetails = Map();
  List<Department> departments = [];
  int feedLimit = 2;
  Feeds newFeeds = new Feeds();
  List<String> currentBookmarks = [];
  ScrollController _scrollController = new ScrollController();

  String errorMessage =
          'Some Error Occurred, Make sure you are connected to the internet.',
      loadingMessage = 'Loading ...',
      noBookmarkMessage = "No Bookmarked Feeds.";

  void getCurrentBookmarks() {
    currentBookmarks =
        new List<String>.from(User.userData.bookmarkedFeeds).reversed.toList();
  }

  List<String> getToBeFetchedList() {
    print(currentBookmarks);
    if (currentBookmarks.length < feedLimit) {
      var list = List<String>.from(currentBookmarks);
      currentBookmarks = [];
      return list;
    }
    var list = currentBookmarks.sublist(0, feedLimit);
    currentBookmarks.removeRange(0, feedLimit);
    return list;
  }

  Future<bool> getDepartmentInfo() async {
    print('fetching departments');
    Firestore db = Firestore.instance;

    bool success = await db
        .collection('departments')
        .where('email', whereIn: User.userData.subscribedDepartmentIDs)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        if (!departmentDetails.containsKey(element.data['email'])) {
          departmentDetails[element.data['email']] = element.data;
        }
      });
      departmentDetails.forEach((key, value) {
        departments.add(new Department.fromJson(value));
      });

      if (this.mounted) setState(() {});
      return true;
    }).catchError((e) {
      resultStream.sink.addError(errorMessage);
      print('Error in query getDepartmentInfo in bookmarks $e');
      return false;
    }).whenComplete(() {
      print('Completed query getDepartmentInfo in bookmarks');
      return true;
    }).timeout(Duration(seconds: 5), onTimeout: () {
      resultStream.sink.addError(errorMessage);
      print('Timeout in query getDepartmentInfo in bookmarks');
      return false;
    });

    return success;
  }

  Future<bool> getMoreBookmarks() async {
    Firestore db = Firestore.instance;
    print('fetching more feeds');

    Query resQuery;
    resQuery =
        db.collection('feeds').where('feedId', whereIn: getToBeFetchedList());

    await resQuery.limit(feedLimit).getDocuments().then((value) {
      List<Feed> fetchedFeeds = [];
      value.documents.forEach((element) {
        fetchedFeeds.add(Feed(
          feedId: element.data['feedId'],
          feedInfo: FeedInfo.fromFirestoreJson(element.data),
          department: Department.fromJson(
              departmentDetails[element.data['departmentUid']]),
        ));
      });
      fetchedFeeds.sort((f1, f2) {
        int i = User.userData.bookmarkedFeeds.indexOf(f1.feedId),
            j = User.userData.bookmarkedFeeds.indexOf(f2.feedId);
        if (i < j)
          return -1;
        else if (i > j)
          return 1;
        else
          return 0;
      });

      newFeeds.feeds += fetchedFeeds.reversed.toList();
    }).timeout(Duration(seconds: 3), onTimeout: () {
      resultStream.sink.addError(errorMessage);
      isRunning = false;
      return null;
    }).catchError((e) {
      resultStream.sink.addError(errorMessage);
      isRunning = false;
      print('onError in query for getMoreBookmarks');
    }).whenComplete(() {
      print('OnDone in query for getMoreBookmarks');
    });

    resultStream.sink.add(newFeeds);

    return true;
  }

  Future<bool> getLatestBookmarks() async {
    Firestore db = Firestore.instance;
    print('fetching bookmarks');
    newFeeds = new Feeds();
    getCurrentBookmarks();

    Query resQuery;
    resQuery =
        db.collection('feeds').where('feedId', whereIn: getToBeFetchedList());

    await resQuery.limit(feedLimit).getDocuments().then((value) {
      List<Feed> fetchedFeeds = [];
      value.documents.forEach((element) {
        fetchedFeeds.add(Feed(
          feedId: element.data['feedId'],
          feedInfo: FeedInfo.fromFirestoreJson(element.data),
          department: Department.fromJson(
              departmentDetails[element.data['departmentUid']]),
        ));
      });
      fetchedFeeds.sort((f1, f2) {
        int i = User.userData.bookmarkedFeeds.indexOf(f1.feedId),
            j = User.userData.bookmarkedFeeds.indexOf(f2.feedId);
        if (i < j)
          return -1;
        else if (i > j)
          return 1;
        else
          return 0;
      });
      newFeeds.feeds += fetchedFeeds.reversed.toList();
    }).timeout(Duration(seconds: 3), onTimeout: () {
      resultStream.sink.addError(errorMessage);
      isRunning = false;
      return null;
    }).catchError((e) {
      resultStream.sink.addError(errorMessage);
      isRunning = false;
      print('onError in query for getLatestBookmarks');
    }).whenComplete(() {
      print('OnDone in query for getLatestBookmarks');
    });

    resultStream.sink.add(newFeeds);

    return true;
  }

  Future<void> feedHandler(
      {bool moreFeeds = false, bool latestFeeds = false}) async {
//    assert(moreFeeds != latestFeeds);
//    assert(isRunning == false);
    if (moreFeeds == latestFeeds || isRunning == true) {
      return;
    } else if (moreFeeds != latestFeeds && isRunning == false) {
      if (moreFeeds && currentBookmarks.isEmpty)
        return;
      else if (latestFeeds && User.userData.bookmarkedFeeds.isEmpty) return;
      isRunning = true;
      print(
          'isRunning ${latestFeeds ? 'latestBookmarks' : 'moreBookmarks'} $isRunning');
      if (moreFeeds) {
        await getMoreBookmarks();
      } else {
        await getLatestBookmarks();
      }
      isRunning = false;
      print(
          'isRunning ${latestFeeds ? 'latestBookmarks' : 'moreBookmarks'} $isRunning');
    }
  }

  void clearSelectedBookmark() {
    setState(() {
      selectedBookmarks.clear();
    });
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

  void _onLongPress(String feedId) {
    bool anySelected = selectedBookmarks.isNotEmpty;
    if (!anySelected) {
      setState(() {
        selectedBookmarks.add(feedId);
        anyBookmarkSelected();
      });
    }
  }

  void _onTap(int i, Feed f) {
    bool anySelected = selectedBookmarks.isNotEmpty;
    if (anySelected) {
      setState(() {
        if (selectedBookmarks.contains(f.feedId)) {
          selectedBookmarks.remove(f.feedId);
        } else {
          selectedBookmarks.add(f.feedId);
        }
        if (selectedBookmarks.isEmpty) allSelectedBookmarkCleared();
      });
    } else {
      Navigator.of(context).pushNamed("/feedInfo", arguments: {
        "feed": f,
      });
    }
  }

  void deleteBookmarks() async {
    var finalList = User.userData.bookmarkedFeeds;
    selectedBookmarks.forEach((element) {
      finalList.remove(element);
      newFeeds.feeds.removeWhere((f) => f.feedId == element);
    });
    selectedBookmarks.clear();
    allSelectedBookmarkCleared();
    setState(() {});
    bool deleted = await FirebaseMethods.saveBookmarks(finalList);
    if (deleted) {
      print("Bookmarks deleted");
    } else {
      print("Error while deleting the bookmarks");
    }
  }

  DefaultCacheManager cacheManager = new DefaultCacheManager();

  @override
  void initState() {
    super.initState();
    getDepartmentInfo();
    feedHandler(latestFeeds: true, moreFeeds: false);
  }

  @override
  void dispose() {
    resultStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bookmarkSelected
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
                    onPressed: deleteBookmarks,
                  ),
                )
              ],
            )
          : AppBar(
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              leading: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Container(
                  margin: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: ClipOval(
                    child: User.authUser.localPhotoLoc != null
                        ? Image.file(
                            File(User.authUser.localPhotoLoc),
                            fit: BoxFit.contain,
                          )
                        : CachedNetworkImage(
                            imageUrl: User.authUser.photoUrl,
                            cacheManager: cacheManager,
                            fit: BoxFit.contain,
                            placeholder: (context, s) {
                              print("Profile Url" + s);
                              return Container();
                            },
                          ),
                  ),
                ),
              ),
              automaticallyImplyLeading: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
              titleSpacing: 0.0,
              /* actions: [
                GestureDetector(
                  onTap: () async {
                    widget.showBottomSheet(
                      (context) {
                        return FilterBottomSheet(
                          departments: departmentDetails,
                          applyFilters: applyFilters,
                        );
                      },
                      elevation: 40,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.filter_list,
                      size: 20.0,
                    ),
                  ),
                ),
              ], */
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Welcome ${User.authUser.displayName.split(" ")[0]}',
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(fontWeight: FontWeight.w600)),
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
                              child: InkWell(
                                onTap: () => LocationBloc.getNewLocation(),
                                child: StreamBuilder(
                                  stream: LocationBloc.locationStream,
                                  builder: (context, AsyncSnapshot<String> snapshot){
                                    return Text(snapshot.hasData ? snapshot.data : 'Your Location',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(color: Color(0xff6D6D6D)));
                                  },
                                ),
                              )))
                    ],
                  )
                ],
              ),
            ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels >=
                  (scrollInfo.metrics.maxScrollExtent - 60.0)) {
            print('Reached Edge, getting more bookmarks');
            feedHandler(moreFeeds: true, latestFeeds: false);
            return true;
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () => feedHandler(latestFeeds: true, moreFeeds: false),
          strokeWidth: 2.5,
          child: StreamBuilder(
            stream: resultStream.stream,
            builder: (context, AsyncSnapshot<Feeds> snapshot) {
              print(
                  'Snapshot details, connection : ${snapshot.connectionState.toString()}, hasData : ${snapshot.hasData}, hasError : ${snapshot.hasError}, hasCode : ${snapshot.hashCode}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return FeedLoadStatus(
                  displayMessage: loadingMessage,
                );
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData && snapshot.data.feeds.isNotEmpty) {
                  return Scrollbar(
                    //isAlwaysShown: true,
                    controller: _scrollController,
                    child: ListView.builder(
                      itemCount: snapshot.data.feeds.length,
                      itemBuilder: (context, i) {
                        Feed f = snapshot.data.feeds[i];
                        return GestureDetector(
                          onLongPress: () => _onLongPress(f.feedId),
                          onTap: () => _onTap(i, f),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: MessageBox(
                              feed: f,
                              selected: selectedBookmarks.contains(f.feedId),
                              canBeSelected: bookmarkSelected,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.data.feeds.isEmpty) {
                  return FeedLoadStatus(
                    displayMessage: noBookmarkMessage,
                  );
                } else if (snapshot.hasError) {
                  return FeedLoadStatus(
                    displayMessage: snapshot.error,
                  );
                }
              }
              return SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  final Feed feed;
  final bool selected, canBeSelected;
  MessageBox(
      {@required this.feed,
      @required this.selected,
      @required this.canBeSelected});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                color: Color(feed.bgColor),
              ),
              foregroundDecoration: selected || canBeSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      color: Colors.grey.withOpacity(selected ? 0.4 : 0.1),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        child: SvgPicture.asset(
                          feed.profileAvatar,
                          width: 64.0,
                          height: 64.0,
                          fit: BoxFit.contain,
                          placeholderBuilder: (context) {
                            return Container(
                              width: 64.0,
                              height: 64.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.white, Color(0xfff7f7f7)]),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: Color(categoryTagColorMap[
                                      feed.department.category]),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  feed.department.category,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                child: Text(
                                  feed.feedInfo.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      .copyWith(
                                          color: Color(0xff303046),
                                          fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(top: 10.0),
                    child: Text(
                      feed.feedInfo.description,
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          .copyWith(fontWeight: FontWeight.normal),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(top: 10.0),
                        child: Text(
                          feed.department.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Color(0xff8C8C8C)),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(top: 10.0),
                        child: RichText(
                          text: TextSpan(children: [
                            WidgetSpan(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: Icon(
                                  Icons.access_time,
                                  size: 13.0,
                                  color: Color(0xff8C8C8C),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: 'July' +
                                  ', ' +
                                  feed.feedInfo.creationDateTimeStamp.hour
                                      .toString() +
                                  ":" +
                                  feed.feedInfo.creationDateTimeStamp.minute
                                      .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(color: Color(0xff8C8C8C)),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] +
          (canBeSelected
              ? <Widget>[
                  Positioned(
                    top: 15,
                    right: 30,
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? Colors.blue : Color(0xffe3e5e9),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ),
                  )
                ]
              : <Widget>[]),
    );
  }
}
