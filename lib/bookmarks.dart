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
              description: 'anjdsbkandkasmlda',
              creationDateTimeStamp: DateTime.now(),
              title: 'anksdnaknd'
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
                {'title': 'asnda,'},
                {'content' : 'asdnkand'},
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
              margin: EdgeInsets.symmetric(horizontal: 15.0),
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
                                feed.department.areaOfAdministration + " " + feed.department.name,
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
                                feed.feedInfo.title,
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
                      feed.feedInfo.description,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(top: 10.0),
                    child: Text(
                      feed.department.areaOfAdministration +
                          ", " +
                          feed.feedInfo.creationDateTimeStamp.hour.toString() +
                          ":" +
                          feed.feedInfo.creationDateTimeStamp.minute.toString(),
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
