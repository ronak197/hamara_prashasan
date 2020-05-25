import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hamaraprashasan/classes.dart';
import 'package:hamaraprashasan/searchPlace.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

class FormField {
  String data;
  bool disabled;
  Type fieldType;
  void saveData(String data) {
    this.data = data;
  }

  FormField(this.data, this.disabled, this.fieldType);
}

class SendPostPage extends StatefulWidget {
  @override
  _SendPostPageState createState() => _SendPostPageState();
}

class _SendPostPageState extends State<SendPostPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int keyIndex = 1;

  List<FormField> formFields = [];
  bool showInsertOptions = false;
  bool showTextFieldOptions = false;
  bool editing = false;

  String _dropDownOption = "Up";

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void _sendPost() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save();
      String postData;
      List<String> formContent = [];
      formFields.forEach((element) {
        formContent.add('${element.data}');
      });
      var created = getCurrentTimeInString();
      await Firestore.instance.collection("feeds").add({
        "feed": formContent,
        "created": created,
      });
    }
  }

  String getCurrentTimeInString() {
    var dt = DateTime.now();
    String s = dt.year.toString();
    if (dt.month < 10) s += "0";
    s += dt.month.toString();
    if (dt.day < 10) s += "0";
    s += dt.day.toString();
    if (dt.hour < 10) s += "0";
    s += dt.hour.toString();
    if (dt.minute < 10) s += "0";
    s += dt.minute.toString();
    if (dt.second < 10) s += "0";
    s += dt.second.toString();
    return s;
  }

  void startPreview() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save();
      List<Map<String, dynamic>> contents = [];
      String title = json.decode(formFields[0].data)['title'],
          description = json.decode(formFields[1].data)['content'];
      for (int i = 0; i < formFields.length; i++) {
        var data = json.decode(formFields[i].data);
        if (data['title'] != null) {
          contents.add(
            {"title": data['title']},
          );
        } else if (data['content'] != null) {
          contents.add(
            {"content": data['content']},
          );
        } else if (data['picture'] != null) {
          contents.add({"pictureUrl": data['picture'], "isLocal": true});
        } else if (data['map'] != null) {
          List<double> latLong = List.from(data['map']),
              latitude = [],
              longitude = [];
          for (int i = 0; i < latLong.length / 2; i++) {
            latitude.add(latLong[2 * i]);
            longitude.add(latLong[2 * i + 1]);
          }
          contents.add(
              {"latitude": latitude, "longitude": longitude, "label": null});
        } else if (data['table'] != null) {
          contents.add({"table": data['table']});
        }
      }
      Feed f = new Feed(
        FeedInfo(
          departmentUid: 'andskad',
          description: description,
          creationDateTimeStamp: DateTime.now(),
          title: title,
        ),
        Department(
          areaOfAdministration: 'adnsd',
          category: "health",
          email: 'naksda',
          name: 'Surat Health Department',
          userType: 'department',
        ),
        FeedInfoDetails(
          details: contents,
        ),
      );
      if (!FocusScope.of(context).hasPrimaryFocus)
        FocusScope.of(context).unfocus();
      Navigator.of(context).pushNamed("/feedInfo", arguments: {"feed": f});
    }
  }

  void editForm() {
    if (editing) {
      for (int i = 0; i < formFields.length; i++) {
        formFields[i].disabled = false;
      }
      editing = false;
    } else {
      for (int i = 0; i < formFields.length; i++) {
        formFields[i].disabled = true;
      }
      editing = true;
    }
    setState(() {});
  }

  Widget fieldWidget(FormField f) {
    if (f.fieldType == TitleFieldBox)
      return TitleFieldBox(
          data: f.data, disabled: f.disabled, saveData: f.saveData);
    else if (f.fieldType == ContentFieldBox)
      return ContentFieldBox(
          data: f.data, disabled: f.disabled, saveData: f.saveData);
    else if (f.fieldType == PictureUploadBox)
      return PictureUploadBox(
          data: f.data, disabled: f.disabled, saveData: f.saveData);
    else if (f.fieldType == MapFieldBox)
      return MapFieldBox(
          data: f.data, disabled: f.disabled, saveData: f.saveData);
    else if (f.fieldType == TableFieldBox)
      return TableFieldBox(
          data: f.data, disabled: f.disabled, saveData: f.saveData);
    else
      return null;
  }

  @override
  void initState() {
    formFields.add(FormField(null, false, TitleFieldBox));
    formFields.add(FormField(null, false, ContentFieldBox));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var form = _formKey.currentState;
    if (form != null) {
      form.save();
    }
    var fabColor = editing ? Colors.grey : Color(0xff2d334c),
        iconColor = editing ? Colors.grey[300] : Colors.white;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          'Write Post',
          style: Theme.of(context).textTheme.headline2,
        ),
        actions: [
          GestureDetector(
            onTap: startPreview,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Center(
                child: Text(
                  'PREVIEW',
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Center(
                child: IconButton(
              icon: Icon(Icons.send),
              color: Colors.black,
              onPressed: _sendPost,
            )),
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          showInsertOptions & showTextFieldOptions
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                formFields.add(
                                    new FormField(null, false, TitleFieldBox));
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(
                                "Add Title",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(
                                        fontSize: 13.0,
                                        color:
                                            editing ? Colors.white : fabColor),
                              ),
                              decoration: BoxDecoration(
                                color: editing ? Colors.green : iconColor,
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
                              heroTag: "addTitle",
                              child: Icon(
                                Icons.title,
                                size: 20.0,
                                color: editing ? Colors.white : iconColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  formFields.add(new FormField(
                                      null, false, TitleFieldBox));
                                });
                              },
                              backgroundColor:
                                  editing ? Colors.green : fabColor,
                              mini: true,
                              elevation: 5.0,
                              //padding: EdgeInsets.all(0.0),
                              //borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                formFields.add(new FormField(
                                    null, false, ContentFieldBox));
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(
                                "Add Description",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(
                                        fontSize: 13.0,
                                        color:
                                            editing ? Colors.white : fabColor),
                              ),
                              decoration: BoxDecoration(
                                color: editing ? Colors.green : iconColor,
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
                              heroTag: "addContent",
                              child: Icon(
                                Icons.content_paste,
                                size: 20.0,
                                color: editing ? Colors.white : iconColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  formFields.add(new FormField(
                                      null, false, ContentFieldBox));
                                });
                              },
                              backgroundColor:
                                  editing ? Colors.green : fabColor,
                              mini: true,
                              elevation: 5.0,
                              //padding: EdgeInsets.all(0.0),
                              //borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : SizedBox(),
          showInsertOptions && !showTextFieldOptions
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: editing
                                ? null
                                : () {
                                    setState(() {
                                      showTextFieldOptions =
                                          !showTextFieldOptions;
                                    });
                                  },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(
                                "Add Text",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(
                                        fontSize: 13.0,
                                        color:
                                            editing ? Colors.white : fabColor),
                              ),
                              decoration: BoxDecoration(
                                color: editing ? Colors.green : iconColor,
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
                              heroTag: "addText",
                              child: Icon(
                                Icons.text_fields,
                                size: 20.0,
                                color: iconColor,
                              ),
                              backgroundColor: fabColor,
                              onPressed: editing
                                  ? null
                                  : () {
                                      setState(() {
                                        showTextFieldOptions =
                                            !showTextFieldOptions;
                                      });
                                    },
                              mini: true,
                              elevation: 20,
                              //padding: EdgeInsets.all(0.0),
                              //borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: editing
                                ? null
                                : () {
                                    setState(() {
                                      formFields.add(new FormField(
                                          null, false, PictureUploadBox));
                                    });
                                  },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(
                                "Add Image",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(
                                        fontSize: 13.0,
                                        color:
                                            editing ? Colors.white : fabColor),
                              ),
                              decoration: BoxDecoration(
                                color: editing ? Colors.green : iconColor,
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
                              heroTag: "addImage",
                              child: Icon(
                                Icons.insert_photo,
                                size: 20.0,
                                color: iconColor,
                              ),
                              backgroundColor: fabColor,
                              onPressed: editing
                                  ? null
                                  : () {
                                      setState(() {
                                        formFields.add(new FormField(
                                            null, false, PictureUploadBox));
                                      });
                                    },
                              mini: true,
                              elevation: 20,
                              //padding: EdgeInsets.all(0.0),
                              //borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: editing
                                ? null
                                : () {
                                    setState(() {
                                      formFields.add(new FormField(
                                          null, false, MapFieldBox));
                                    });
                                  },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(
                                "Add Map",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(
                                        fontSize: 13.0,
                                        color:
                                            editing ? Colors.white : fabColor),
                              ),
                              decoration: BoxDecoration(
                                color: editing ? Colors.green : iconColor,
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
                              heroTag: "addMap",
                              child: Icon(
                                Icons.map,
                                size: 20.0,
                                color: iconColor,
                              ),
                              backgroundColor: fabColor,
                              onPressed: editing
                                  ? null
                                  : () {
                                      setState(() {
                                        formFields.add(new FormField(
                                            null, false, MapFieldBox));
                                      });
                                    },
                              mini: true,
                              elevation: 20,
                              //padding: EdgeInsets.all(0.0),
                              //borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: editing
                                ? null
                                : () {
                                    setState(() {
                                      formFields.add(new FormField(
                                          null, false, TableFieldBox));
                                    });
                                  },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(
                                "Add Map",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(
                                        fontSize: 13.0,
                                        color:
                                            editing ? Colors.white : fabColor),
                              ),
                              decoration: BoxDecoration(
                                color: editing ? Colors.green : iconColor,
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
                              heroTag: "addTable",
                              child: Icon(
                                Icons.table_chart,
                                size: 20.0,
                                color: iconColor,
                              ),
                              backgroundColor: fabColor,
                              onPressed: editing
                                  ? null
                                  : () {
                                      setState(() {
                                        formFields.add(new FormField(
                                            null, false, TableFieldBox));
                                      });
                                    },
                              mini: true,
                              elevation: 20,
                              //padding: EdgeInsets.all(0.0),
                              //borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /* Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: MaterialButton(
                              child: Text(
                                "Edit",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(
                                        color:
                                            editing ? Colors.white : iconColor),
                              ),
                              color: editing ? Colors.green : fabColor,
                              onPressed: () {
                                if (!editing) {
                                  showInsertOptions = false;
                                }
                                editForm();
                              },
                              padding: EdgeInsets.all(0.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 20,
                            ),
                          ), */
                          InkWell(
                            onTap: () {
                              showTextFieldOptions = false;
                              showInsertOptions = false;
                              editForm();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(
                                "Move or Delete Fields",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(
                                        fontSize: 13.0,
                                        color:
                                            editing ? Colors.white : fabColor),
                              ),
                              decoration: BoxDecoration(
                                color: editing ? Colors.green : iconColor,
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
                              heroTag: "edit",
                              child: Icon(
                                Icons.edit,
                                size: 20.0,
                                color: editing ? Colors.white : iconColor,
                              ),
                              onPressed: () {
                                showTextFieldOptions = false;
                                showInsertOptions = false;
                                editForm();
                              },
                              backgroundColor:
                                  editing ? Colors.green : fabColor,
                              mini: true,
                              elevation: 5.0,
                              //padding: EdgeInsets.all(0.0),
                              //borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ],
                      ),
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
      body: Opacity(
        opacity: showInsertOptions ? 0.2 : 1,
        child: Form(
          key: _formKey,
          child: editing
              ? ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex >= 2 && newIndex > 1) {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      var f = formFields.removeAt(oldIndex);
                      formFields.insert(newIndex, f);
                      setState(() {});
                    } else {
                      showMessage(
                          "You cannot reorder the first Title and Description fields.");
                    }
                  },
                  children: List<Widget>.generate(
                    formFields.length,
                    (index) {
                      var field = formFields[index];
                      {
                        if (index < 2)
                          return fieldWidget(field);
                        else
                          return Dismissible(
                            key: new Key(formFields[index].hashCode.toString()),
                            onDismissed: (dir) async {
                              formFields.removeAt(index);
                              setState(() {});
                            },
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30,
                              ),
                              margin: EdgeInsets.symmetric(vertical: 20),
                              padding: EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: fieldWidget(field),
                          );
                      }
                    },
                  ),
                )
              : ListView(
                  children: List<Widget>.generate(
                    formFields.length,
                    (index) {
                      var field = formFields[index];
                      return fieldWidget(field);
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class TitleFieldBox extends StatefulWidget {
  String data;
  final Function saveData;
  Key key;
  TitleFieldBox(
      {@required this.data, @required this.disabled, @required this.saveData}) {
    key = new Key(this.hashCode.toString());
  }
  final bool disabled;

  @override
  _TitleFieldBoxState createState() => _TitleFieldBoxState();
}

class _TitleFieldBoxState extends State<TitleFieldBox> {
  String initialString;
  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      initialString = json.decode(widget.data)['title'];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool dis = widget.disabled;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 1.0,
            offset: Offset(0, 2.5),
            color: Colors.grey[300],
          ),
          BoxShadow(
            blurRadius: 0.1,
            offset: Offset(0, -0.5),
            color: Colors.grey[300],
          )
        ],
        color: Colors.white,
      ),
      child: TextFormField(
        validator: (s) {
          return s == "" ? 'Enter a Title' : null;
        },
        onSaved: (s) {
          widget.saveData(json.encode({"title": s}));
        },
        style: Theme.of(context)
            .textTheme
            .headline2
            .copyWith(color: dis ? Colors.grey : Colors.black),
        cursorColor: Colors.black54,
        minLines: 1,
        maxLines: null,
        maxLength: 100,
        maxLengthEnforced: true,
        enabled: !dis,
        initialValue: initialString,
        decoration: InputDecoration(
          labelText: 'TITLE',
          hintText: 'Enter Title...',
          hintStyle: Theme.of(context)
              .textTheme
              .headline2
              .copyWith(color: Colors.grey, fontSize: 15.0),
          labelStyle: Theme.of(context).textTheme.headline1.copyWith(
              color: dis ? Colors.grey : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15.0),
          counterText: "",
          contentPadding: EdgeInsets.all(12.0),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class ContentFieldBox extends StatefulWidget {
  String data;
  final Function saveData;
  Key key;
  ContentFieldBox(
      {@required this.data, @required this.disabled, @required this.saveData}) {
    key = new Key(this.hashCode.toString());
  }
  final bool disabled;

  @override
  _ContentFieldBoxState createState() => _ContentFieldBoxState();
}

class _ContentFieldBoxState extends State<ContentFieldBox> {
  String initialString;
  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      initialString = json.decode(widget.data)['content'];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool dis = widget.disabled;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 1.0,
            offset: Offset(0, 2.5),
            color: Colors.grey[300],
          ),
          BoxShadow(
            blurRadius: 0.1,
            offset: Offset(0, -0.5),
            color: Colors.grey[300],
          )
        ],
        color: Colors.white,
      ),
      child: TextFormField(
        validator: (s) {
          return s == "" ? 'Enter some content' : null;
        },
        onSaved: (s) {
          widget.saveData(json.encode({"content": s}));
        },
        style: Theme.of(context)
            .textTheme
            .headline2
            .copyWith(color: dis ? Colors.grey : Colors.black),
        cursorColor: Colors.black54,
        minLines: 3,
        maxLines: null,
        maxLength: 600,
        maxLengthEnforced: true,
        keyboardType: TextInputType.text,
        initialValue: initialString,
        enabled: !dis,
        decoration: InputDecoration(
          labelText: 'DESCRIPTION',
          hintText: 'Enter Details...',
          counterText: "",
          hintStyle: Theme.of(context)
              .textTheme
              .headline2
              .copyWith(color: Colors.grey, fontSize: 15.0),
          labelStyle: Theme.of(context).textTheme.headline1.copyWith(
              color: dis ? Colors.grey : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15.0),
          contentPadding: EdgeInsets.all(12.0),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class PictureUploadBox extends StatefulWidget {
  String data;
  final Function saveData;
  Key key;
  PictureUploadBox(
      {@required this.data, @required this.disabled, @required this.saveData}) {
    key = new Key(this.hashCode.toString());
  }
  final bool disabled;

  @override
  _PictureUploadBoxState createState() => _PictureUploadBoxState();
}

class _PictureUploadBoxState extends State<PictureUploadBox> {
  File image;
  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      image = File(json.decode(widget.data)['picture']);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool dis = widget.disabled;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 1.0,
            offset: Offset(0, 2.5),
            color: Colors.grey[300],
          ),
          BoxShadow(
            blurRadius: 0.1,
            offset: Offset(0, -0.5),
            color: Colors.grey[300],
          )
        ],
      ),
      child: ListTile(
        title: Text(
          'PICTURE',
          style: Theme.of(context).textTheme.headline2.copyWith(
              fontWeight: FontWeight.bold,
              color: dis ? Colors.grey : Colors.black),
        ),
        subtitle: image != null
            ? Text(
                image.path.split("/").last,
              )
            : SizedBox(),
        trailing: image != null
            ? RaisedButton(
                child: Text(
                  "Uploaded",
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .copyWith(color: Colors.white),
                ),
                color: Color(0xff2d334c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: dis
                    ? null
                    : () async {
                        image = await ImagePicker.pickImage(
                            source: ImageSource.gallery);
                        setState(() {});
                        widget.saveData(json.encode({'picture': image.path}));
                      },
              )
            : RaisedButton(
                child: Text(
                  "Upload",
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .copyWith(color: Colors.white),
                ),
                color: Color(0xfff69264),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: dis
                    ? null
                    : () async {
                        image = await ImagePicker.pickImage(
                            source: ImageSource.gallery);
                        setState(() {});
                        widget.saveData(json.encode({'picture': image.path}));
                      },
              ),
      ),
    );
  }
}

class MapFieldBox extends StatefulWidget {
  String data;
  final Function saveData;
  Key key;
  MapFieldBox(
      {@required this.data, @required this.disabled, @required this.saveData}) {
    key = new Key(this.hashCode.toString());
  }

  final bool disabled;

  @override
  _MapFieldBoxState createState() => _MapFieldBoxState();
}

class _MapFieldBoxState extends State<MapFieldBox> {
  bool searchOptions = false;

  int noOfLatLongs = 1;
  List<dynamic> latLongs = [];
  List<TextEditingController> latCont = [TextEditingController()],
      longCont = [TextEditingController()],
      labelCont = [TextEditingController()];

  void saveMapData() {
    if (latLongs.length > 0) widget.saveData(json.encode({'map': latLongs}));
  }

  void initState() {
    super.initState();
    if (widget.data != null) {
      List<dynamic> latLong = json.decode(widget.data)['map'];
      latCont = [];
      longCont = [];
      labelCont = [];
      for (int i = 0; i < latLong.length; i++) {
        if (i % 3 == 0) {
          if (latLong[i] != null)
            latCont.add(TextEditingController(text: latLong[i].toString()));
          else
            latCont.add(TextEditingController());
        } else if (i % 3 == 1) {
          if (latLong[i] != null)
            longCont.add(TextEditingController(text: latLong[i].toString()));
          else
            longCont.add(TextEditingController());
        } else {
          if (latLong[i] != null)
            labelCont.add(TextEditingController(text: latLong[i].toString()));
          else
            labelCont.add(TextEditingController());
        }
      }
      noOfLatLongs = latCont.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool dis = widget.disabled;
    if (dis) searchOptions = false;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 1.0,
            offset: Offset(0, 2.5),
            color: Colors.grey[300],
          ),
          BoxShadow(
            blurRadius: 0.1,
            offset: Offset(0, -0.5),
            color: Colors.grey[300],
          )
        ],
      ),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'MAP',
                    style: Theme.of(context).textTheme.headline2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: dis ? Colors.grey : Colors.black),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    searchOptions
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: RaisedButton(
                              child: Text(
                                "Search Place",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(color: Colors.white),
                              ),
                              color: Color(0xff02c6ba),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onPressed: dis
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SearchPlace(
                                            addPlaces: (List<Marker> places) {
                                              noOfLatLongs += places.length;
                                              for (var loc in places) {
                                                latCont.add(
                                                    new TextEditingController(
                                                        text: loc
                                                            .position.latitude
                                                            .toString()));
                                                longCont.add(
                                                    new TextEditingController(
                                                        text: loc
                                                            .position.longitude
                                                            .toString()));
                                                labelCont.add(
                                                    new TextEditingController(
                                                        text: loc
                                                            .markerId.value));
                                              }
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      );
                                    },
                            ),
                          )
                        : SizedBox(),
                    searchOptions
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: RaisedButton(
                              child: Text(
                                "Add LatLong",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(color: Colors.white),
                              ),
                              color: Color(0xff02c6ba),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onPressed: dis
                                  ? null
                                  : () {
                                      noOfLatLongs += 1;
                                      latCont.add(new TextEditingController());
                                      longCont.add(new TextEditingController());
                                      labelCont
                                          .add(new TextEditingController());
                                      setState(() {});
                                    },
                            ),
                          )
                        : SizedBox(),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: IconButton(
                          padding: EdgeInsets.all(0.0),
                          onPressed: dis
                              ? null
                              : () {
                                  setState(() {
                                    searchOptions =
                                        searchOptions ? false : true;
                                  });
                                },
                          icon: Icon(
                            searchOptions
                                ? Icons.close
                                : Icons.add_circle_outline,
                          ),
                          color: Color(0xff5658d0),
                          disabledColor: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              primary: false,
              shrinkWrap: true,
              itemCount: noOfLatLongs,
              itemBuilder: (_, index) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 8.0),
                        child: TextFormField(
                          controller: latCont[index],
                          validator: (s) {
                            return s == "" ? 'Enter Latitude' : null;
                          },
                          onSaved: (s) {
                            if (index == 0) {
                              latLongs = [];
                            }
                            if (s.length != 0)
                              latLongs.insert(index * 3, double.parse(s));
                            else
                              latLongs.insert(index * 3, null);
                          },
                          style: Theme.of(context).textTheme.headline1.copyWith(
                              color:
                                  dis ? Colors.grey[300] : Color(0xff8baee6)),
                          enabled: !widget.disabled,
                          enableInteractiveSelection: false,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hoverColor: Colors.amber,
                            labelText: 'Latitude',
                            labelStyle: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(
                                    color:
                                        dis ? Colors.grey : Color(0xff8baee6)),
                            filled: true,
                            isDense: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xff8baee6),
                                  style: BorderStyle.solid,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xff8baee6),
                                  style: BorderStyle.solid,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xff8baee6),
                                  style: BorderStyle.solid,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 8.0),
                        child: TextFormField(
                          controller: longCont[index],
                          validator: (s) {
                            return s == "" ? 'Enter Longitude' : null;
                          },
                          onSaved: (s) {
                            if (s.length != 0)
                              latLongs.insert(index * 3 + 1, double.parse(s));
                            else
                              latLongs.insert(index * 3 + 1, null);
                          },
                          style: Theme.of(context).textTheme.headline1.copyWith(
                              color:
                                  dis ? Colors.grey[300] : Color(0xff81c39f)),
                          enabled: !widget.disabled,
                          keyboardType: TextInputType.number,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            labelText: 'Longitude',
                            labelStyle: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(
                                    color:
                                        dis ? Colors.grey : Color(0xff81c39f)),
                            focusColor: Colors.red,
                            filled: true,
                            isDense: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xff81c39f),
                                  style: BorderStyle.solid,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xff81c39f),
                                  style: BorderStyle.solid,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xff81c39f),
                                  style: BorderStyle.solid,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 8.0),
                        child: TextFormField(
                          controller: labelCont[index],
                          validator: (s) {
                            return s == "" ? 'Enter a Label' : null;
                          },
                          onSaved: (s) {
                            if (s.length != 0)
                              latLongs.insert(index * 3 + 2, s);
                            else
                              latLongs.insert(index * 3 + 2, null);
                            if (index + 1 == noOfLatLongs) {
                              saveMapData();
                            }
                          },
                          style: Theme.of(context).textTheme.headline1.copyWith(
                              color:
                                  dis ? Colors.grey[300] : Color(0xfff3d081)),
                          enabled: !widget.disabled,
                          enableInteractiveSelection: false,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hoverColor: Colors.amber,
                            labelText: 'Label',
                            labelStyle: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(
                                    color:
                                        dis ? Colors.grey : Color(0xfff3d081)),
                            filled: true,
                            isDense: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xfff3d081),
                                  style: BorderStyle.solid,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xfff3d081),
                                  style: BorderStyle.solid,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xfff3d081),
                                  style: BorderStyle.solid,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    /* IconButton(
                      icon: Icon(
                        Icons.close,
                      ),
                      color: Colors.redAccent,
                      disabledColor: Colors.grey,
                      onPressed: dis || (noOfLatLongs == 1 && index == 0)
                          ? null
                          : () {
                              setState(() {
                                noOfLatLongs -= 1;
                                latCont.removeAt(index);
                                longCont.removeAt(index);
                              });
                            },
                    ) */
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TableFieldBox extends StatefulWidget {
  String data;
  final Function saveData;
  Key key;
  TableFieldBox(
      {@required this.data, @required this.disabled, @required this.saveData}) {
    key = new Key(this.hashCode.toString());
  }
  final bool disabled;

  @override
  _TableFieldBoxState createState() => _TableFieldBoxState();
}

class _TableFieldBoxState extends State<TableFieldBox> {
  TextEditingController controller;
  bool csvAdded = false;
  @override
  void initState() {
    super.initState();
    controller = new TextEditingController();
    if (widget.data != null) {
      controller.text = json.decode(widget.data)['table'];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool dis = widget.disabled;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 1.0,
            offset: Offset(0, 2.5),
            color: Colors.grey[300],
          ),
          BoxShadow(
            blurRadius: 0.1,
            offset: Offset(0, -0.5),
            color: Colors.grey[300],
          )
        ],
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: TextFormField(
              controller: controller,
              validator: (s) {
                return s == "" ? 'Enter Table data' : null;
              },
              onSaved: (s) {
                widget.saveData(json.encode({"table": s}));
              },
              style: Theme.of(context)
                  .textTheme
                  .headline2
                  .copyWith(color: dis ? Colors.grey : Colors.black),
              cursorColor: Colors.black54,
              minLines: 3,
              maxLines: 10,
              enabled: !widget.disabled,
              decoration: InputDecoration(
                labelText: 'TABLE',
                hintText:
                    "Enter Data...", //'Separate column with \',\' and row with \';\'',
                hintStyle: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(color: Colors.grey, fontSize: 15.0),
                labelStyle: Theme.of(context).textTheme.headline1.copyWith(
                    color: dis ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0),
                contentPadding: EdgeInsets.all(12.0),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: InputBorder.none,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: RaisedButton(
              child: Text(
                csvAdded ? "Clear" : "Upload CSV",
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(color: Colors.white),
              ),
              color: Color(0xff01c8b5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: dis
                  ? null
                  : csvAdded
                      ? () {
                          controller.clear();
                          csvAdded = false;
                          setState(() {});
                        }
                      : () async {
                          var file = await FilePicker.getFile();
                          if (file != null && file.path.endsWith("csv")) {
                            final input = file.openRead();
                            final fields = await input
                                .transform(utf8.decoder)
                                .transform(new CsvToListConverter())
                                .toList();
                            String text = "";
                            fields.forEach((row) {
                              row.forEach((e) {
                                text += e.toString() + ",";
                              });
                              text = text.substring(0, text.length - 1);
                              text += ";";
                            });
                            text = text.substring(0, text.length - 1);
                            controller.text = text;
                            csvAdded = true;
                          }
                          setState(() {});
                        },
            ),
          ),
        ],
      ),
    );
  }
}
