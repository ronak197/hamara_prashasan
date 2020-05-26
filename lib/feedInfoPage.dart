import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hamaraprashasan/app_bar_icons_icons.dart';
import 'package:hamaraprashasan/classes.dart';

class FeedInfoPage extends StatefulWidget {
  final Feed feed;
  FeedInfoPage({@required this.feed});
  @override
  _FeedInfoPageState createState() => _FeedInfoPageState(feed: feed);
}

class _FeedInfoPageState extends State<FeedInfoPage> {
  Feed feed;
  _FeedInfoPageState({this.feed});
  List<Map<String, dynamic>> content = [];

  @override
  void initState() {
    super.initState();
    if (feed != null) content = feed.feedInfoDetails.details;
  }

  void getFeedInfoDetails(DocumentReference feedReference) {
    feedReference
        .collection("feedInfoDetails")
        .getDocuments()
        .then((QuerySnapshot qs) {
      if (qs.documents.isNotEmpty) {
        setState(() {
          content = List.from(qs.documents[0].data["details"]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (feed == null) {
      Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
      feed = args['feed'];
      if (feed.feedInfoDetails != null)
        content = feed.feedInfoDetails.details;
      else {
        getFeedInfoDetails(args['feedReference']);
      }
    }
    print(content);
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
                          child: Text(feed.department.areaOfAdministration,
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
              feed.profileAvatar,
            ),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        margin: EdgeInsets.only(top: 10),
        child: ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Color(
                            categoryTagColorMap[feed.department.category]),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        feed.department.category,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                        feed.department.areaOfAdministration +
                            ", " +
                            feed.feedInfo.creationDateTimeStamp
                                .toIso8601String()
                                .substring(11, 16),
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                )
              ] +
              <Widget>[
                TitleBox(feed.feedInfo.title),
                ContentBox(feed.feedInfo.description),
              ] +
              List<Widget>.generate(content.length, (i) {
                if (content[i].containsKey('title')) {
                  String title = content[i]['title'];
                  return TitleBox(title);
                } else if (content[i].containsKey('content')) {
                  String data = content[i]['content'];
                  return ContentBox(data);
                } else if (content[i].containsKey('pictureUrl')) {
                  String pictureUrl = content[i]['pictureUrl'];
                  bool isLocal = content[i]['isLocal'] ?? false;
                  return PictureBox(pictureUrl, isLocal);
                } else if (content[i].containsKey('coords')) {
                  return MapBox(content[i]['coords']);
                } else if (content[i].containsKey('table')) {
                  TableData t = new TableData();

                  var rows = content[i]['table'].toString().split(';');
                  t.headers = rows[0].split(',');
                  t.contents = [];
                  for (int i = 1; i < rows.length; i++) {
                    t.contents.add(rows[i].split(','));
                  }

                  return TableBox(t);
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
    );
  }
}

class TitleBox extends StatelessWidget {
  final String title;
  TitleBox(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .headline4
              .copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

class ContentBox extends StatelessWidget {
  final String data;
  ContentBox(this.data);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Text(data[0].toUpperCase(),
                  style: Theme.of(context).textTheme.headline2),
            ),
            TextSpan(
              text: data.substring(1),
              style: Theme.of(context).textTheme.headline2,
            ),
          ],
        ),
      ),
    );
  }
}

class PictureBox extends StatelessWidget {
  final String pictureUrl;
  final bool isLocal;
  PictureBox(this.pictureUrl, this.isLocal);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
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
        child: isLocal
            ? Image.file(
                File(pictureUrl),
                fit: BoxFit.contain,
              )
            : CachedNetworkImage(
                imageUrl: pictureUrl,
                fit: BoxFit.contain,
                placeholder: (context, s) => Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }
}

class MapBox extends StatefulWidget {
  final List<dynamic> coords;
  MapBox(this.coords);
  @override
  _MapBoxState createState() => _MapBoxState();
}

class _MapBoxState extends State<MapBox> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _myLocation;
  List<double> latitudes = [], longitudes = [];
  List<String> labels = [];

  Set<Marker> places;

  void filterCoordinates() {
    for (int i = 0; i < widget.coords.length; i++) {
      if (i % 3 == 0)
        latitudes.add(widget.coords[i]);
      else if (i % 3 == 1)
        longitudes.add(widget.coords[i]);
      else
        labels.add(widget.coords[i]);
    }
  }

  @override
  void initState() {
    super.initState();
    filterCoordinates();
    _myLocation = CameraPosition(
      target: setInitialCameraPosition(),
      zoom: 4.0,
    );
    places = new Set();
    for (int i = 0; i < latitudes.length; i++) {
      places.add(
        new Marker(
          markerId: MarkerId(labels[i]),
          position: LatLng(latitudes[i], longitudes[i]),
        ),
      );
    }
  }

  LatLng setInitialCameraPosition() {
    double lat = 0, lng = 0;
    for (int i = 0; i < latitudes.length; i++) {
      lat += latitudes[i];
      lng += longitudes[i];
    }
    lat /= latitudes.length;
    lng /= longitudes.length;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: GoogleMap(
          initialCameraPosition: _myLocation,
          mapType: MapType.normal,
          onMapCreated: (controller) {
            _controller.complete(controller);
          },
          markers: places,
        ),
      ),
    );
  }
}

class TableBox extends StatelessWidget {
  final double tileHeight = 30, margin = 2;
  final TableData t;
  TableBox(this.t);
  @override
  Widget build(BuildContext context) {
    int n = t.contents.length + 1;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(t.headers.length, (j) {
            int colWidth = t.headers[j].length;
            for (int i = 0; i < n - 1; i++) {
              colWidth = max(t.contents[i][j].length, colWidth);
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                    Container(
                      height: tileHeight,
                      width: colWidth * 80 / 8,
                      margin: EdgeInsets.all(margin),
                      padding: EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(t.headers[j],
                          style: Theme.of(context).textTheme.headline2),
                    ),
                  ] +
                  List<Widget>.generate(n - 1, (k) {
                    return Container(
                      height: tileHeight,
                      width: colWidth * 80 / 8,
                      margin: EdgeInsets.all(margin),
                      padding: EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(t.contents[k][j],
                          style: Theme.of(context).textTheme.headline2),
                    );
                  }),
            );
          }),
        ),
      ),
    );
  }
}
