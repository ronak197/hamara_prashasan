/*
Widget floatingButtonListTile(
      {@required Function onTap,
      @required String toolTip,
      @required Color toolTipColor,
      @required Color toolTipBackgroundColor,
      @required String iconTag,
      @required Icon icon,
      @required Color iconBackgroundColor}) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                toolTip,
                style: Theme.of(context)
                    .textTheme
                    .headline1
                    .copyWith(fontSize: 13.0, color: toolTipColor),
              ),
              decoration: BoxDecoration(
                color: toolTipBackgroundColor,
                borderRadius: BorderRadius.circular(3.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: FloatingActionButton(
              heroTag: iconTag,
              child: icon,
              onPressed: onTap,
              backgroundColor: iconBackgroundColor,
              mini: true,
              elevation: 5.0,
            ),
          ),
        ],
      ),
    );
  }
  
  floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          showInsertOptions & showTextFieldOptions
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    floatingButtonListTile(
                      onTap: editing
                          ? null
                          : () {
                              setState(() {
                                formFields.add(new TitleFieldBox());
                                gotoBottom();
                              });
                            },
                      toolTip: "Add Title",
                      toolTipColor: editing ? Colors.white : fabColor,
                      toolTipBackgroundColor: iconColor,
                      iconTag: "addTitle",
                      icon: Icon(
                        Icons.title,
                        size: 20.0,
                        color: editing ? Colors.white : iconColor,
                      ),
                      iconBackgroundColor: fabColor,
                    ),
                    floatingButtonListTile(
                      onTap: editing
                          ? null
                          : () {
                              setState(() {
                                formFields.add(new ContentFieldBox());
                                gotoBottom();
                              });
                            },
                      toolTip: "Add Description",
                      toolTipColor: editing ? Colors.white : fabColor,
                      toolTipBackgroundColor: iconColor,
                      iconTag: "addContent",
                      icon: Icon(
                        Icons.content_paste,
                        size: 20.0,
                        color: editing ? Colors.white : iconColor,
                      ),
                      iconBackgroundColor: fabColor,
                    ),
                  ],
                )
              : SizedBox(),
          showInsertOptions && !showTextFieldOptions
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    floatingButtonListTile(
                      onTap: () {
                        if (!editing) {
                          showTextFieldOptions = false;
                          showInsertOptions = false;
                        }
                        editForm();
                      },
                      toolTip: "Move or Delete Fields",
                      toolTipColor: editing ? Colors.white : fabColor,
                      toolTipBackgroundColor:
                          editing ? Colors.green : iconColor,
                      iconTag: "edit",
                      icon: Icon(
                        Icons.edit,
                        size: 20.0,
                        color: editing ? Colors.white : iconColor,
                      ),
                      iconBackgroundColor: editing ? Colors.green : fabColor,
                    ),
                    floatingButtonListTile(
                      onTap: editing
                          ? null
                          : () {
                              setState(() {
                                formFields.add(new TableFieldBox());
                                gotoBottom();
                              });
                            },
                      toolTip: "Add Table",
                      toolTipColor: editing ? Colors.white : fabColor,
                      toolTipBackgroundColor: iconColor,
                      iconTag: "addTable",
                      icon: Icon(
                        Icons.table_chart,
                        size: 20.0,
                        color: iconColor,
                      ),
                      iconBackgroundColor: fabColor,
                    ),
                    floatingButtonListTile(
                      onTap: editing
                          ? null
                          : () {
                              setState(() {
                                formFields.add(new MapFieldBox());
                                gotoBottom();
                              });
                            },
                      toolTip: "Add Map",
                      toolTipColor: editing ? Colors.white : fabColor,
                      toolTipBackgroundColor: iconColor,
                      iconTag: "addMap",
                      icon: Icon(
                        Icons.map,
                        size: 20.0,
                        color: iconColor,
                      ),
                      iconBackgroundColor: fabColor,
                    ),
                    floatingButtonListTile(
                      onTap: editing
                          ? null
                          : () {
                              setState(() {
                                formFields.add(new PictureUploadBox());
                                gotoBottom();
                              });
                            },
                      toolTip: "Add Image",
                      toolTipColor: editing ? Colors.white : fabColor,
                      toolTipBackgroundColor: iconColor,
                      iconTag: "addImage",
                      icon: Icon(
                        Icons.map,
                        size: 20.0,
                        color: iconColor,
                      ),
                      iconBackgroundColor: fabColor,
                    ),
                    floatingButtonListTile(
                      onTap: editing
                          ? null
                          : () {
                              setState(() {
                                showTextFieldOptions = !showTextFieldOptions;
                              });
                            },
                      toolTip: "Add Text",
                      toolTipColor: editing ? Colors.white : fabColor,
                      toolTipBackgroundColor: iconColor,
                      iconTag: "addText",
                      icon: Icon(
                        Icons.text_fields,
                        size: 20.0,
                        color: iconColor,
                      ),
                      iconBackgroundColor: fabColor,
                    ),
                  ],
                )
              : SizedBox(),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: FloatingActionButton(
              child: Icon(
                showInsertOptions ? Icons.close : Icons.add,
                size: 30.0,
                color: Colors.white,
              ),
              backgroundColor: Color(0xff2d334c), //Color(0xff1010fc),
              onPressed: () {
                setState(() {
                  showInsertOptions = !showInsertOptions;
                  showTextFieldOptions = false;
                });
              },
              elevation: 25,
              //padding: EdgeInsets.all(0.0),
              //borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        ],
      ),
      
   */

//import 'package:flutter/material.dart';
//
//class ImageData {
//  String url;
//  bool isLocal;
//  ImageData({@required this.url, this.isLocal}) {
//    if (this.isLocal == null) this.isLocal = false;
//  }
//}
//
//class TitleData {
//  String title;
//  TitleData({@required this.title});
//}
//
//class ContentData {
//  String text;
//  ContentData({@required this.text});
//}
//
//class MapData {
//  List<double> latitude, longitude;
//  List<String> name;
//  MapData(
//      {@required this.latitude, @required this.longitude, @required this.name});
//}
//
//class TableData {
//  List<String> headers;
//  List<List<String>> contents;
//  TableData({@required this.headers, @required this.contents})
//      : assert(contents.length == 0 ||
//            (contents.length > 0 && headers.length == contents[0].length));
//}
//
//class Feed {
//  DateTime time;
//  TitleData firstTitle;
//  List<dynamic> contents;
//  Department department;
//  LocationData location;
//  Feed({
//    @required this.contents,
//    @required this.location,
//    @required this.time,
//    @required this.department,
//    @required this.firstTitle,
//  });
//}
//
//class LocationData {
//  String city, state, country;
//  LocationData({
//    @required this.city,
//    @required this.country,
//    @required this.state,
//  });
//}
//
//class Department {
//  String name, logoUrl;
//  Department({@required this.logoUrl, @required this.name});
//}
