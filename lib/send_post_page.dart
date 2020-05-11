import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamaraprashasan/feedClasses.dart';
import 'package:hamaraprashasan/feedInfoPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendPostPage extends StatefulWidget {
  @override
  _SendPostPageState createState() => _SendPostPageState();
}

class _SendPostPageState extends State<SendPostPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int keyIndex = 1;

  List<dynamic> formFields = [];
  bool showInsertOptions = false;
  bool showTextFieldOptions = false;

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
      //await Firestore.instance.collection("feeds").add({"feed": formContent});
    }
  }

  void getFeed() async {
    var sp = await Firestore.instance.collection("feeds").getDocuments();
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
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 2.0),
            ),
            padding: EdgeInsets.all(5),
            child: FeedInfoPage(feed: f),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    formFields.add(TitleFieldBox());
    formFields.add(ContentFieldBox());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        primary: true,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: formFields.length,
                      itemBuilder: (_, index) {
                        return formFields[index];
                      },
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
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
                          showInsertOptions && !showTextFieldOptions
                              ? Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: CupertinoButton(
                                        child: Icon(
                                          Icons.text_fields,
                                          size: 20.0,
                                          color: Colors.black,
                                        ),
                                        color: Colors.amber,
                                        onPressed: () {
                                          setState(() {
                                            showTextFieldOptions = true;
                                          });
                                        },
                                        padding: EdgeInsets.all(0.0),
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: CupertinoButton(
                                        child: Icon(
                                          Icons.insert_photo,
                                          size: 20.0,
                                          color: Colors.black,
                                        ),
                                        color: Colors.amber,
                                        onPressed: () {
                                          setState(() {
                                            formFields.add(PictureUploadBox());
                                          });
                                        },
                                        padding: EdgeInsets.all(0.0),
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: CupertinoButton(
                                        child: Icon(
                                          Icons.map,
                                          size: 20.0,
                                          color: Colors.black,
                                        ),
                                        color: Colors.amber,
                                        onPressed: () {
                                          setState(() {
                                            formFields.add(MapFieldBox());
                                          });
                                        },
                                        padding: EdgeInsets.all(0.0),
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: CupertinoButton(
                                        child: Icon(
                                          Icons.table_chart,
                                          size: 20.0,
                                          color: Colors.black,
                                        ),
                                        color: Colors.amber,
                                        onPressed: () {
                                          setState(() {
                                            formFields.add(TableFieldBox());
                                          });
                                        },
                                        padding: EdgeInsets.all(0.0),
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
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
                                            formFields.add(TitleFieldBox());
                                          });
                                        },
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
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
                                            formFields.add(ContentFieldBox());
                                          });
                                        },
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                    )
                                  ],
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PictureUploadBox extends StatefulWidget {
  String data;

  @override
  _PictureUploadBoxState createState() => _PictureUploadBoxState();
}

class _PictureUploadBoxState extends State<PictureUploadBox> {
  File image;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.grey[300],
      child: ListTile(
        title: image != null
            ? Image.file(
                image,
                fit: BoxFit.contain,
              )
            : Text(
                'Picture',
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(fontWeight: FontWeight.w600),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.file_upload),
              onPressed: () async {
                image =
                    await ImagePicker.pickImage(source: ImageSource.gallery);
                setState(() {});
                widget.data = json.encode({'picture': image.path});
              },
            ),
            IconButton(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.close),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}

class ContentFieldBox extends StatefulWidget {
  String data;

  @override
  _ContentFieldBoxState createState() => _ContentFieldBoxState();
}

class _ContentFieldBoxState extends State<ContentFieldBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        validator: (s) {
          return s == "" ? 'Enter some content' : null;
        },
        onSaved: (s) {
          widget.data = json.encode({"content": s});
        },
        style: Theme.of(context).textTheme.headline2,
        cursorColor: Colors.black54,
        minLines: 3,
        maxLines: null,
        maxLength: 600,
        maxLengthEnforced: true,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: 'Content',
          hintText: 'Write a Description',
          hintStyle: Theme.of(context).textTheme.headline2,
          labelStyle: Theme.of(context).textTheme.headline1.copyWith(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15.0),
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

class MapFieldBox extends StatefulWidget {
  String data;

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
    widget.data = json.encode({'map': latLongs});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.only(bottom: 8.0),
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
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              searchOptions
                  ? Align(
                      alignment: Alignment.topRight,
                      child: RawMaterialButton(
                        onPressed: () {
                          saveMapData();
                        },
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
                    onPressed: () {
                      setState(() {
                        searchOptions = searchOptions ? false : true;
                      });
                    },
                    icon: Icon(
                      searchOptions ? Icons.close : Icons.add_circle_outline,
                      color: Colors.black,
                    ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                      child: TextFormField(
                        controller: latCont[index],
                        validator: (s) {
                          return s == "" ? 'Enter Latitude' : null;
                        },
                        onSaved: (s) {
                          if (index == 0) {
                            latLongs = [];
                          }
                          latLongs.insert(index * 2, double.parse(s));
                        },
                        enableInteractiveSelection: false,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hoverColor: Colors.amber,
                          hintText: 'Latitude',
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                      child: TextFormField(
                        controller: longCont[index],
                        validator: (s) {
                          return s == "" ? 'Enter Longitude' : null;
                        },
                        onSaved: (s) {
                          latLongs.insert(index * 2 + 1, double.parse(s));
                          if (index + 1 == noOfLatLongs) {
                            saveMapData();
                          }
                        },
                        keyboardType: TextInputType.number,
                        enableInteractiveSelection: false,
                        decoration: InputDecoration(
                          hintText: 'Longitude',
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
                      color: index == 0 ? Colors.grey[300] : Colors.black,
                    ),
                    onPressed: index == 0
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
    );
  }
}

class TableFieldBox extends StatefulWidget {
  String data;

  @override
  _TableFieldBoxState createState() => _TableFieldBoxState();
}

class _TableFieldBoxState extends State<TableFieldBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        validator: (s) {
          return s == "" ? 'Enter Table data' : null;
        },
        onSaved: (s) {
          widget.data = json.encode({"table": s});
        },
        style: Theme.of(context).textTheme.headline2,
        cursorColor: Colors.black54,
        minLines: 3,
        maxLines: null,
        maxLength: 1000,
        maxLengthEnforced: false,
        decoration: InputDecoration(
          labelText: 'Table',
          hintText: 'Separate column with \',\' and row with \';\'',
          hintStyle: Theme.of(context).textTheme.headline2,
          labelStyle: Theme.of(context).textTheme.headline1.copyWith(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15.0),
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

class TitleFieldBox extends StatefulWidget {
  String data;

  @override
  _TitleFieldBoxState createState() => _TitleFieldBoxState();
}

class _TitleFieldBoxState extends State<TitleFieldBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              validator: (s) {
                return s == "" ? 'Enter a Title' : null;
              },
              onSaved: (s) {
                widget.data = json.encode({"title": s});
              },
              style: Theme.of(context).textTheme.headline2,
              cursorColor: Colors.black54,
              minLines: 1,
              maxLines: null,
              maxLength: 100,
              maxLengthEnforced: true,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Write a title',
                hintStyle: Theme.of(context).textTheme.headline2,
                labelStyle: Theme.of(context).textTheme.headline1.copyWith(
                    color: Colors.black,
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
        ),
        Container(
          width: 25.0,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(0.0),
                child: RawMaterialButton(
                  onPressed: () {},
                  padding: EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.arrow_drop_up,
                    size: 22.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(0.0),
                child: RawMaterialButton(
                  onPressed: () {},
                  padding: EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 22.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
