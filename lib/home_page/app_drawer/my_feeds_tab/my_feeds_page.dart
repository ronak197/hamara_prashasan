import 'dart:math';

import 'package:flutter/material.dart';

import 'package:rxdart/subjects.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hamaraprashasan/app_configurations/app_configurations.dart';
import 'package:hamaraprashasan/helper_classes/feed_classes/feed_info_class.dart';
import 'package:hamaraprashasan/home_page/bookmarks_tab/bookmarks_page.dart';
import 'package:hamaraprashasan/home_page/feed_tab/news_feed_page.dart';
import 'package:hamaraprashasan/helper_classes/feed_classes/feed_class.dart';
import 'package:hamaraprashasan/helper_classes/user_classes/department_user_class.dart';

class MyFeedsPage extends StatefulWidget {
  @override
  _MyFeedsPageState createState() => _MyFeedsPageState();
}

class _MyFeedsPageState extends State<MyFeedsPage> {
  List<Department> departments = [];
  BehaviorSubject<Feeds> resultStream = BehaviorSubject<Feeds>();
  BehaviorSubject<bool> loadingStream = BehaviorSubject<bool>();
  DocumentSnapshot lastFeedSp;
  int feedLimit = 2;
  bool isRunning = false;
  String errorMessage =
          'Some Error Occurred, Make sure you are connected to the internet.',
      loadingMessage = 'Loading ...',
      noBookmarkMessage = "No Feeds Found.";
  ScrollController _scrollController = new ScrollController();
  Feeds myFeeds = new Feeds();
  Set<String> selectedFeed = new Set<String>();
  bool feedSelected = false;

  //Variables for beta version
  List<String> allDepartmentList = ["temporary_department@gmail.com"];
  String _selectedDepartmentId = "temporary_department@gmail.com";

  //Function for beta version
  void fetchAllDeparmentIds() async {
    allDepartmentList.clear();
    QuerySnapshot qs =
        await Firestore.instance.collection("departments").getDocuments();
    setState(() {
      qs.documents.forEach((doc) {
        allDepartmentList.add(doc.data["email"].toString());
      });
    });
  }

  Future<bool> getDepartmentInfo() async {
    print('fetching departments  in editProfile');
    Firestore db = Firestore.instance;
    bool success = await db
        .collection('departments')
        .where('email', isEqualTo: _selectedDepartmentId ?? User.userData.email)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        if (!departments.any((d) => d.email == element.data['email'])) {
          departments.add(new Department.fromJson(element.data));
        }
      });
      return true;
    }).catchError((e) {
      print('Error in query getDepartmentInfo in editProfile $e');
      return false;
    }).whenComplete(() {
      return true;
    }).timeout(Duration(seconds: 5), onTimeout: () {
      print('Timeout in query getDepartmentInfo in editProfile');
      return false;
    });

    return success;
  }

  Future<void> getLatestFeeds() async {
    Firestore db = Firestore.instance;
    print('fetching my feeds');
    myFeeds = new Feeds();
    await db
        .collection('feeds')
        .where('creationDateTimeStamp', isLessThanOrEqualTo: Timestamp.now())
        .where('departmentUid',
            isEqualTo: _selectedDepartmentId ?? User.authUser.email)
        .orderBy('creationDateTimeStamp', descending: true)
        .limit(feedLimit)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        myFeeds.feeds.add(Feed(
          feedId: element.data['feedId'],
          feedInfo: FeedInfo.fromFirestoreJson(element.data),
          department: departments
              .firstWhere((d) => d.email == element.data['departmentUid']),
        ));
      });
      if (value.documents.isNotEmpty) lastFeedSp = value.documents.last;
      resultStream.sink.add(myFeeds);
    }).whenComplete(() {
      print("Fetched mine latest feeds");
    });
  }

  Future<void> getMoreFeeds() async {
    Firestore db = Firestore.instance;
    print('fetching my feeds');
    Query q = db
        .collection('feeds')
        .where('creationDateTimeStamp', isLessThanOrEqualTo: Timestamp.now())
        .where('departmentUid',
            isEqualTo: _selectedDepartmentId ?? User.authUser.email)
        .orderBy('creationDateTimeStamp', descending: true);
    if (lastFeedSp != null) {
      q = q.startAfterDocument(lastFeedSp);
    }
    await q.limit(feedLimit).getDocuments().then((value) {
      value.documents.forEach((element) {
        myFeeds.feeds.add(Feed(
          feedId: element.data['feedId'],
          feedInfo: FeedInfo.fromFirestoreJson(element.data),
          department: departments
              .firstWhere((d) => d.email == element.data['departmentUid']),
        ));
      });
      if (value.documents.isNotEmpty) lastFeedSp = value.documents.last;
      resultStream.sink.add(myFeeds);
    }).whenComplete(() {
      print("Fetched More of mine feeds");
    });
  }

  Future<void> feedHandler(
      {bool moreFeeds = false, bool latestFeeds = false}) async {
    if (departments.isNotEmpty ||
        (departments.isEmpty && (await getDepartmentInfo()))) {
      if (moreFeeds == latestFeeds || isRunning == true) {
        return;
      } else if (moreFeeds != latestFeeds && isRunning == false) {
        isRunning = true;
        print(
            'isRunning ${latestFeeds ? 'latestFeeds' : 'moreFeeds'} $isRunning');
        if (moreFeeds) {
          //loadingStream.add(true);
          await getMoreFeeds();
          //loadingStream.add(false);
        } else {
          myFeeds.feeds.clear();
          resultStream.add(myFeeds);
          await getLatestFeeds();
        }
        isRunning = false;
        print(
            'isRunning ${latestFeeds ? 'latestFeeds' : 'moreFeeds'} $isRunning');
      }
    } else {
      print("Error in getting departments information");
    }
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

  void deleteFeed() async {
    List<String> deletedFeedIds = selectedFeed.toList();
    bool deleteSuccess = await FirebaseMethods.deleteMyFeeds(deletedFeedIds);
    if (deleteSuccess) {
      setState(() {
        deletedFeedIds.forEach((id) {
          myFeeds.feeds.removeWhere((f) => f.feedId == id);
        });
      });
      print("deletion successful");
    } else {
      print("error in deleting the feeds");
    }
    selectedFeed.clear();
    allSelectedFeedCleared();
  }

  @override
  void initState() {
    super.initState();
    feedHandler(latestFeeds: true, moreFeeds: false);
    fetchAllDeparmentIds();
  }

  @override
  void dispose() {
    resultStream.close();
    loadingStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          titleSpacing: 5.0,
          title: Text(
            'My Feeds',
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(fontWeight: FontWeight.w600),
          ),
          actions: selectedFeed.isNotEmpty
              ? [
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: 25.0,
                        color: Colors.red,
                      ),
                      onPressed: deleteFeed,
                    ),
                  )
                ]
              : [],
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
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Select email:",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 0.5),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              onChanged: (String dep) {
                                setState(() {
                                  _selectedDepartmentId = dep;
                                });
                                lastFeedSp = null;
                                isRunning = false;
                                departments.clear();
                                feedHandler(
                                    latestFeeds: true, moreFeeds: false);
                              },
                              isExpanded: true,
                              hint: Text(
                                "Select",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              value: _selectedDepartmentId,
                              items: allDepartmentList
                                  .map<DropdownMenuItem<String>>(
                                    (dep) => DropdownMenuItem<String>(
                                      value: dep,
                                      child: Container(
                                        child: Text(
                                          dep,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: resultStream.stream,
                    builder: (context, AsyncSnapshot<Feeds> snapshot) {
                      print(
                          'Snapshot details, connection : ${snapshot.connectionState.toString()}, hasData : ${snapshot.hasData}, hasError : ${snapshot.hasError}, hasCode : ${snapshot.hashCode}');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return FeedLoadStatus(
                          displayMessage: loadingMessage,
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.active) {
                        if (snapshot.hasData &&
                            snapshot.data.feeds.isNotEmpty) {
                          return Scrollbar(
                            //isAlwaysShown: true,
                            controller: _scrollController,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: snapshot.data.feeds.length,
                              itemBuilder: (context, i) {
                                Feed f = snapshot.data.feeds[i];
                                return GestureDetector(
                                  onTap: () => _onTap(i, f),
                                  onLongPress: () => _onLongPress(f.feedId),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    child: MessageBox(
                                      feed: f,
                                      selected: selectedFeed.contains(
                                          snapshot.data.feeds[i].feedId),
                                      canBeSelected: feedSelected,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else if (snapshot.data.feeds.isEmpty) {
                          if (isRunning)
                            return FeedLoadStatus(
                              displayMessage: loadingMessage,
                            );
                          else
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
                StreamBuilder(
                  stream: loadingStream,
                  builder: (context, AsyncSnapshot<bool> sp) {
                    if (sp.connectionState == ConnectionState.active &&
                        sp.hasData &&
                        sp.data)
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: CircularProgressIndicator(strokeWidth: 1),
                        height: 25,
                        width: 25,
                      );
                    else
                      return SizedBox();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
