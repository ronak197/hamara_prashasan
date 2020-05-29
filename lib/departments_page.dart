import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:hamaraprashasan/classes.dart';
import 'package:algolia/algolia.dart';

class DepartmentsPage extends StatefulWidget {
  @override
  _DepartmentsPageState createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {

  Algolia algolia;

  bool isSearching = false;
  List<String> searchResults = List<String>();
  AlgoliaQuery query;
  TextEditingController textEditingController = TextEditingController();

  bool showResults = false;
  List<Department> results = List<Department>();
  String message = "Fetching Subscribed Departments";

  void getAvailableDepartments(String searchQuery){
    Firestore db = Firestore.instance;
    results.clear();
    setState(() {
      message = "Fetching";
    });
    db.collection('departments')
        .where('areaOfAdministration', isEqualTo: searchQuery).getDocuments().asStream()
        .listen((event) {
          setState(() {
            event.documents.forEach((snapshot) { results.add(Department.fromJson(snapshot.data)); });
          });
        })..onDone(() {
      setState(() {
        message = results.isEmpty ? 'No Available Departments' : '';
        print(message);
      });
    })..onError((e){
      setState(() {
        message = "Error Occurred";
        print(message);
      });
    });
  }

  void getSubscribedDepartments() async{
    Firestore db = Firestore.instance;
    results?.clear();
    if(User.lastUserState == UserState.initial){
       db.collection('departments')
           .where('email', whereIn: User.userData.subscribedDepartmentIDs).getDocuments().asStream()
           .listen((event) {
             setState(() {
               event.documents.forEach((snapshot) { results.add(Department.fromJson(snapshot.data)); });
             });
       })..onDone(() {
         setState(() {
           message = results.isEmpty ? 'No subscribed Departments' : '';
           print(message);
         });
       })..onError((e){
         setState(() {
           message = "Error Occurred";
           print(message);
         });
       });
    } else {
      if(await FirebaseMethods.getFirestoreUserDataInfo()){
        getSubscribedDepartments();
      }
    }

  }

  void onSubscribePressed(String toSubscribe, bool hasSubscribed) async {
    Firestore db = Firestore.instance;

    db.runTransaction((transaction) async {
      if(User.lastUserState != UserState.subscription){
        await db.collection('users').document(User.authUser.uid).get().then((snapshot){
          User.saveUserData(UserData.fromFirestoreJson(snapshot.data), UserState.subscription);
        });
      }
      if (!User.userData.subscribedDepartmentIDs.contains(toSubscribe)) {
        User.userData.subscribedDepartmentIDs.add(toSubscribe);
        setState(() {});
        await db
            .collection('users')
            .document(User.authUser.uid)
            .updateData(User.userData.toFirestoreJson())
            .catchError((e) {
          return null;
        });
      } else {
        User.userData.subscribedDepartmentIDs.remove(toSubscribe);
        setState(() {});
        await db
            .collection('users')
            .document(User.authUser.uid)
            .updateData(User.userData.toFirestoreJson())
            .catchError((e) {
          return null;
        });
      }
      return null;
    });
  }

  void search(String textToSearch) async {
    if (textToSearch.isNotEmpty) {
      query = query.search(textToSearch);
      searchResults.clear();
      List<String> result = [];
      (await query.getObjects()).hits.forEach((element) {
        if (searchResults.length < 5) {
          result.add(element.data['areaOfAdministration']);
        }
      });
      setState(() {
        searchResults = textEditingController.text.isNotEmpty ? result : [];
      });
    } else {
      setState(() {
        searchResults.clear();
      });
    }
  }

  void onPlaceSelected(String place) async{
    textEditingController.text = place;
    setState(() {
      isSearching = false;
    });
    if(place.isNotEmpty) {
      getAvailableDepartments(place.toLowerCase().trim());
    }
  }

  void setupAlgolia() async {
    algolia = Algolia.init(
        applicationId: "EV6Y9JFNMN",
        apiKey: "84f5028a9a96b956051ec63b38e0399d");
    query = algolia.instance.index('departments_prod').setHitsPerPage(5);
  }

  Future<void> onRefresh() async{
    setState(() {
      getSubscribedDepartments();
    });
  }


  @override
  void initState() {
    setupAlgolia();
    textEditingController.addListener(() {
      search(textEditingController.text);
    });
    getSubscribedDepartments();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
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
        leading: Container(
          margin: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  User.authUser.photoUrl,
                )
            ),
          ),
        ),
        title: Container(
          margin: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 0.0, right: 10.0),
          padding: EdgeInsets.only(right: 10.0, left: 8.0),
          height: 40.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 6,
                child: TextField(
                  onTap: () {
                    isSearching = true;
                    setState(() {});
                  },
                  onEditingComplete: (){
                    onPlaceSelected(textEditingController.text);
                  },
                  onSubmitted: (s){
                    print('submit');
                  },
                  controller: textEditingController,
                  cursorColor: Colors.black,
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .copyWith(color: Color(0xff514A4A)),
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
              Expanded(
                flex: 1,
                child: Icon(
                  isSearching ? Icons.close : Icons.search,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
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
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
              decoration: BoxDecoration(
                  border: Border.symmetric(
                      vertical: BorderSide(
                          color: Colors.grey, width: 0.2))),
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
      ) : GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            setState(() {
              isSearching = false;
            });
          }
        },
        child: results.isNotEmpty ? RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            itemCount: results?.length,
            itemBuilder: (context, index) {
              Department department = results[index];
              bool hasSubscribed =
                  (User.userData.subscribedDepartmentIDs ?? [])
                      .contains(department.email) ??
                      false;
              return DepartmentsMessageBox(
                subscribed: hasSubscribed,
                department: department,
                onSubscribePressed: () =>
                    onSubscribePressed(results[index].email, hasSubscribed),
              );
            },
          ),
        ) : Container(
          child: Center(
            child: Text(message),
          ),
        ),
      ),
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
        color: Color(avatarColorMap[department.category]),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            child: SvgPicture.asset(
              avatarLocMap[department.category],
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
                              color: Color(
                                  categoryTagColorMap[department.category]),
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
