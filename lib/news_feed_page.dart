import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hamaraprashasan/bottomSheets.dart';
import 'package:hamaraprashasan/classes.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';

class NewsFeedPage extends StatefulWidget {
  final Function(Widget Function(BuildContext) builder,
      {double elevation,
      ShapeBorder shape,
      Color backgroundColor}) showBottomSheet;
  NewsFeedPage({this.showBottomSheet});
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  bool feedSelected = false;
  List<Feed> feeds = [];
  Set<String> selectedFeed = new Set<String>();

  BehaviorSubject<Feeds> resultStream = BehaviorSubject<Feeds>();

  Feeds newFeeds = new Feeds();

  Map<String, dynamic> departmentDetails = Map();
  SortingType sortingType = SortingType.none;
  List<Department> departments = [], selectedDepartments = [];
  List<String> categories = [], selectedCategories = [];

  DocumentSnapshot lastFeedDetails;

  String errorMessage =
      'Some Error Occurred, Make sure you are connected to the internet.';
  String loadingMessage = 'Loading ...';
  String noSubscriptionMessage = "No subscribed departments";

  bool isRunning = false;

  DateTime startDateTimeAfter, endDateTimeBefore;

  bool noMoreFeeds = false;

  String userLocation;

  Future<bool> getDepartmentInfo() async {
    print('fetching departments');
    Firestore db = Firestore.instance;

    if(User.userData.subscribedDepartmentIDs.isEmpty){
      print('No subscribed departments');
      resultStream.sink.addError(noSubscriptionMessage);
      return false;
    } else {
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
        selectedDepartments = List.from(departments);
        Set<String> cat = new Set<String>();
        departments.forEach((d) {
          cat.add(d.category);
        });
        categories = cat.toList();
        selectedCategories = new List.from(categories);
        if (this.mounted) setState(() {});
        return true;
      }).catchError((e) {
        resultStream.sink.addError(errorMessage);
        print('Error in query getDepartmentInfo $e');
        return false;
      }).whenComplete(() {
        print('Completed query getDepartmentInfo');
        return true;
      }).timeout(Duration(seconds: 5), onTimeout: () {
        resultStream.sink.addError(errorMessage);
        print('Timeout in query getDepartmentInfo');
        return false;
      });
      return success;
    }
  }

  Future<bool> getMoreFeeds() async {
    Firestore db = Firestore.instance;
    print('fetching more feeds');

    if (User.lastUserState == UserState.feedUpdate) {
      startDateTimeAfter = endDateTimeBefore ?? DateTime.now();

      await db
          .collection('feeds')
          .where('creationDateTimeStamp',
              isLessThanOrEqualTo: User.userData.lastUpdateTime)
          .where('departmentUid',
              whereIn: User.userData.subscribedDepartmentIDs)
          .orderBy('creationDateTimeStamp', descending: true)
          .startAfter([startDateTimeAfter])
          .limit(2)
          .getDocuments()
          .then((value) {
            value.documents.forEach((element) {
              newFeeds.feeds.add(Feed(
                feedId: element.data['feedId'],
                feedInfo: FeedInfo.fromFirestoreJson(element.data),
                department: Department.fromJson(
                    departmentDetails[element.data['departmentUid']]),
              ));
            });
            if(value.documents.isEmpty){
              print('No new feeds');
              noMoreFeeds = true;
            }
          })
          .timeout(Duration(seconds: 3), onTimeout: () {
            resultStream.sink.addError(errorMessage);
            return null;
          })
          .catchError((e) {
            resultStream.sink.addError(errorMessage);
            print('onError in query for getLatestFeeds');
          })
          .whenComplete(() {
            print('OnDone in query for getLatestFeeds');
            User.lastUserState = UserState.feedUpdate;
            // update firestore user feed update time
          });

      endDateTimeBefore = newFeeds.feeds.last.feedInfo.creationDateTimeStamp;
      print(endDateTimeBefore);
      resultStream.sink.add(newFeeds);
    } else {
      print('last user state is not feedUpdate');
      if (await getDepartmentInfo()) {
        print('Fetched departments info');
        User.lastUserState = UserState.feedUpdate;
        getLatestFeeds();
        print('Gonna fetch getLatestFeeds');
      }
    }
    return true;
  }

  Future<bool> getLatestFeeds() async {
    Firestore db = Firestore.instance;
    print('fetching feeds');

    if (User.lastUserState == UserState.feedUpdate) {
      newFeeds.feeds.clear();

      await db
          .collection('feeds')
          .where('creationDateTimeStamp', isLessThanOrEqualTo: Timestamp.now())
          .where('departmentUid',
              whereIn: User.userData.subscribedDepartmentIDs)
          .orderBy('creationDateTimeStamp', descending: true)
          .limit(2)
          .getDocuments()
          .then((value) {
        value.documents.forEach((element) {
          newFeeds.feeds.add(Feed(
            feedId: element.data['feedId'],
            feedInfo: FeedInfo.fromFirestoreJson(element.data),
            department: Department.fromJson(
                departmentDetails[element.data['departmentUid']]),
          ));
        });
      }).whenComplete(() {
        User.lastUserState = UserState.feedUpdate;
      });

      endDateTimeBefore = newFeeds.feeds.last.feedInfo.creationDateTimeStamp;
      resultStream.sink.add(newFeeds);
    } else {
      print('last user state is not feedUpdate');
      if (await getDepartmentInfo()) {
        print('Fetched departments info');
        User.lastUserState = UserState.feedUpdate;
        getLatestFeeds();
        print('Gonna fetch getLatestFeeds');
      } else {
//        resultStream.sink.addError(errorMessage);
      }
    }
    return true;
  }

  void clearSelectedFeed() {
    setState(() {
      selectedFeed.clear();
    });
  }

  Future<void> feedHandler(
      {bool moreFeeds = false, bool latestFeeds = false}) async {
//    assert(moreFeeds != latestFeeds);
//    assert(isRunning == false);
    if (moreFeeds == latestFeeds || isRunning == true) {
      return;
    } else if (moreFeeds != latestFeeds && isRunning == false) {
      isRunning = true;
      print(
          'isRunning ${latestFeeds ? 'latestFeeds' : 'moreFeeds'} $isRunning');
      if (moreFeeds){
        if(noMoreFeeds == false){
          await getMoreFeeds();
        }
      } else {
        noMoreFeeds = false;
        await getLatestFeeds();
      }
      isRunning = false;
      print(
          'isRunning ${latestFeeds ? 'latestFeeds' : 'moreFeeds'} $isRunning');
    }
  }

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

  void _onLongPress(String feedId) {
    bool anySelected = selectedFeed.isNotEmpty;
    if (!anySelected) {
      setState(() {
        selectedFeed.add(feedId);
        anyFeedSelected();
      });
    }
  }

  void _onTap(int i, Feed f) {
    bool anySelected = selectedFeed.isNotEmpty;
    if (anySelected) {
      setState(() {
        if (selectedFeed.contains(f.feedId)) {
          selectedFeed.remove(f.feedId);
        } else {
          selectedFeed.add(f.feedId);
        }
        if (selectedFeed.isEmpty) allSelectedFeedCleared();
      });
    } else {
      Navigator.of(context).pushNamed("/feedInfo", arguments: {
        "feed": f,
      });
    }
  }

  void saveBookmarkedFeeds() async {
    selectedFeed.forEach((e1) {
      User.userData.bookmarkedFeeds.removeWhere((e2) => e1 == e2);
    });
    var selIds = User.userData.bookmarkedFeeds + selectedFeed.toList();
    selectedFeed.clear();
    allSelectedFeedCleared();
    bool saved = await FirebaseMethods.saveBookmarks(selIds);
    if (saved)
      print("Bookmarks Saved");
    else
      print("Some Error in saving bookmarks");
  }

  void applyFilters(SortingType sortingType, List<Department> departments,
      List<String> categories) {
    print("filtering");
    if (this.sortingType != sortingType) {
      this.sortingType = sortingType;
      feedHandler(latestFeeds: true, moreFeeds: false);
    } else {
      this.selectedDepartments = departments;
      this.selectedCategories = categories;
      setState(() {});
    }
  }

  void getRecentLocation() async {
    print('fetching last location');
    Geolocator geoLocator = Geolocator();
    GeolocationStatus geolocationStatus  = await geoLocator.checkGeolocationPermissionStatus();
    if(geolocationStatus == GeolocationStatus.granted){
      Position position = (await geoLocator.getLastKnownPosition(desiredAccuracy: LocationAccuracy.lowest,)) ?? (await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest));
      List<Placemark> placemark = await geoLocator.placemarkFromPosition(position);
      print(placemark);
      setState(() {
        userLocation = '${placemark[0].subLocality}, ${placemark[0].locality}';
      });
    } else {
      print('Permission not granted');
    }
  }

  void getNewLocation() async{
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
      setState(() {
        userLocation = '${placemark[0].subLocality}, ${placemark[0].locality}';
      });
    } else {
      print('permission not granted');
    }
  }

  @override
  void initState() {
    super.initState();
    feedHandler(latestFeeds: true, moreFeeds: false);
    getRecentLocation();
  }

  @override
  void dispose() {
    resultStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool filtered = this.sortingType != SortingType.none ||
        !listEquals(this.selectedDepartments, this.departments) ||
        !listEquals(this.selectedCategories, this.categories);
    List<String> selDepIds = selectedDepartments.map((e) => e.email).toList();
    return Scaffold(
      appBar: feedSelected
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
                    onPressed: saveBookmarkedFeeds,
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
                    child: User.authUser.photoString != null
                        ? Image.memory(
                            base64.decode(User.authUser.photoString),
                            fit: BoxFit.contain,
                          )
                        : CachedNetworkImage(
                            imageUrl: User.authUser.photoUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, s) {
                              return Container();
                            },
                          ),
                  ),
                ),
              ),
              automaticallyImplyLeading: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
              titleSpacing: 5.0,
              actions: [
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
              ],
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
                                onTap: (){
                                  getNewLocation();
                                },
                                child: Text(userLocation ?? 'Your Location',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(color: Color(0xff6D6D6D))),
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
            print('Reached Edge, getting more feeds');
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
              /* print(
                  'Snapshot details, connection : ${snapshot.connectionState.toString()}, hasData : ${snapshot.hasData}, hasError : ${snapshot.hasError}, hasCode : ${snapshot.hashCode}');
               */
              if (snapshot.connectionState == ConnectionState.waiting) {
                return FeedLoadStatus(
                  displayMessage: loadingMessage,
                );
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData && snapshot.data.feeds.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data.feeds?.length,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onLongPress: () =>
                            _onLongPress(snapshot.data.feeds[i].feedId),
                        onTap: () => _onTap(i, snapshot.data.feeds[i]),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: FeedBox(
                            feed: snapshot.data.feeds[i],
                            selected: selectedFeed
                                .contains(snapshot.data.feeds[i].feedId),
                            canBeSelected: feedSelected,
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return FeedLoadStatus(
                    displayMessage: snapshot.error.toString(),
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

class FeedBox extends StatelessWidget {
  final Feed feed;
  final bool selected, canBeSelected;
  FeedBox(
      {@required this.feed,
      @required this.selected,
      @required this.canBeSelected});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Text(
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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
                              text: DateFormat('MMM d, HH:m')
                                  .format(feed.feedInfo.creationDateTimeStamp),
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

class FeedLoadStatus extends StatelessWidget {
  final String displayMessage;

  FeedLoadStatus({@required this.displayMessage});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline2,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
