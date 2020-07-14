import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:hamaraprashasan/classes.dart';
import 'package:hamaraprashasan/searchPlace.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

abstract class FormField {
  Map<String, dynamic> data = {};
  bool disabled = false;
  Key key;
  TextEditingController controller;
  void saveData(Map<String, dynamic> data) {
    this.data = data;
  }
}

class SendPostPage extends StatefulWidget {
  @override
  _SendPostPageState createState() => _SendPostPageState();
}

class _SendPostPageState extends State<SendPostPage> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int keyIndex = 1;

  List<dynamic> formFields = [];
  bool showInsertOptions = false;
  bool showTextFieldOptions = false;
  bool editing = false;

  ScrollController scrollController;

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  bool validateForm() {
    final FormState form = _formKey.currentState;
    bool textFieldsValid = form.validate();
    bool pictureFieldsValid = formFields
        .where((field) => field.runtimeType == PictureUploadBox)
        .every((picture) => (picture as PictureUploadBox).validate());
    bool tableFieldsValid = formFields
        .where((field) => field.runtimeType == TableFieldBox)
        .every((picture) => (picture as TableFieldBox).validate());
    return textFieldsValid && pictureFieldsValid && tableFieldsValid;
  }

  void _sendPost() async {
    final FormState form = _formKey.currentState;
    if (!validateForm()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save();
      List<Map<String, dynamic>> details = [];
      for (int i = 2; i < formFields.length; i++) {
        details.add(formFields[i].data);
      }
      _showSendConfirmationDialog(details);
    }
  }

  void _showSendConfirmationDialog(List<Map<String, dynamic>> details) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text("Proceed to post this feed?"),
        actions: [
          FlatButton(
            onPressed: () {
              print(details);
              DocumentReference feedRef =
                  Firestore.instance.collection("feeds").document();
              feedRef.setData({
                "feedId": feedRef.documentID,
                "creationDateTimeStamp": DateTime.now(),
                "departmentUid": User.userData.email,
                "description": details[1]["content"],
                "title": details[0]["title"],
              }).then((value) {
                print("Uploaded Feed Info");
              });
              feedRef
                  .collection("feedInfoDetails")
                  .add({"details": details}).then((value) {
                print("Uploaded Feed Info Details");
              });
              for (var field in formFields) {
                if (field.runtimeType == PictureUploadBox) {
                  PictureUploadBox pic = field;
                  pic.feedPosted = true;
                }
              }
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            },
            child: Text("Confirm"),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void startPreview() {
    final FormState form = _formKey.currentState;
    if (!validateForm()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save();
      List<Map<String, dynamic>> details = [];
      String title = formFields[0].data['title'],
          description = formFields[1].data['content'];
      for (int i = 2; i < formFields.length; i++) {
        details.add(formFields[i].data);
      }
      Feed f = new Feed(
        feedInfo: FeedInfo(
          departmentUid: User.authUser.uid,
          description: description,
          creationDateTimeStamp: DateTime.now(),
          title: title,
        ),
        department: Department(
          areaOfAdministration: 'adnsd', //TODO yet to be determined
          category: "health",
          email: User.authUser.email,
          name: User.authUser.displayName,
          userType: 'department',
        ),
        feedInfoDetails: FeedInfoDetails(
          details: details,
        ),
      );
      if (!FocusScope.of(context).hasPrimaryFocus)
        FocusScope.of(context).unfocus();
      Navigator.of(context).pushNamed("/feedInfo", arguments: f);
    }
  }

  void editForm() {
    var form = _formKey.currentState;
    if (form != null) form.save();
    if (editing) {
      for (int i = 0; i < formFields.length; i++) {
        formFields[i].disabled = false;
      }
      editing = false;
    } else {
      showMessage(
          "Long Press a field to Reorder\nSwipe Right to remove the field",
          Colors.green);
      for (int i = 0; i < formFields.length; i++) {
        formFields[i].disabled = true;
      }
      editing = true;
    }
    setState(() {});
  }

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

  @override
  void initState() {
    scrollController = new ScrollController();
    formFields.add(TitleFieldBox());
    formFields.add(ContentFieldBox());
    super.initState();
  }

  void gotoBottom() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
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
          FlatButton(
            onPressed: editing ? null : startPreview,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Center(
                child: Text(
                  'PREVIEW',
                  style: Theme.of(context).textTheme.headline2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: editing ? Colors.grey : Colors.black),
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
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              for (var f in formFields) {
                if (f.runtimeType == PictureUploadBox) {
                  PictureUploadBox pic = f;
                  pic.deleteImage(pic.data['pictureUrl']);
                }
              }
              Navigator.pop(context);
            }),
      ),
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
      body: Opacity(
        opacity: showInsertOptions ? 0.2 : 1,
        child: AbsorbPointer(
          absorbing: showInsertOptions,
          child: Form(
            key: _formKey,
            child: editing
                ? Scrollbar(
                    controller: scrollController,
                    child: ReorderableListView(
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
                          if (index < 2)
                            return field;
                          else
                            return Dismissible(
                              key: new Key(
                                  formFields[index].hashCode.toString()),
                              onDismissed: (dir) async {
                                if (formFields[index].runtimeType ==
                                    PictureUploadBox) {
                                  PictureUploadBox pic = formFields[index];
                                  pic.deleteImage(pic.data['pictureUrl']);
                                }
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
                              child: field,
                            );
                        },
                      ),
                    ),
                  )
                : /* ListView(
                    physics: BouncingScrollPhysics(),
                    addAutomaticKeepAlives: true,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                        semanticChildCount: 10,
                    controller: scrollController,
                    children: List<Widget>.generate(
                          formFields.length,
                          (index) {
                            var field = formFields[index];
                            return field;
                          },
                        ) +
                        <Widget>[SizedBox(height: 150)],
                  ), */
                Scrollbar(
                    controller: scrollController,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: List<Widget>.generate(
                              formFields.length,
                              (index) {
                                var field = formFields[index];
                                return field;
                              },
                            ) +
                            <Widget>[SizedBox(height: 150)],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class TitleFieldBox extends StatefulWidget with FormField {
  TitleFieldBox() {
    key = new Key(this.hashCode.toString());
    controller = new TextEditingController();
  }

  @override
  _TitleFieldBoxState createState() => _TitleFieldBoxState();
}

class _TitleFieldBoxState extends State<TitleFieldBox> {
  @override
  void dispose() {
    print("${widget.runtimeType} disposed");
    super.dispose();
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
        controller: widget.controller,
        validator: (s) {
          return s == "" ? 'Enter a Title' : null;
        },
        onSaved: (s) {
          widget.saveData({"title": s});
        },
        style: Theme.of(context)
            .textTheme
            .headline2
            .copyWith(color: dis ? Colors.grey : Colors.black),
        cursorColor: Colors.black54,
        minLines: 1,
        maxLines: 3,
        maxLength: 150,
        maxLengthEnforced: true,
        enabled: !dis,
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

class ContentFieldBox extends StatefulWidget with FormField {
  Key key;
  ContentFieldBox() {
    key = new Key(this.hashCode.toString());
    controller = new TextEditingController();
  }

  @override
  _ContentFieldBoxState createState() => _ContentFieldBoxState();
}

class _ContentFieldBoxState extends State<ContentFieldBox> {
  @override
  void dispose() {
    print("${widget.runtimeType} disposed");
    super.dispose();
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
        controller: widget.controller,
        validator: (s) {
          return s == "" ? 'Enter some content' : null;
        },
        onSaved: (s) {
          widget.saveData({"content": s});
        },
        style: Theme.of(context)
            .textTheme
            .headline2
            .copyWith(color: dis ? Colors.grey : Colors.black),
        cursorColor: Colors.black54,
        minLines: 3,
        maxLines: 10,
        maxLength: 1000,
        maxLengthEnforced: true,
        keyboardType: TextInputType.text,
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
              fontWeight: FontWeight.w800,
              fontSize: 15.0),
          contentPadding: EdgeInsets.all(12.0),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class PictureUploadBox extends StatefulWidget with FormField {
  Key key;
  ValueNotifier<bool> valid = ValueNotifier(true);
  bool _feedPosted = false;
  String errorMessage;
  set feedPosted(bool val) {
    this._feedPosted = val;
  }

  bool validate() {
    if (controller.value.text.isEmpty) {
      errorMessage = "Upload a Picture";
      valid.value = false;
    }
    return valid.value;
  }

  Future<void> deleteImage(String url) async {
    print(url);
    if (url != null) {
      try {
        var imageRef = await FirebaseStorage.instance.getReferenceFromUrl(url);
        print("IMage ref: $imageRef");
        await imageRef.delete().then((_) {
          print("Image deleted");
        });
      } catch (e) {
        print("Error ${e.code}  Image under the url does not exists");
      }
    }
  }

  PictureUploadBox() {
    key = new Key(this.hashCode.toString());
    controller = new TextEditingController();
  }

  @override
  _PictureUploadBoxState createState() => _PictureUploadBoxState();
}

class _PictureUploadBoxState extends State<PictureUploadBox> {
  File image;
  bool uploading = false;
  /* @override
  void dispose() {
    if (!widget._feedPosted) widget.deleteImage(widget.data['pictureUrl']);
    print("${widget.runtimeType} disposed");
    super.dispose();
  }
 */
  @override
  void initState() {
    super.initState();
    if (widget.controller.value.text.isNotEmpty) {
      image = File(widget.controller.value.text);
    }
  }

  Future<String> uploadImage(File image) async {
    if (await image.exists()) {
      String ext = image.path.split(".").last;
      String path = DateTime.now().toIso8601String() + "." + ext;
      final data = await image.readAsBytes();
      final uploadTask =
          FirebaseStorage.instance.ref().child(path).putData(data);
      final taskSp = await uploadTask.onComplete;
      final url = await taskSp.ref.getDownloadURL();

      return uploadTask.isSuccessful ? url : null;
    }
    return null;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
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
                    child: uploading
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
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
                            var file = await ImagePicker.pickImage(
                                source: ImageSource.gallery);
                            if (file != null) {
                              var fileStats = await file.stat();
                              String ext = file.path.split(".").last;
                              if (fileStats.size / (1000000) > 3) {
                                widget.errorMessage =
                                    "Maximum picture size should be 3MB";
                                widget.valid.value = false;
                              } else if (imageFormats.contains(ext)) {
                                widget.errorMessage =
                                    "Picture format not valid";
                                widget.valid.value = false;
                              } else {
                                if (file.path != image.path) {
                                  setState(() {
                                    uploading = true;
                                  });
                                  String url = await uploadImage(file);
                                  if (url != null) {
                                    await widget
                                        .deleteImage(widget.data['pictureUrl']);
                                    image = file;
                                    setState(() {});
                                    widget.saveData({'pictureUrl': url});
                                    widget.controller.text = image.path;
                                    widget.valid.value = true;
                                  }
                                  setState(() {
                                    uploading = false;
                                  });
                                }
                              }
                            }
                          },
                  )
                : RaisedButton(
                    child: uploading
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
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
                            var file = await ImagePicker.pickImage(
                                source: ImageSource.gallery);
                            if (file != null) {
                              var fileStats = await file.stat();
                              if (fileStats.size / (1000000) <= 3) {
                                setState(() {
                                  uploading = true;
                                });
                                String url = await uploadImage(file);
                                if (url != null) {
                                  image = file;
                                  setState(() {});
                                  widget.saveData({'pictureUrl': url});
                                  widget.controller.text = image.path;
                                  widget.valid.value = true;
                                }
                                setState(() {
                                  uploading = false;
                                });
                              } else {
                                widget.errorMessage =
                                    "Maximum picture size should be 3MB";
                                widget.valid.value = false;
                              }
                            }
                          },
                  ),
          ),
          ValueListenableBuilder(
              valueListenable: widget.valid,
              builder: (context, valid, child) {
                if (valid)
                  return SizedBox();
                else
                  return Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      widget.errorMessage,
                      textAlign: TextAlign.left,
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          .copyWith(color: Colors.red),
                    ),
                  );
              }),
        ],
      ),
    );
  }
}

class MapFieldBox extends StatefulWidget with FormField {
  Key key;
  MapFieldBox() {
    key = new Key(this.hashCode.toString());
    controller = new TextEditingController();
  }

  bool searchOptions = false;

  int noOfLatLongs = 1;
  List<dynamic> latLongs = [];
  List<TextEditingController> latCont = [TextEditingController()],
      longCont = [TextEditingController()],
      labelCont = [TextEditingController()];

  @override
  _MapFieldBoxState createState() => _MapFieldBoxState();
}

class _MapFieldBoxState extends State<MapFieldBox> {
  bool searchOptions;

  int noOfLatLongs;
  List<dynamic> latLongs;
  List<TextEditingController> latCont, longCont, labelCont;

  @override
  void initState() {
    super.initState();
    this.searchOptions = widget.searchOptions;
    this.noOfLatLongs = widget.noOfLatLongs;
    this.latLongs = widget.latLongs;
    this.latCont = widget.latCont;
    this.longCont = widget.longCont;
    this.labelCont = widget.labelCont;
  }

  void saveMapData() {
    if (latLongs.length > 0) widget.saveData({'coords': latLongs});
  }

  @override
  void dispose() {
    widget.searchOptions = this.searchOptions;
    widget.noOfLatLongs = this.noOfLatLongs;
    widget.latLongs = this.latLongs;
    widget.latCont = this.latCont;
    widget.longCont = this.longCont;
    widget.labelCont = this.labelCont;
    print("${widget.runtimeType} disposed");
    super.dispose();
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
                if (noOfLatLongs == 1 || dis)
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
                              if (s == "") return 'Enter Latitude';
                              try {
                                double.parse(s);
                              } catch (e) {
                                return "Not Valid";
                              }
                              return null;
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
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(
                                    color: dis
                                        ? Colors.grey[300]
                                        : Color(0xff8baee6)),
                            enabled: !widget.disabled,
                            enableInteractiveSelection: false,
                            cursorColor: Color(0xff8baee6),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hoverColor: Colors.amber,
                              labelText: 'Latitude',
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(
                                      color: dis
                                          ? Colors.grey
                                          : Color(0xff8baee6)),
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
                              if (s == "") return 'Enter Latitude';
                              try {
                                double.parse(s);
                              } catch (e) {
                                return "Not Valid";
                              }
                              return null;
                            },
                            onSaved: (s) {
                              if (s.length != 0)
                                latLongs.insert(index * 3 + 1, double.parse(s));
                              else
                                latLongs.insert(index * 3 + 1, null);
                            },
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(
                                    color: dis
                                        ? Colors.grey[300]
                                        : Color(0xff81c39f)),
                            enabled: !widget.disabled,
                            keyboardType: TextInputType.number,
                            enableInteractiveSelection: false,
                            cursorColor: Color(0xff81c39f),
                            decoration: InputDecoration(
                              labelText: 'Longitude',
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(
                                      color: dis
                                          ? Colors.grey
                                          : Color(0xff81c39f)),
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
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(
                                    color: dis
                                        ? Colors.grey[300]
                                        : Color(0xfff3d081)),
                            enabled: !widget.disabled,
                            enableInteractiveSelection: false,
                            cursorColor: Color(0xfff3d081),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hoverColor: Colors.amber,
                              labelText: 'Label',
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(
                                      color: dis
                                          ? Colors.grey
                                          : Color(0xfff3d081)),
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
                    ],
                  );
                else
                  return Dismissible(
                    key: new Key(latCont[index].hashCode.toString()),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (dir) {
                      setState(() {
                        noOfLatLongs -= 1;
                        latCont.removeAt(index);
                        longCont.removeAt(index);
                        labelCont.removeAt(index);
                      });
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Row(
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
                                if (s == "") return 'Enter Latitude';
                                try {
                                  double.parse(s);
                                } catch (e) {
                                  return "Not Valid";
                                }
                                return null;
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
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(
                                      color: dis
                                          ? Colors.grey[300]
                                          : Color(0xff8baee6)),
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
                                        color: dis
                                            ? Colors.grey
                                            : Color(0xff8baee6)),
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
                                if (s == "") return 'Enter Latitude';
                                try {
                                  double.parse(s);
                                } catch (e) {
                                  return "Not Valid";
                                }
                                return null;
                              },
                              onSaved: (s) {
                                if (s.length != 0)
                                  latLongs.insert(
                                      index * 3 + 1, double.parse(s));
                                else
                                  latLongs.insert(index * 3 + 1, null);
                              },
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(
                                      color: dis
                                          ? Colors.grey[300]
                                          : Color(0xff81c39f)),
                              enabled: !widget.disabled,
                              keyboardType: TextInputType.number,
                              enableInteractiveSelection: false,
                              decoration: InputDecoration(
                                labelText: 'Longitude',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(
                                        color: dis
                                            ? Colors.grey
                                            : Color(0xff81c39f)),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(
                                      color: dis
                                          ? Colors.grey[300]
                                          : Color(0xfff3d081)),
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
                                        color: dis
                                            ? Colors.grey
                                            : Color(0xfff3d081)),
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
                      ],
                    ),
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TableFieldBox extends StatefulWidget with FormField {
  bool csvAdded = false;
  ValueNotifier<bool> valid = ValueNotifier(true);
  String errorMessage;

  bool validate() {
    if (controller.text.isNotEmpty) {
      var rows = MyCsvParser.parser(controller.text);
      int headersLength = rows[0].length;
      List<int> notEqualCols = [];
      for (int i = 1; i < rows.length; i++) {
        if (rows[i].length != headersLength) notEqualCols.add(i);
      }
      valid.value = notEqualCols.length == 0;
      if (!valid.value) {
        errorMessage = "Number of columns not equal in rows:";
        for (int i = 0; i < notEqualCols.length; i++) {
          errorMessage += " ${notEqualCols[i]},";
          if (i >= 4) {
            errorMessage =
                errorMessage.substring(0, errorMessage.length - 1) + "......";
            break;
          }
        }
        errorMessage = errorMessage.substring(0, errorMessage.length - 1);
        int f = notEqualCols.first;
        int start =
                rows.sublist(0, f).map((e) => e.join()).join().length + 2 * (f),
            end = rows.sublist(0, f + 1).map((e) => e.join()).join().length +
                2 * (f + 1);
        controller.selection =
            TextSelection.collapsed(offset: ((start + end) / 2).floor());
        TextSelection(baseOffset: start, extentOffset: end);
      }
    } else {
      valid.value = false;
    }
    return valid.value;
  }

  TableFieldBox() {
    key = new Key(this.hashCode.toString());
    controller = new TextEditingController();
  }

  @override
  _TableFieldBoxState createState() => _TableFieldBoxState();
}

class _TableFieldBoxState extends State<TableFieldBox> {
  String colDelemiter = ";", rowDelemiter = "\n";
  @override
  void dispose() {
    print("${widget.runtimeType} disposed");
    super.dispose();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: widget.valid,
            builder: (context, valid, child) {
              return Container(
                child: TextFormField(
                  controller: widget.controller,
                  validator: (s) {
                    widget.valid.value = s.isNotEmpty;
                    if (!widget.valid.value) {
                      widget.errorMessage = "Enter Table data";
                      print(widget.valid);
                    }
                    return null;
                  },
                  onSaved: (s) {
                    widget.saveData({"table": s});
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
                    //errorText: valid ? null : widget.errorMessage,
                    labelText: 'TABLE',
                    hintText:
                        'Separate column with a \'$colDelemiter\' and a row with a line break', //'Separate column with \',\' and row with \';\'',
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
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: RaisedButton(
              child: Text(
                widget.csvAdded ? "Clear" : "Upload CSV",
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
                  : widget.csvAdded
                      ? () {
                          widget.controller.clear();
                          widget.csvAdded = false;
                          widget.valid.value = true;
                          setState(() {});
                        }
                      : () async {
                          var file = await FilePicker.getFile();
                          if (file != null) {
                            var fileStats = await file.stat();
                            String ext = file.path.split(".").last;
                            if (fileStats.size / 1000000 > 1) {
                              widget.errorMessage =
                                  "Maximum CSV file size should be 1MB";
                              widget.valid.value = false;
                            } else if (ext != "csv") {
                              widget.errorMessage =
                                  "Format of file should be csv";
                              widget.valid.value = false;
                            } else {
                              final input = file.openRead();
                              final fields = await input
                                  .transform(utf8.decoder)
                                  .transform(new CsvToListConverter())
                                  .toList();
                              String text = "";
                              fields.forEach((row) {
                                row.forEach((e) {
                                  text += e.toString() + colDelemiter;
                                });
                                text = text.substring(0, text.length - 1);
                                text += rowDelemiter;
                              });
                              text = text.substring(0, text.length - 1);
                              widget.controller.text = text;
                              widget.csvAdded = true;
                              widget.valid.value = true;
                            }
                          }
                          setState(() {});
                        },
            ),
          ),
          ValueListenableBuilder(
              valueListenable: widget.valid,
              builder: (context, valid, child) {
                if (valid)
                  return SizedBox();
                else
                  return Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      widget.errorMessage,
                      textAlign: TextAlign.left,
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          .copyWith(color: Colors.red),
                    ),
                  );
              }),
        ],
      ),
    );
  }
}
