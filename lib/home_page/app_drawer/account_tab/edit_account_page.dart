import 'dart:io';
import 'dart:math';

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

  //variables for Beta version only
  List<String> allDepartmentList = ["temporary_department@gmail.com"];
  String _selectedDepartmentId = "temporary_department@gmail.com";

  //Function for Beta version only
  void fetchAllDeparmentIds() async {
    QuerySnapshot qs =
        await Firestore.instance.collection("departments").getDocuments();
    setState(() {
      qs.documents.forEach((doc) {
        allDepartmentList.add(doc.data["email"].toString());
      });
    });
  }

  Future<void> getLatestFeeds() async {
    Firestore db = Firestore.instance;
    print('fetching my feeds');
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
          department: subscribedDepartments
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
          department: subscribedDepartments
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
    if (subscribedDepartments.isEmpty) await getSubscribedDepartmentsHandler();
    if (subscribedDepartments.isNotEmpty) {
      if (moreFeeds == latestFeeds || isRunning == true) {
        return;
      } else if (moreFeeds != latestFeeds && isRunning == false) {
        isRunning = true;
        print(
            'isRunning ${latestFeeds ? 'latestFeeds' : 'moreFeeds'} $isRunning');
        if (moreFeeds) {
          await getMoreFeeds();
        } else {
          myFeeds.feeds.clear();
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

  Future<void> getSubscribedDepartmentsHandler() async {
    setState(() {
      subscribedDepartments?.clear();
      errorMessage = "Getting subscribers";
      print(errorMessage);
    });
    if (_selectedDepartmentId != null) {
      await getSubscribedDepartments([_selectedDepartmentId]);
    } else {
      int len = User.userData.subscribedDepartmentIDs.length;
      for (int i = 0; i < len; i += 10) {
        List<String> ids =
            User.userData.subscribedDepartmentIDs.sublist(i, min(i + 10, len));
        await getSubscribedDepartments(ids);
      }
      if (subscribedDepartments.isEmpty) {
        setState(() {
          errorMessage = 'No Subscribed Departments';
          print(errorMessage);
        });
      }
    }
  }

  Future<void> getSubscribedDepartments(List<String> ids) async {
    Firestore db = Firestore.instance;

    await db
        .collection('departments')
        .where('email', whereIn: ids)
        .getDocuments()
        .then((qs) {
      setState(() {
        qs.documents.forEach((snapshot) {
          subscribedDepartments.add(Department.fromJson(snapshot.data));
        });
      });
    }).catchError((e) {
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
      fetchAllDeparmentIds();
    } else {
      getSubscribedDepartmentsHandler();
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
      return SafeArea(
        child: Scaffold(
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
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
                                      subscribedDepartments.clear();
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
                                      margin:
                                          EdgeInsets.symmetric(vertical: 8.0),
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
                              if (isRunning)
                                return FeedLoadStatus(
                                  displayMessage: loadingMessage,
                                );
                              else
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
        ),
      );
    else
      return SafeArea(
        child: Scaffold(
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
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                .copyWith(),
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
                              subscribedDepartments[index].email,
                              hasSubscribed),
                        );
                      }),
                ),
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
