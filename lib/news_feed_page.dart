import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hamaraprashasan/classes.dart';
import 'package:hamaraprashasan/feedClasses.dart';
import 'package:hamaraprashasan/feedInfoPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class City {


  String name;
  String state;
  String country;
  bool capital;
  double population;
  List<String> regions;

  City(String name, String state, String country, bool capital, double population, List<String> regions);

  String getName() {
    return name;
  }

  String getState() {
    return state;
  }

  String getCountry() {
    return country;
  }

  bool isCapital() {
    return capital;
  }

  double getPopulation() {
    return population;
  }

  List<String> getRegions() {
    return regions;
  }

}

class _NewsFeedPageState extends State<NewsFeedPage> {
  List<Feed> feeds;
  List<bool> selected;

  Firestore db = Firestore.instance;

  void createRecord() async{

    FeedInfo feed = FeedInfo(
      title: 'hedasda',
      creationDateTimeStamp: DateTime.now(),
      description: 'adadad',
      departmentUid: 'admamda'
    );


    FeedInfoDetails feedInfoDetails = FeedInfoDetails(
      details: [
        {'title': 'asdasd'},
        {'content': 'asdka'},
        {'title': 'adaskd'}
      ]
    );

    DateTime d = DateTime.now();
    await db.collection('feeds').add(feed.toJson()).then((value){
      db.collection('feeds').document(value.documentID).collection('Details').add(feedInfoDetails.toJson());
    }).whenComplete((){
      print(DateTime.now().difference(d));
    });
  }

  void getFeeds() {
    feeds = new List();
    selected = new List();
    for (int i = 0; i < 4; i++) {
      feeds.add(new Feed(
        contents: [
          ContentData(
              text:
                  "Citizens are informed that curfew has been imposed starting from today till further announcement by the government of India. Following locations are the places where you can get shelter homes."),
          TableData(
            headers: List.generate(6, (index) => "Head"),
            contents: List.generate(
              4,
              (i) => List.generate(6, (j) => "Row ${i + 1}"),
            ),
          ),
          ImageData(
              url:
                  "https://firebasestorage.googleapis.com/v0/b/elare-bd2f2.appspot.com/o/cover_images%2FMLDC_cover.png?alt=media&token=b375c390-bf56-47e2-9fcf-d6ba5d7d39f8"),
        ],
        location:
            new LocationData(city: "Surat", state: "Gujarat", country: "India"),
        time: DateTime.now(),
        firstTitle: TitleData(title: "Curfew till 12th May"),
        department: Department(
            logoUrl: 'assets/police_avatar.svg', name: "Police Department"),
      ));
      selected.add(false);
    }
  }

  void clearSelectedFeed() {
    setState(() {
      for (int i = 0; i < selected.length; i++) selected[i] = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getFeeds();
    createRecord();
  }

  @override
  Widget build(BuildContext context) {
    bool anySelected = selected.any((element) => element);
    return SingleChildScrollView(
      child: Column(
        children: List<Widget>.generate(
          feeds.length,
          (i) => GestureDetector(
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FeedInfoPage(
                          feed: feeds[i],
                        ),
                      ),
                    );
                  },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: MessageBox(
                feed: feeds[i],
                selected: selected[i],
                canBeSelected: anySelected,
              ),
            ),
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
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                color: Color(0xffFFFCED),
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
                          feed.department.logoUrl,
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
                              Text(
                                feed.location.city + " " + feed.department.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    .copyWith(
                                        color: Color(0xff514A4A),
                                        fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                feed.firstTitle.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2
                                    .copyWith(color: Color(0xff514A4A)),
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
                      'Citizens are informed that curfew has been imposed starting from today till further announcement.',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(top: 10.0),
                    child: Text(
                      feed.location.city +
                          ", " +
                          feed.time.hour.toString() +
                          ":" +
                          feed.time.minute.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: Color(0xff8C8C8C)),
                    ),
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
                        color: selected ? Colors.black : Colors.white,
                        border: Border.all(),
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
