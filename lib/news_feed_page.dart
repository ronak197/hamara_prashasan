import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hamaraprashasan/classes.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class TempClass{
  List<Map<String,dynamic>> feedData = List<Map<String,dynamic>>();

  TempClass({this.feedData});
}

class NewsFeedPage extends StatefulWidget {
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {

  bool feedSelected = false;

  List<Feed> feeds = [];
  List<bool> selected = [];

  BehaviorSubject<TempClass> resultStream = BehaviorSubject<TempClass>();
  List<Map<String,dynamic>> feedData = List<Map<String,dynamic>>();

  Map<String, dynamic> departmentDetails = Map();

  DateTime startDateTimeAfter;
  DateTime endDateTimeBefore;

  String errorMessage = 'Some Error Occurred, Make sure you are connected to the internet.';
  String loadingMessage = 'Loading ...';

  bool isRunning = false;

  Future<bool> getDepartmentInfo() async {
    print('fetching departments');
    Firestore db = Firestore.instance;

    bool success = await db.collection('departments')
      .where('email', whereIn: User.userData.subscribedDepartmentIDs)
      .getDocuments()
      .then((value) {
        value.documents.forEach((element) {
          if (!departmentDetails.containsKey(element.data['email'])) {
            departmentDetails[element.data['email']] = element.data;
          }
      });
      return true;
    }).catchError((e) {
      resultStream.sink.addError(errorMessage);
      print('Error in query getDepartmentInfo $e');
      return false;
    }).whenComplete(() {
      print('Completed query getDepartmentInfo');
      return true;
    }).timeout(Duration(seconds: 5), onTimeout: (){
      resultStream.sink.addError(errorMessage);
      print('Timeout in query getDepartmentInfo');
      return false;
    });

    return success;
  }

  Future<bool> getMoreFeeds() async{
    Firestore db = Firestore.instance;

    print('fetching more feeds');

    if (User.lastUserState == UserState.feedUpdate) {

      List<Map<String,dynamic>> initialFeedData = feedData;

      startDateTimeAfter = endDateTimeBefore ?? DateTime.now();

      List<DocumentSnapshot> temp = (await db.collection('feeds')
          .where('creationDateTimeStamp', isLessThanOrEqualTo: User.userData.lastUpdateTime)
          .where('departmentUid', whereIn: User.userData.subscribedDepartmentIDs)
          .orderBy('creationDateTimeStamp', descending: true)
          .startAfter([startDateTimeAfter])
          .limit(2)
          .getDocuments()
          .timeout(Duration(seconds: 3), onTimeout: (){
            resultStream.sink.addError(errorMessage);
            return null;
          })
          .catchError((e){
            resultStream.sink.addError(errorMessage);
            print('onError in query for getLatestFeeds');
          })
          .whenComplete(() {
            print('OnDone in query for getLatestFeeds');
            User.lastUserState = UserState.feedUpdate;
            // update firestore user feed update time
          })
      ).documents;


      List<Map<String,dynamic>> newFeedData = List<Map<String,dynamic>>();
      temp.forEach((element) {
        newFeedData.add(element.data);
      });

      if(newFeedData.isNotEmpty){
        endDateTimeBefore = (newFeedData.last['creationDateTimeStamp'] as Timestamp).toDate();
        print(endDateTimeBefore);
        feedData.addAll(newFeedData);
        resultStream.sink.add(new TempClass(feedData: feedData));
      }
    }
    else {
      print('last user state is not feedUpdate');
      if(await getDepartmentInfo()) {
        print('Fetched departments info');
        User.lastUserState = UserState.feedUpdate;
        getLatestFeeds();
        print('Gonna fetch getLatestFeeds');
      } else {
        resultStream.sink.addError(errorMessage);
      }
    }
    return true;
  }

  Future<bool> getLatestFeeds() async {
      Firestore db = Firestore.instance;

      print('fetching feeds');

      if (User.lastUserState == UserState.feedUpdate) {
        feedData.clear();

        List<DocumentSnapshot> temp = (await db.collection('feeds')
            .where('creationDateTimeStamp', isLessThanOrEqualTo: User.userData.lastUpdateTime)
            .where('departmentUid', whereIn: User.userData.subscribedDepartmentIDs)
            .orderBy('creationDateTimeStamp', descending: true)
            .limit(2)
            .getDocuments()
            .timeout(Duration(seconds: 3), onTimeout: (){
              resultStream.sink.addError(errorMessage);
              return null;
            })
            .catchError((e){
              resultStream.sink.addError(errorMessage);
              print('onError in query for getLatestFeeds');
            })
            .whenComplete(() {
              print('OnDone in query for getLatestFeeds');
              User.lastUserState = UserState.feedUpdate;
              // update firestore user feed update time
            })
        ).documents;

        List<Map<String,dynamic>> newFeedData = List<Map<String,dynamic>>();
        temp.forEach((element) {
          newFeedData.add(element.data);
        });
        endDateTimeBefore = (newFeedData.last['creationDateTimeStamp'] as Timestamp).toDate();
        feedData.addAll(newFeedData);
        resultStream.sink.add(new TempClass(feedData: feedData));
      }
      else {
        print('last user state is not feedUpdate');
        if(await getDepartmentInfo()) {
          print('Fetched departments info');
          User.lastUserState = UserState.feedUpdate;
          getLatestFeeds();
          print('Gonna fetch getLatestFeeds');
        } else {
          resultStream.sink.addError(errorMessage);
        }
      }
      return true;
  }

  void clearSelectedFeed() {
    setState(() {
      for (int i = 0; i < selected.length; i++) selected[i] = false;
    });
  }


  Future<void> feedHandler({bool moreFeeds = false, bool latestFeeds = false}) async{
//    assert(moreFeeds != latestFeeds);
//    assert(isRunning == false);
    if(moreFeeds == latestFeeds || isRunning == true){
      return;
    }
    else if(moreFeeds != latestFeeds && isRunning == false){
      isRunning = true;
      print('isRunning ${latestFeeds ? 'latestFeeds' : 'moreFeeds'} $isRunning');
      if(moreFeeds){
        await getMoreFeeds();
      } else {
        await getLatestFeeds();
      }
      isRunning = false;
      print('isRunning ${latestFeeds ? 'latestFeeds' : 'moreFeeds'} $isRunning');
    }
  }

  void addTempFields() {
    for (int i = 0; i < 10; i++) {
      selected.add(false);
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

  void _onLongPress(int i){
    bool anySelected = selected.any((element) => element);
    if(!anySelected){
      setState(() {
        selected[i] = true;
        anyFeedSelected();
      });
    }
  }

  void _onTap(int i, Feed f, snapshot){
    bool anySelected = selected.any((element) => element);
    if(selected[i] || anySelected){
      setState(() {
        selected[i] = !selected[i];
        if (!(selected.any((element) => element)))
          allSelectedFeedCleared();
      });
    }
    else {
      Navigator.of(context)
          .pushNamed("/feedInfo", arguments: {
        "feed": f,
        "feedReference": snapshot.data.feedData[i]['email'],
      });
    }
  }

  @override
  void initState() {
    super.initState();
    addTempFields();
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
      appBar: feedSelected ? AppBar(
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
      ) : AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        leading: Container(
          margin: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  User.authUser.photoUrl,
                )
            ),
          ),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
        titleSpacing: 5.0,
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification && scrollInfo.metrics.pixels >= (scrollInfo.metrics.maxScrollExtent - 60.0) ) {
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
            builder: (context, AsyncSnapshot<TempClass> snapshot) {
              print('Snapshot details, connection : ${snapshot.connectionState.toString()}, hasData : ${snapshot.hasData}, hasError : ${snapshot.hasError}, hasCode : ${snapshot.hashCode}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return FeedLoadStatus(displayMessage: loadingMessage,);
              }
              else if (snapshot.connectionState == ConnectionState.active) {
                if(snapshot.hasData && snapshot.data.feedData.isNotEmpty){
                  return ListView.builder(
                    itemCount: snapshot.data.feedData.length,
                    itemBuilder: (context, i) {
                      Feed f = Feed(
                          feedInfo: FeedInfo.fromFirestoreJson(
                              snapshot.data.feedData[i]),
                          department: Department.fromJson(departmentDetails[
                          snapshot.data.feedData[i]['departmentUid']]));
                      return GestureDetector(
                        onLongPress: () => _onLongPress(i),
                        onTap: () => _onTap(i,f,snapshot),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: MessageBox(
                            feed: f,
                            selected: selected[i],
                            canBeSelected: false,
                          ),
                        ),
                      );
                    },
                  );
                }
                else if (snapshot.hasError) {
                  return FeedLoadStatus(displayMessage: errorMessage,);
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
    return LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(displayMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline2,
                  )
                ],
              ),
            ),
          ),
        )
    )
    );
  }
}
