import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/feedInfoPage.dart';
import 'package:hamaraprashasan/classes.dart';

class BookmarkPage extends StatefulWidget {
  final Function anyBookmarkSelected, allSelectedBookmarkCleared;
  void clearSelectedBookmark() {
    _newsFeedPageState.clearSelectedBookmark();
  }

  _BookmarkPageState _newsFeedPageState = new _BookmarkPageState();
  BookmarkPage(
      {@required this.anyBookmarkSelected,
      @required this.allSelectedBookmarkCleared});
  @override
  _BookmarkPageState createState() => _newsFeedPageState;
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<Feed> bookmarks;
  List<bool> selected;

  void getBookmarks() {
    bookmarks = new List();
    selected = new List();
    List<String> categories = ['health', 'police', 'muncorp'];
    for (int i = 0; i < 4; i++) {
      bookmarks.add(Feed(
          FeedInfo(
              departmentUid: 'andskad',
              description: 'Quarantine facilities are made available to general public',
              creationDateTimeStamp: DateTime.now(),
              title: 'Coronovirus victims got shelter homes'
          ),
          Department(
              areaOfAdministration: 'adnsd',
              category: categories[i%3],
              email: 'naksda',
              name: 'Surat Police Department',
              userType: 'department'
          ),
          FeedInfoDetails(
              details: [
                {'title': 'Coronovirus victims got shelter homes,'},
                {'content' : 'Quarantine facilities are made available to general public'},
              ]
          )
      ));
      selected.add(false);
    }
  }

  void clearSelectedBookmark() {
    setState(() {
      for (int i = 0; i < selected.length; i++) selected[i] = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    bool anySelected = selected.any((element) => element);
    return SingleChildScrollView(
      child: Column(
        children: List<Widget>.generate(
          bookmarks.length,
          (i) => GestureDetector(
            onLongPress: anySelected
                ? null
                : () {
                    setState(() {
                      selected[i] = true;
                      widget.anyBookmarkSelected();
                    });
                  },
            onTap: selected[i] || anySelected
                ? () {
                    setState(() {
                      selected[i] = !selected[i];
                      if (!(selected.any((element) => element)))
                        widget.allSelectedBookmarkCleared();
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
              margin: EdgeInsets.symmetric(vertical: 10),
              child: MessageBox(
                feed: bookmarks[i],
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
