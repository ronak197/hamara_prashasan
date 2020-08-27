import 'dart:io';

import 'package:flutter/material.dart';

import 'package:rxdart/subjects.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hamaraprashasan/app_configurations/app_configurations.dart';
import 'package:hamaraprashasan/home_page/bookmarks_tab/bookmarks_page.dart';
import 'package:hamaraprashasan/home_page/departments_tab/departments_page.dart';
import 'package:hamaraprashasan/helper_classes/user_classes/department_user_class.dart';
import 'package:hamaraprashasan/helper_classes/feed_classes/feed_class.dart';
import 'package:hamaraprashasan/helper_classes/feed_classes/feed_info_class.dart';

class EditAccountPage extends StatefulWidget {
  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  List<Department> departments = [];
  List<Department> subscribedDepartments = List<Department>();
  BehaviorSubject<Feeds> resultStream = BehaviorSubject<Feeds>();
  DocumentSnapshot lastFeedSp;
  int feedLimit = 2;
  bool isRunning = false;
  String errorMessage =
          'Some Error Occurred, Make sure you are connected to the internet.',
      loadingMessage = 'Loading ...',
      noFeedMessage = "No Feeds Found.";
  ScrollController _scrollController = new ScrollController();
  Feeds myFeeds = new Feeds();
  int numberOfSubscribers = 0;

  Future<bool> getDepartmentInfo() async {
    print('fetching departments  in editProfile');
    Firestore db = Firestore.instance;

    bool success = await db
        .collection('departments')
        .where('email', whereIn: User.userData.subscribedDepartmentIDs)
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
      print('Completed query getDepartmentInfo in editProfile');
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
    await db
        .collection('feeds')
        .where('creationDateTimeStamp', isLessThanOrEqualTo: Timestamp.now())
        .where('departmentUid', isEqualTo: User.authUser.email)
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
        .where('departmentUid', isEqualTo: User.authUser.email)
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
          await getMoreFeeds();
        } else {
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

  void getNumberOfSubscribers() async {
    Firestore db = Firestore.instance;
    var doc = await db
        .collection("users")
        .where("subscribedDepartmentIDs", arrayContains: User.userData.email)
        .getDocuments();
    setState(() {
      numberOfSubscribers = doc.documents.length;
    });
  }

  void getSubscribedDepartments() async {
    Firestore db = Firestore.instance;

    setState(() {
      subscribedDepartments?.clear();
      errorMessage = "Getting subscribers";
      print(errorMessage);
    });

    db
        .collection('departments')
        .where('email', whereIn: User.userData.subscribedDepartmentIDs)
        .getDocuments()
        .asStream()
        .listen((event) {
      setState(() {
        event.documents.forEach((snapshot) {
          subscribedDepartments.add(Department.fromJson(snapshot.data));
        });
      });
    })
          ..onDone(() {
            if (subscribedDepartments.isEmpty) {
              setState(() {
                errorMessage = 'No Subscribed Departments';
                print(errorMessage);
              });
            }
          })
          ..onError((e) {
            setState(() {
              errorMessage = "Error Occurred";
              print(errorMessage);
            });
          });
  }

  void onSubscribePressed(String toSubscribe, bool hasSubscribed) async {
    Firestore db = Firestore.instance;

    if (User.lastUserState != UserState.initial) {
      await FirebaseMethods.getFirestoreUserDataInfo();
    }
    if (!User.userData.subscribedDepartmentIDs.contains(toSubscribe)) {
      setState(() {
        User.userData.subscribedDepartmentIDs.add(toSubscribe);
        User.saveUserData(User.userData, UserState.subscription);
      });
      await db
          .collection('users')
          .document(User.authUser.uid)
          .updateData(User.userData.toFirestoreJson())
          .catchError((e) {
        setState(() {
          errorMessage = 'Error Occurred';
        });
        return null;
      });
    } else {
      setState(() {
        User.userData.subscribedDepartmentIDs.remove(toSubscribe);
        User.saveUserData(User.userData, UserState.subscription);
      });
      await db
          .collection('users')
          .document(User.authUser.uid)
          .updateData(User.userData.toFirestoreJson())
          .catchError((e) {
        setState(() {
          errorMessage = 'Error Occurred';
        });
        return null;
      });
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (User.userData.isDepartment) {
      feedHandler(latestFeeds: true, moreFeeds: false);
      getNumberOfSubscribers();
    } else {
      getSubscribedDepartments();
    }
  }

  @override
  void dispose() {
    resultStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (User.userData.isDepartment)
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 15,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(5),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is ScrollEndNotification &&
                  scrollInfo.metrics.pixels >=
                      (scrollInfo.metrics.maxScrollExtent - 60.0)) {
                print('Reached Edge, getting more Feeds');
                feedHandler(moreFeeds: true, latestFeeds: false);
                return true;
              }
              return false;
            },
            child: Scrollbar(
              //isAlwaysShown: true,
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.all(12.0),
                        padding: EdgeInsets.all(2),
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: User.authUser.localPhotoLoc != null
                              ? Image.file(
                                  File(User.authUser.localPhotoLoc),
                                  fit: BoxFit.contain,
                                )
                              : CachedNetworkImage(
                                  imageUrl: User.authUser.photoUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, s) {
                                    return Container(color: Colors.white);
                                  },
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        User.authUser.displayName,
                        style: Theme.of(context).textTheme.headline2.copyWith(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        User.authUser.email,
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(color: Colors.grey),
                      ),
                    ),
                    User.authUser.phoneNumber != null
                        ? Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              User.authUser.phoneNumber,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(color: Colors.grey),
                            ),
                          )
                        : SizedBox(),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Number of subscribers: $numberOfSubscribers",
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "My Feeds :",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: resultStream.stream,
                      builder: (context, AsyncSnapshot<Feeds> snapshot) {
                        print(
                            'Snapshot details, connection : ${snapshot.connectionState.toString()}, hasData : ${snapshot.hasData}, hasError : ${snapshot.hasError}, hasCode : ${snapshot.hashCode}');

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return FeedLoadStatus(
                            displayMessage: loadingMessage,
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData &&
                              snapshot.data.feeds.isNotEmpty) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data.feeds.length,
                              itemBuilder: (context, i) {
                                Feed f = snapshot.data.feeds[i];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed("/feedInfo", arguments: {
                                      "feed": f,
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    child: MessageBox(
                                      feed: f,
                                      selected: false,
                                      canBeSelected: false,
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.data.feeds.isEmpty) {
                            print(noFeedMessage);
                            return FeedLoadStatus(
                              displayMessage: noFeedMessage,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    else
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 15,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(5),
          child: Scrollbar(
            //isAlwaysShown: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: EdgeInsets.all(12.0),
                          padding: EdgeInsets.all(2),
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: User.authUser.localPhotoLoc != null
                                ? Image.file(
                                    File(User.authUser.localPhotoLoc),
                                    fit: BoxFit.contain,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: User.authUser.photoUrl,
                                    fit: BoxFit.contain,
                                    placeholder: (context, s) {
                                      return Container(color: Colors.white);
                                    },
                                  ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          User.authUser.displayName,
                          style:
                              Theme.of(context).textTheme.headline2.copyWith(),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          User.authUser.email,
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              .copyWith(color: Colors.grey),
                        ),
                      ),
                      User.authUser.phoneNumber != null
                          ? Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                User.authUser.phoneNumber,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(color: Colors.grey),
                              ),
                            )
                          : SizedBox(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Departments subscribed :",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ),
                      ),
                    ] +
                    List<Widget>.generate(subscribedDepartments?.length,
                        (index) {
                      Department department = subscribedDepartments[index];
                      bool hasSubscribed =
                          (User.userData.subscribedDepartmentIDs ?? [])
                                  .contains(department.email) ??
                              false;
                      return DepartmentsMessageBox(
                        subscribed: hasSubscribed,
                        department: department,
                        onSubscribePressed: () => onSubscribePressed(
                            subscribedDepartments[index].email, hasSubscribed),
                      );
                    }),
              ),
            ),
          ),
        ),
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
