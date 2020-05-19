import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamaraprashasan/feedClasses.dart';
import 'package:hamaraprashasan/feedInfoPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';

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

  void getFeed() async {
    var sp = await Firestore.instance
        .collection("feeds")
        .orderBy("created", descending: true)
        .getDocuments();
    sp.documents.forEach((doc) {
      var d = doc.data;
      List<dynamic> formContent = List.from(d['feed']);
      print(formContent);
      List<dynamic> contents = [];
      for (int i = 0; i < formContent.length; i++) {
        var data = json.decode(formContent[i]);
        if (data['title'] != null) {
          contents.add(
            new TitleData(title: data['title']),
          );
        } else if (data['content'] != null) {
          contents.add(
            new ContentData(text: data['content']),
          );
        } else if (data['picture'] != null) {
          contents.add(
            new ImageData(url: data['picture'], isLocal: true),
          );
        } else if (data['map'] != null) {
          List<double> latLong = List.from(data['map']),
              latitude = [],
              longitude = [];
          for (int i = 0; i < latLong.length / 2; i++) {
            latitude.add(latLong[2 * i]);
            longitude.add(latLong[2 * i + 1]);
          }
          contents.add(new MapData(
              latitude: latitude, longitude: longitude, name: null));
        } else if (data['table'] != null) {
          String d = data['table'];
          List<String> a = d.split(";"), headers = [];
          headers = a[0].split(",");
          List<List<String>> content = [];
          for (int i = 1; i < a.length; i++) {
            content.add(a[i].split(","));
          }
          contents.add(new TableData(headers: headers, contents: content));
        }
      }
      TitleData firstTitle = contents[0];
      Feed f = new Feed(
          contents: contents,
          location: new LocationData(
              city: "Surat", state: "Gujarat", country: "India"),
          time: DateTime.now(),
          department: Department(
            logoUrl: 'assets/police_avatar.svg',
            name: "Police Department",
          ),
          firstTitle: firstTitle);
      print(f);
    });
  }

  void startPreview() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save();
      List<dynamic> contents = [];
      for (int i = 0; i < formFields.length; i++) {
        var data = json.decode(formFields[i].data);
        if (data['title'] != null) {
          contents.add(
            new TitleData(title: data['title']),
          );
        } else if (data['content'] != null) {
          contents.add(
            new ContentData(text: data['content']),
          );
        } else if (data['picture'] != null) {
          contents.add(
            new ImageData(url: data['picture'], isLocal: true),
          );
        } else if (data['map'] != null) {
          List<double> latLong = List.from(data['map']),
              latitude = [],
              longitude = [];
          for (int i = 0; i < latLong.length / 2; i++) {
            latitude.add(latLong[2 * i]);
            longitude.add(latLong[2 * i + 1]);
          }
          contents.add(new MapData(
              latitude: latitude, longitude: longitude, name: null));
        } else if (data['table'] != null) {
          String d = data['table'];
          List<String> a = d.split(";"), headers = [];
          headers = a[0].split(",");
          List<List<String>> content = [];
          for (int i = 1; i < a.length; i++) {
            content.add(a[i].split(","));
          }
          contents.add(new TableData(headers: headers, contents: content));
        }
      }
      TitleData firstTitle = contents[0];
      Feed f = new Feed(
          contents: contents,
          location: new LocationData(
              city: "Surat", state: "Gujarat", country: "India"),
          time: DateTime.now(),
          department: Department(
            logoUrl: 'assets/police_avatar.svg',
            name: "Police Department",
          ),
          firstTitle: firstTitle);
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

  void removeItem(int index) async {
    formFields.removeAt(index);
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          showInsertOptions & showTextFieldOptions
              ? Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CupertinoButton(
                        child: Text(
                          'Add Title',
                          style: Theme.of(context)
                              .textTheme
                              .headline2
                              .copyWith(color: Colors.black),
                        ),
                        color: Colors.amber,
                        onPressed: () {
                          setState(() {
                            formFields
                                .add(new FormField(null, false, TitleFieldBox));
                          });
                        },
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CupertinoButton(
                        child: Text(
                          'Add Body',
                          style: Theme.of(context)
                              .textTheme
                              .headline2
                              .copyWith(color: Colors.black),
                        ),
                        color: Colors.amber,
                        onPressed: () {
                          setState(() {
                            formFields.add(
                                new FormField(null, false, ContentFieldBox));
                          });
                        },
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    )
                  ],
                )
              : SizedBox(),
          showInsertOptions //&& !showTextFieldOptions
              ? Row(
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CupertinoButton(
                        child: Icon(
                          Icons.text_fields,
                          size: 20.0,
                          color: editing ? Colors.grey : Colors.black,
                        ),
                        color: editing ? Colors.grey : Colors.amber,
                        onPressed: editing
                            ? null
                            : () {
                                setState(() {
                                  showTextFieldOptions = !showTextFieldOptions;
                                });
                              },
                        padding: EdgeInsets.all(0.0),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CupertinoButton(
                        child: Icon(
                          Icons.insert_photo,
                          size: 20.0,
                          color: editing ? Colors.grey : Colors.black,
                        ),
                        color: editing ? Colors.grey : Colors.amber,
                        onPressed: editing
                            ? null
                            : () {
                                setState(() {
                                  formFields.add(new FormField(
                                      null, false, PictureUploadBox));
                                });
                              },
                        padding: EdgeInsets.all(0.0),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CupertinoButton(
                        child: Icon(
                          Icons.map,
                          size: 20.0,
                          color: editing ? Colors.grey : Colors.black,
                        ),
                        color: editing ? Colors.grey : Colors.amber,
                        onPressed: editing
                            ? null
                            : () {
                                setState(() {
                                  formFields.add(
                                      new FormField(null, false, MapFieldBox));
                                });
                              },
                        padding: EdgeInsets.all(0.0),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CupertinoButton(
                        child: Icon(
                          Icons.table_chart,
                          size: 20.0,
                          color: editing ? Colors.grey : Colors.black,
                        ),
                        color: editing ? Colors.grey : Colors.amber,
                        onPressed: editing
                            ? null
                            : () {
                                setState(() {
                                  formFields.add(new FormField(
                                      null, false, TableFieldBox));
                                });
                              },
                        padding: EdgeInsets.all(0.0),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CupertinoButton(
                        child: Icon(
                          Icons.edit,
                          size: 20.0,
                          color: Colors.black,
                        ),
                        color: editing ? Colors.green : Colors.amber,
                        onPressed: () {
                          showTextFieldOptions = false;
                          editForm();
                        },
                        padding: EdgeInsets.all(0.0),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    Spacer(),
                  ],
                )
              : SizedBox(),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: CupertinoButton(
              child: Icon(
                showInsertOptions ? Icons.close : Icons.add,
                size: 30.0,
              ),
              color: Colors.deepOrange,
              onPressed: () {
                setState(() {
                  showInsertOptions = !showInsertOptions;
                  showTextFieldOptions = false;
                });
              },
              padding: EdgeInsets.all(0.0),
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: new List<Widget>.generate(2, (index) {
                  var field = formFields[index];
                  return fieldWidget(field);
                }) +
                <Widget>[
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        print(111);
                        oldIndex += 2;
                        newIndex += 2;
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        var f = formFields.removeAt(oldIndex);
                        formFields.insert(newIndex, f);
                        setState(() {});
                      },
                      children: List<Widget>.generate(
                        formFields.length - 2,
                        (index) {
                          index += 2;
                          var field = formFields[index];
                          {
                            if (!editing)
                              return fieldWidget(field);
                            else
                              return Dismissible(
                                key: new Key(
                                    formFields[index].hashCode.toString()),
                                onDismissed: (dir) async {
                                  formFields.removeAt(index);
                                  setState(() {});
                                },
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                child: fieldWidget(field),
                              );
                          }
                        },
                      ),
                    ),
                  ),
                ],
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
            blurRadius: 0.5,
            offset: Offset(0, 1),
            color: Colors.grey[300],
          ),
          BoxShadow(
            blurRadius: 0.5,
            offset: Offset(0, -1),
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
              fontWeight: FontWeight.w600,
              fontSize: 20.0),
          counterText: "",
          contentPadding: EdgeInsets.all(12.0),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          /* focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              style: BorderStyle.solid,
            ),
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
              color: Colors.grey,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ), */
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
      padding: EdgeInsets.symmetric(vertical: 8.0),
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
          labelText: 'Content',
          hintText: 'Write a Description',
          hintStyle: Theme.of(context).textTheme.headline2,
          labelStyle: Theme.of(context).textTheme.headline1.copyWith(
              color: dis ? Colors.grey : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 15.0),
          contentPadding: EdgeInsets.all(12.0),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              style: BorderStyle.solid,
            ),
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
              color: Colors.grey,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
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
      child: Container(
        color: dis ? Colors.grey[300] : Colors.grey[300],
        child: ListTile(
          title: image != null
              ? Image.file(
                  image,
                  fit: BoxFit.contain,
                  color: dis ? Colors.grey : Colors.transparent,
                  colorBlendMode: BlendMode.darken,
                  height: 100,
                )
              : Text(
                  'Picture',
                  style: Theme.of(context).textTheme.headline2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: dis ? Colors.grey : Colors.black),
                ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.file_upload),
                disabledColor: Colors.grey[400],
                color: Colors.grey[600],
                onPressed: dis
                    ? null
                    : () async {
                        image = await ImagePicker.pickImage(
                            source: ImageSource.gallery);
                        setState(() {});
                        widget.saveData(json.encode({'picture': image.path}));
                      },
              ),
              IconButton(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.close),
                disabledColor: Colors.grey[400],
                color: Colors.grey[600],
                onPressed: dis
                    ? null
                    : () {
                        setState(() {
                          image = null;
                        });
                      },
              )
            ],
          ),
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
  List<double> latLongs = [];
  List<TextEditingController> latCont = [TextEditingController()],
      longCont = [TextEditingController()];

  void saveMapData() {
    if (latLongs.length > 0) widget.saveData(json.encode({'map': latLongs}));
  }

  void initState() {
    super.initState();
    if (widget.data != null) {
      List<dynamic> latLong = json.decode(widget.data)['map'];
      latCont = [];
      longCont = [];
      for (int i = 0; i < latLong.length; i++) {
        if (i % 2 == 0) {
          if (latLong[i] != null)
            latCont.add(TextEditingController(text: latLong[i].toString()));
          else
            latCont.add(TextEditingController());
        } else {
          if (latLong[i] != null)
            longCont.add(TextEditingController(text: latLong[i].toString()));
          else
            longCont.add(TextEditingController());
        }
      }
      while (longCont.length < latCont.length) {
        longCont.add(TextEditingController());
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
      padding: EdgeInsets.only(bottom: 8.0),
      child: Container(
        color: Colors.grey[200],
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
                    'Map',
                    style: Theme.of(context).textTheme.headline2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: dis ? Colors.grey : Colors.black),
                  ),
                ),
                searchOptions
                    ? Align(
                        alignment: Alignment.topRight,
                        child: RawMaterialButton(
                          onPressed: () {},
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          fillColor: Colors.grey[300],
                          padding: EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 8.0),
                          child: Text(
                            'Search Place',
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                      )
                    : SizedBox(),
                searchOptions
                    ? Align(
                        alignment: Alignment.topRight,
                        child: RawMaterialButton(
                          onPressed: () {
                            noOfLatLongs += 1;
                            latCont.add(new TextEditingController());
                            longCont.add(new TextEditingController());
                            setState(() {});
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          fillColor: Colors.grey[300],
                          padding: EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 8.0),
                          child: Text(
                            'Add LatLong',
                            style: Theme.of(context).textTheme.headline1,
                          ),
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
                                searchOptions = searchOptions ? false : true;
                              });
                            },
                      icon: Icon(
                        searchOptions ? Icons.close : Icons.add_circle_outline,
                      ),
                      color: Colors.black,
                      disabledColor: Colors.grey,
                    ),
                  ),
                )
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
                              latLongs.insert(index * 2, double.parse(s));
                            else
                              latLongs.insert(index * 2, null);
                          },
                          style: Theme.of(context).textTheme.headline1.copyWith(
                              color: dis ? Colors.grey[300] : Colors.black),
                          enabled: !widget.disabled,
                          enableInteractiveSelection: false,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hoverColor: Colors.amber,
                            hintText: 'Latitude',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(
                                    color: dis ? Colors.grey : Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                style: BorderStyle.solid,
                              ),
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
                              latLongs.insert(index * 2 + 1, double.parse(s));
                            else
                              latLongs.insert(index * 2 + 1, null);
                            if (index + 1 == noOfLatLongs) {
                              saveMapData();
                            }
                          },
                          style: Theme.of(context).textTheme.headline1.copyWith(
                              color: dis ? Colors.grey[300] : Colors.black),
                          enabled: !widget.disabled,
                          keyboardType: TextInputType.number,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            hintText: 'Longitude',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(
                                    color: dis ? Colors.grey : Colors.black),
                            focusColor: Colors.red,
                            filled: true,
                            fillColor: Colors.white,
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                      ),
                      color: Colors.black,
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
                    )
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
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
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
                labelText: 'Table',
                hintText: 'Separate column with \',\' and row with \';\'',
                hintStyle: Theme.of(context).textTheme.headline2,
                labelStyle: Theme.of(context).textTheme.headline1.copyWith(
                    color: dis ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0),
                contentPadding: EdgeInsets.all(12.0),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    style: BorderStyle.solid,
                  ),
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
                    color: Colors.grey,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: FlatButton(
              padding: EdgeInsets.all(0.0),
              child: Text(
                csvAdded ? "Remove CSV" : "Upload CSV",
                style: TextStyle(
                  color: dis ? Colors.grey[400] : Colors.blue,
                  decoration: TextDecoration.underline,
                ),
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
