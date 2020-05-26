import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hamaraprashasan/classes.dart';
import 'package:intl/intl.dart';

class NewsFeedPage extends StatefulWidget {
  final Function anyFeedSelected, allSelectedFeedCleared;
  void clearSelectedFeed() {
    _newsFeedPageState.clearSelectedFeed();
  }

  _NewsFeedPageState _newsFeedPageState = new _NewsFeedPageState();
  NewsFeedPage(
      {@required this.anyFeedSelected, @required this.allSelectedFeedCleared});
  @override
  _NewsFeedPageState createState() => _newsFeedPageState;
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  List<Feed> feeds = [];
  List<bool> selected = [];

  StreamController<QuerySnapshot> resultStream = StreamController();
  Map<String, dynamic> departmentDetails = Map();

  String message;

  Future<dynamic> getDepartmentInfo() async {
    print('fetching departments');
    Firestore db = Firestore.instance;

    var val = db.runTransaction((transaction) {
      db
          .collection('departments')
          .where('email', whereIn: UserConfig.user.subscribedDepartmentIDs)
          .getDocuments(source: Source.server)
            ..then((value) {
              value.documents.forEach((element) {
                print(element.data);
                if (!departmentDetails.containsKey(element.data['email'])) {
                  departmentDetails[element.data['email']] = element.data;
                }
              });
            })
            ..catchError((e) {
              return false;
            })
            ..whenComplete(() {
              return true;
            });
      return null;
    })
      ..catchError((e) {
        print('this is $e');
        setState(() {
          resultStream.addError(message);
          message =
              "Some Error Occurred, Make sure you are connected to the internet.";
        });
      })
      ..timeout(Duration(seconds: 5), onTimeout: () {
        setState(() {
          resultStream.addError(message);
          message =
              "Some Error Occurred, Make sure you are connected to the internet.";
        });
        return null;
      });

    return val;
  }

  void getFeeds() async {
    Firestore db = Firestore.instance;

    /* db.collection('path').add({'temp': 'temp'}).then((value) {
      value.collection('collectionPath').add({'temp': 'temp'});
    }); */
    db.runTransaction((transaction) async {
      if (UserConfig.lastUserState == UserState.initial) {
        db
            .collection('feeds')
            .where('creationDateTimeStamp',
                isLessThanOrEqualTo: UserConfig.user.lastFeedUpdateTime)
            .where('departmentUid',
                whereIn: UserConfig.user.subscribedDepartmentIDs)
            .getDocuments(source: Source.server)
            .asStream()
            .listen((event) {
          resultStream.sink.add(event);
        });
      } else {
        if (await FirebaseMethods.getFirestoreUserDataInfo()) {
          print('fetching feeds again');
          getDepartmentInfo();
          getFeeds();
        }
      }
      return null;
    })
      ..catchError((e) {
        setState(() {
          message =
              "Some Error Occurred, Make sure you are connected to the internet.";
          resultStream.addError(message);
        });
      })
      ..timeout(Duration(seconds: 5), onTimeout: () {
        setState(() {
          message =
              "Some Error Occurred, Make sure you are connected to the internet.";
          resultStream.addError(message);
        });
        return null;
      });
  }

  void addTempFields() {
    List<String> categories = ['health', 'police', 'muncorp'];
    for (int i = 0; i < 10; i++) {
      feeds.add(Feed(
          feedInfo: FeedInfo(
              departmentUid: 'andskad',
              description:
                  'Citizens are informed that 10 patients are released from qaurantine',
              creationDateTimeStamp: DateTime.now(),
              title:
                  'Patients Released from quarantine are kept under isolation'),
          department: Department(
              areaOfAdministration: 'adnsd',
              category: categories[i % 3],
              email: 'naksda',
              name: 'Surat Health Department',
              userType: 'department'),
          feedInfoDetails: FeedInfoDetails(details: [
            {'title': 'asnda,'},
            {'content': 'asdnkand'},
            {
              'coords': [
                {'latLong': GeoPoint(12, 33), 'label': 'ansdnak'},
                {'latLong': GeoPoint(12, 33), 'label': 'ansdnak'}
              ]
            }
          ])));
      selected.add(false);
    }
  }

  void clearSelectedFeed() {
    setState(() {
      for (int i = 0; i < selected.length; i++) selected[i] = false;
    });
  }

  Future<void> onRefresh() async {
    getFeeds();
  }

  @override
  void initState() {
    super.initState();
    addTempFields();
    getFeeds();
  }

  @override
  void dispose() {
    resultStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool anySelected = selected.any((element) => element);
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification && scrollInfo.metrics.atEdge) {
          print('fetching more');
          getFeeds();
          return true;
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: onRefresh,
        strokeWidth: 2.5,
        child: StreamBuilder(
          stream: resultStream.stream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                child: Center(
                    child: Text(
                  'Loading ...',
                  style: Theme.of(context).textTheme.headline2,
                  textAlign: TextAlign.center,
                )),
              );
            }
            if (snapshot.hasData) {
              print('has data');
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, i) {
                  Feed f = Feed(
                      feedInfo: FeedInfo.fromFirestoreJson(
                          snapshot.data.documents[i].data),
                      department: Department.fromJson(departmentDetails[
                          snapshot.data.documents[i].data['departmentUid']]));
                  return GestureDetector(
                    onLongPress: anySelected
                        ? null
                        : () {
                            setState(() {
                              selected[i] = true;
                              widget.anyFeedSelected();
                            });
                          },
                    onTap: selected[i] || anySelected
                        ? () {
                            setState(() {
                              selected[i] = !selected[i];
                              if (!(selected.any((element) => element)))
                                widget.allSelectedFeedCleared();
                            });
                          }
                        : () {
                            Navigator.of(context)
                                .pushNamed("/feedInfo", arguments: {
                              "feed": f,
                              "feedReference":
                                  snapshot.data.documents[i].reference,
                            });
                          },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: MessageBox(
                        feed: f,
                        selected: selected[i],
                        canBeSelected: anySelected,
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 2 - 60,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          snapshot.error.toString(),
                          style: Theme.of(context).textTheme.headline2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return SizedBox();
          },
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
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
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
                              text: DateFormat('MMM, HH:m')
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
