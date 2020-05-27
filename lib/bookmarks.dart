import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:hamaraprashasan/feedInfoPage.dart';
import 'package:hamaraprashasan/classes.dart';

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<Feed> bookmarks;
  List<bool> selected;

  bool bookmarkSelected = false;

  void getBookmarks() {
    bookmarks = new List();
    selected = new List();
    List<String> categories = ['health', 'police', 'muncorp'];
    for (int i = 0; i < 4; i++) {
      bookmarks.add(
          Feed(
              feedInfo: FeedInfo(
                  departmentUid: 'andskad',
                  description: 'Citizens are informed that 10 patients are released from qaurantine',
                  creationDateTimeStamp: DateTime.now(),
                  title: 'Patients Released from quarantine are kept under isolation'
              ),
              department: Department(
                  areaOfAdministration: 'adnsd',
                  category: categories[i%3],
                  email: 'naksda',
                  name: 'Surat Health Department',
                  userType: 'department'
              ),
              feedInfoDetails: FeedInfoDetails(
                  details: [
                    {'title': 'asnda,'},
                    {'content' : 'asdnkand'},
                    {'coords' : [{'latLong' : LatLng(12,33), 'label' : 'ansdnak'},{'latLong' : LatLng(12,33), 'label' : 'ansdnak'}]}
                  ]
              )
          )
      );
      selected.add(false);
    }
  }

  void clearSelectedBookmark() {
    setState(() {
      for (int i = 0; i < selected.length; i++) selected[i] = false;
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

//  void clearSelectedBookmark() {
//    setState(() {
//      bookmarkSelected = false;
//    });
//    bookmarkPage.clearSelectedBookmark();
//  }

  @override
  void initState() {
    super.initState();
    getBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    bool anySelected = selected.any((element) => element);
    return Scaffold(
      appBar: bookmarkSelected ? AppBar(
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
      body: SingleChildScrollView(
        child: Column(
          children: List<Widget>.generate(
            bookmarks.length,
            (i) => GestureDetector(
              onLongPress: anySelected
                  ? null
                  : () {
                      setState(() {
                        selected[i] = true;
                        anyBookmarkSelected();
                      });
                    },
              onTap: selected[i] || anySelected
                  ? () {
                      setState(() {
                        selected[i] = !selected[i];
                        if (!(selected.any((element) => element)))
                          allSelectedBookmarkCleared();
                      });
                    }
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FeedInfoPage(
                            feed: bookmarks[i],
                          ),
                        ),
                      );
                    },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: MessageBox(
                  feed: bookmarks[i],
                  selected: selected[i],
                  canBeSelected: anySelected,
                ),
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
                      placeholderBuilder: (context){
                        return Container(
                          width: 64.0,
                          height: 64.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.white, Color(0xfff7f7f7)]
                            ),
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
                            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Color(categoryTagColorMap[feed.department.category]),
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
                                  .copyWith(color: Color(0xff303046), fontWeight: FontWeight.w600),
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
                  style: Theme.of(context).textTheme.headline1.copyWith(fontWeight: FontWeight.normal),
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
                      text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: Icon(Icons.access_time, size: 13.0, color: Color(0xff8C8C8C),),
                              ),
                            ),
                            TextSpan(
                              text: 'July' + ', ' + feed.feedInfo
                                  .creationDateTimeStamp.hour.toString() +
                                  ":" +
                                  feed.feedInfo.creationDateTimeStamp.minute.toString(),
                              style: Theme.of(context).textTheme.bodyText1
                                  .copyWith(color: Color(0xff8C8C8C)),
                            ),
                          ]
                      ),
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
