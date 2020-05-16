import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/app_bar_icons_icons.dart';
import 'package:hamaraprashasan/feedClasses.dart';

class FeedInfoPage extends StatefulWidget {
  final Feed feed;
  FeedInfoPage({@required this.feed});
  @override
  _FeedInfoPageState createState() => _FeedInfoPageState(feed: feed);
}

class _FeedInfoPageState extends State<FeedInfoPage> {
  final Feed feed;
  _FeedInfoPageState({this.feed});
  List<dynamic> content;

  @override
  void initState() {
    super.initState();
    content = feed.contents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 5.0,
        titleSpacing: 0.0,
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(feed.department.name,
                  style: Theme.of(context).textTheme.headline2),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      height: 16.0,
                      alignment: Alignment.bottomCenter,
                      child: Center(
                          child: Icon(
                        AppBarIcons.location,
                        size: 10.0,
                        color: Color(0xff6D6D6D),
                      ))),
                  Container(
                      height: 16.0,
                      alignment: Alignment.bottomRight,
                      child: Center(
                          child: Text(feed.location.city,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(color: Color(0xff6D6D6D)))))
                ],
              )
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: SvgPicture.asset(
              feed.department.logoUrl,
            ),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List<Widget>.generate(content.length, (i) {
                  if (content[i].runtimeType == TitleData) {
                    String title = (content[i] as TitleData).title;
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text(
                              feed.location.country +
                                  ", " +
                                  feed.time.hour.toString() +
                                  ":" +
                                  feed.time.minute.toString(),
                              style: Theme.of(context).textTheme.bodyText1),
                        ],
                      ),
                    );
                  }
                  if (content[i].runtimeType == ContentData) {
                    String data = (content[i] as ContentData).text;
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: Text(data,
                          style: Theme.of(context).textTheme.headline2),
                    );
                  } else if (content[i].runtimeType == ImageData) {
                    ImageData image = content[i] as ImageData;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 2,
                            offset: Offset(5, 5),
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: image.isLocal
                            ? Image.file(
                                File(image.url),
                                fit: BoxFit.contain,
                              )
                            : CachedNetworkImage(
                                imageUrl: image.url,
                                fit: BoxFit.contain,
                                placeholder: (context, s) => Container(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                      ),
                    );
                  }
                  if (content[i].runtimeType == MapData) {
                    return SizedBox();
                  }
                  if (content[i].runtimeType == TableData) {
                    TableData t = content[i] as TableData;
                    int n = t.contents.length + 1;
                    double tileHeight = 30, margin = 2;
                    return Container(
                      height: n * (tileHeight + 2 * margin),
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: List<Widget>.generate(t.headers.length, (j) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                                  Container(
                                    height: tileHeight,
                                    width: tileHeight * 3,
                                    margin: EdgeInsets.all(margin),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(t.headers[j],
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2),
                                  ),
                                ] +
                                List<Widget>.generate(n - 1, (k) {
                                  return Container(
                                    height: tileHeight,
                                    width: tileHeight * 3,
                                    margin: EdgeInsets.all(margin),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(t.contents[k][j],
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2),
                                  );
                                }),
                          );
                        }),
                      ),
                    );
                  } else {
                    return SizedBox();
                  }
                }) +
                <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                ],
          ),
        ),
      ),
    );
  }
}
