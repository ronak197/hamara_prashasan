import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/app_configurations/app_configurations.dart';
import 'package:algolia/algolia.dart';
import 'package:hamaraprashasan/constants/constants.dart';
import 'package:hamaraprashasan/helper_classes/user_classes/department_user_class.dart';

class DepartmentsPage extends StatefulWidget {
  @override
  _DepartmentsPageState createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  Algolia algolia;

  FocusNode searchFocusNode;
  bool isSearching = false;
  List<String> searchResults = List<String>();
  AlgoliaQuery query;
  TextEditingController searchTextEditingController = TextEditingController();

  bool showResults = false;
  List<Department> searchDepartmentsResults = List<Department>();
  List<Department> subscribedDepartments = List<Department>();
  String errorMessage = "Fetching Subscribed Departments";

  void getAvailableDepartments(String searchQuery) {
    Firestore db = Firestore.instance;
    setState(() {
      searchDepartmentsResults?.clear();
      errorMessage = "Searching";
      print(errorMessage);
    });
    db
        .collection('departments')
        .where('areaOfAdministration', isEqualTo: searchQuery)
        .getDocuments()
        .asStream()
        .listen((event) {
      setState(() {
        event.documents.forEach((snapshot) {
          searchDepartmentsResults.add(Department.fromJson(snapshot.data));
        });
      });
    })
          ..onDone(() {
            if (searchDepartmentsResults.isEmpty) {
              setState(() {
                errorMessage = 'No available departments for your search';
                print(errorMessage);
              });
            }
          })
          ..onError((e) {
            setState(() {
              errorMessage =
                  "Some unknown error occurred, Make sure you are connected proper internet connection";
              print(errorMessage);
            });
          });
  }

  void getSubscribedDepartments() async {
    Firestore db = Firestore.instance;

    setState(() {
      subscribedDepartments?.clear();
      errorMessage = "Getting subscribers";
      print(errorMessage);
    });

    db
        .collection('departments')
        .where('email', whereIn: User.userData.subscribedDepartmentIDs)
        .getDocuments()
        .asStream()
        .listen((event) {
      setState(() {
        event.documents.forEach((snapshot) {
          subscribedDepartments.add(Department.fromJson(snapshot.data));
        });
      });
    })
          ..onDone(() {
            if (subscribedDepartments.isEmpty) {
              setState(() {
                errorMessage = 'No Subscribed Departments';
                print(errorMessage);
              });
            } else {
              setState(() {
                searchDepartmentsResults = subscribedDepartments;
              });
            }
          })
          ..onError((e) {
            setState(() {
              errorMessage = "Error Occurred";
              print(errorMessage);
            });
          });
  }

  void onSubscribePressed(String toSubscribe, bool hasSubscribed) async {
    Firestore db = Firestore.instance;

    if (User.lastUserState != UserState.initial) {
      await FirebaseMethods.getFirestoreUserDataInfo();
    }
    if (!User.userData.subscribedDepartmentIDs.contains(toSubscribe)) {
      setState(() {
        User.userData.subscribedDepartmentIDs.add(toSubscribe);
        User.saveUserData(User.userData, UserState.subscription);
      });
      await db
          .collection('users')
          .document(User.authUser.uid)
          .updateData(User.userData.toFirestoreJson())
          .catchError((e) {
        setState(() {
          errorMessage = 'Error Occurred';
        });
        return null;
      });
    } else {
      setState(() {
        User.userData.subscribedDepartmentIDs.remove(toSubscribe);
        User.saveUserData(User.userData, UserState.subscription);
      });
      await db
          .collection('users')
          .document(User.authUser.uid)
          .updateData(User.userData.toFirestoreJson())
          .catchError((e) {
        setState(() {
          errorMessage = 'Error Occurred';
        });
        return null;
      });
    }
    return null;
  }

  void search(String textToSearch) async {
    print('called search');
    searchResults.clear();
    if (textToSearch.isNotEmpty) {
      query = query.search(textToSearch);
      List<String> results = List<String>();
      (await query.getObjects()).hits.forEach((element) {
        if (searchResults.length < 5) {
          results.add(element.data['areaOfAdministration']);
        }
      });
      setState(() {
        searchResults.addAll(results);
      });
    }
  }

  void onPlaceSelected(String place) async {
    setState(() {
      isSearching = false;
    });
    if (place.isNotEmpty) {
      getAvailableDepartments(place.toLowerCase().trim());
    }
  }

  void setupAlgolia() async {
    algolia = Algolia.init(
        applicationId: "EV6Y9JFNMN",
        apiKey: "84f5028a9a96b956051ec63b38e0399d");
    query = algolia.instance.index('departments_prod').setHitsPerPage(5);
  }

  Future<void> onRefresh() async {
    searchTextEditingController.clear();
    searchFocusNode.unfocus();
    setState(() {
      getSubscribedDepartments();
    });
  }

  @override
  void initState() {
    searchFocusNode = FocusNode();
    setupAlgolia();
    searchTextEditingController.addListener(() {
      search(searchTextEditingController.text);
    });
    getSubscribedDepartments();
    super.initState();
  }

  @override
  void dispose() {
    searchTextEditingController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        excludeHeaderSemantics: true,
        titleSpacing: 0.0,
        leading: GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Container(
            margin: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipOval(
              child: User.authUser.localPhotoLoc != null
                  ? Image.file(
                      File(User.authUser.localPhotoLoc),
                      fit: BoxFit.contain,
                    )
                  : CachedNetworkImage(
                      imageUrl: User.authUser.photoUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, s) {
                        return Container(color: Colors.white);
                      },
                    ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                child: TextField(
                  onTap: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                  onEditingComplete: () {
                    print('completed');
                    onPlaceSelected(searchTextEditingController.text);
                  },
                  onSubmitted: (s) {
                    searchFocusNode.unfocus();
                    print('submit');
                  },
                  controller: searchTextEditingController,
                  cursorColor: Colors.black,
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .copyWith(color: Color(0xff514A4A)),
                  focusNode: searchFocusNode,
                  autofocus: false,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(0.0),
                    isDense: true,
                    hintText: 'Search City, State or Department',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .headline1
                        .copyWith(color: Color(0xff5f5f5f)),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(isSearching ? Icons.close : Icons.search),
                color: Colors.black54,
                onPressed: () {
                  if (isSearching) {
                    searchFocusNode.unfocus();
                  } else {
                    searchFocusNode.requestFocus();
                  }
                  setState(() {
                    isSearching = !isSearching;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: isSearching && searchResults?.length != 0
          ? ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => onPlaceSelected(searchResults[index]),
                  highlightColor: Colors.orange[100],
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical:
                                BorderSide(color: Colors.grey, width: 0.2))),
                    child: Text(
                      searchResults[index],
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          .copyWith(color: Color(0xff6f6f6f)),
                    ),
                  ),
                );
              },
            )
          : GestureDetector(
              onTap: () {
                if (searchFocusNode.hasFocus) {
                  searchFocusNode.unfocus();
                  setState(() {
                    isSearching = false;
                  });
                }
              },
              child: RefreshIndicator(
                onRefresh: onRefresh,
                strokeWidth: 2.5,
                child: searchDepartmentsResults.isNotEmpty
                    ? ListView.builder(
                        itemCount: searchDepartmentsResults?.length,
                        itemBuilder: (context, index) {
                          Department department =
                              searchDepartmentsResults[index];
                          bool hasSubscribed =
                              (User.userData.subscribedDepartmentIDs ?? [])
                                      .contains(department.email) ??
                                  false;
                          return DepartmentsMessageBox(
                            subscribed: hasSubscribed,
                            department: department,
                            onSubscribePressed: () => onSubscribePressed(
                                searchDepartmentsResults[index].email,
                                hasSubscribed),
                          );
                        },
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: constraints.maxHeight,
                              child: Center(
                                child: Text(errorMessage),
                              ),
                            ),
                          );
                        },
                      ),
              )),
    );
  }
}

class DepartmentsMessageBox extends StatelessWidget {
  final Department department;
  final bool subscribed;
  final Function onSubscribePressed;

  DepartmentsMessageBox(
      {this.department, this.subscribed, this.onSubscribePressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        color: Color(avatarColorMap.containsKey(department.category)
            ? avatarColorMap[department.category]
            : avatarColorMap['department']),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            child: SvgPicture.asset(
              avatarLocMap.containsKey(department.category)
                  ? avatarLocMap[department.category]
                  : avatarLocMap['department'],
              height: 60.0,
              width: 60.0,
              fit: BoxFit.contain,
              placeholderBuilder: (context) {
                return Container(
                  width: 64.0,
                  height: 64.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xfff7f7f7)]),
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
                  Text(
                    department.name,
                    style: Theme.of(context).textTheme.headline2.copyWith(
                        color: Color(0xff514A4A), fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            department.areaOfAdministration,
                            style:
                                Theme.of(context).textTheme.headline1.copyWith(
                                      color: Color(0xff514A4A),
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 1.0),
                            decoration: BoxDecoration(
                              color: Color(categoryTagColorMap
                                      .containsKey(department.category)
                                  ? categoryTagColorMap[department.category]
                                  : categoryTagColorMap['department']),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              department.category,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subscribed
                          ? RawMaterialButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              fillColor: Colors.orange,
                              splashColor: Colors.red,
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: RichText(
                                softWrap: true,
                                text: TextSpan(children: [
                                  WidgetSpan(
                                      child: Container(
                                        child: Icon(
                                          Icons.done,
                                          size: 17.0,
                                          color: Colors.white,
                                        ),
                                        margin: EdgeInsets.only(right: 3.0),
                                      ),
                                      alignment: PlaceholderAlignment.middle),
                                  TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1
                                          .copyWith(color: Colors.white),
                                      text: 'Subscribed'),
                                ]),
                              ),
                              onPressed: onSubscribePressed,
                            )
                          : RawMaterialButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              fillColor: Colors.orange,
                              splashColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Text(
                                'Subscribe',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(color: Colors.white),
                              ),
                              elevation: 0.0,
                              onPressed: onSubscribePressed,
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
