import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:hamaraprashasan/classes.dart';
import 'package:hamaraprashasan/editAccount.dart';

class AccountBottomSheet extends StatefulWidget {
  @override
  _AccountBottomSheetState createState() => _AccountBottomSheetState();
}

class _AccountBottomSheetState extends State<AccountBottomSheet> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.55,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          Container(
            child: Column(
              children: [
                Container(
                  height: 50,
                  color: Colors.transparent,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            //Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAccountPage(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Edit profile",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(color: Colors.green),
                              ),
                              Icon(
                                Icons.arrow_right,
                                color: Colors.green,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            User.authUser.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                .copyWith(),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            User.authUser.email,
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(color: Colors.grey),
                          ),
                        ),
                        User.authUser.phoneNumber != null
                            ? Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  User.authUser.phoneNumber,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      .copyWith(color: Colors.grey),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: size.width / 2 - 52,
            top: 0,
            child: Container(
              margin: EdgeInsets.all(12.0),
              padding: EdgeInsets.all(2),
              height: 80,
              width: 80,
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
                          return Container();
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> departments, prevVal;
  final Function(SortingType sortingType, List<Department> departments,
      List<String> categories, DateTime start, DateTime end) applyFilters;
  FilterBottomSheet(
      {@required this.departments,
      @required this.applyFilters,
      @required this.prevVal});
  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

enum SortingType { department, category, none }

enum FilterType { All, Department, Category }

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int selectedIndex = 0;
  SortingType _sortingType = SortingType.none;
  List<String> sortingList = [
    "Department",
    "Category",
  ];
  List<Department> departments = [];
  List<String> categories = [];
  List<bool> departmentSelected = [], categoriesSelected = [];
  DateTime start, end;

  void getDepartments() {
    widget.departments.forEach((key, value) {
      departments.add(new Department.fromJson(value));
    });
    departmentSelected = new List.generate(departments.length, (index) {
      return widget.prevVal['selDep'].contains(departments[index].email);
    });
  }

  void getCategories() {
    Set<String> cat = new Set<String>();
    departments.forEach((d) {
      cat.add(d.category);
    });
    categories = cat.toList();
    categoriesSelected = new List.generate(categories.length, (index) {
      return widget.prevVal['selCat'].contains(categories[index]);
    });
  }

  void setPreviousValues() {
    _sortingType = widget.prevVal['sortingType'];
    start = widget.prevVal['start'];
    end = widget.prevVal['end'];
  }

  @override
  void initState() {
    super.initState();
    getDepartments();
    getCategories();
    setPreviousValues();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.75,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              //borderRadius: BorderRadius.circular(2),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300],
                  width: 1,
                ),
              ),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Text(
                    "Filters",
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: double.maxFinite,
                      color: Colors.grey[200],
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = 0;
                                });
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: selectedIndex == 0
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                                child: Text(
                                  "Sort by",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = 1;
                                });
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: selectedIndex == 1
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                                child: Text(
                                  "Department",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = 2;
                                });
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: selectedIndex == 2
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                                child: Text(
                                  "Category",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = 3;
                                });
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: selectedIndex == 3
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                                child: Text(
                                  "Date",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: selectedIndex == 0
                          ? new List<Widget>.generate(
                              sortingList.length,
                              (index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _sortingType = SortingType.values[index];
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        bottom: 15,
                                        top: 15,
                                        left: 35,
                                        right: 15),
                                    child: Text(
                                      sortingList[index],
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1
                                          .copyWith(
                                            fontWeight:
                                                index == _sortingType.index
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                            color: index == _sortingType.index
                                                ? Colors.green
                                                : Colors.black,
                                          ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : selectedIndex == 1
                              ? new List<Widget>.generate(
                                  departments.length,
                                  (index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          departmentSelected[index] =
                                              !departmentSelected[index];
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(
                                            bottom: 15,
                                            top: 15,
                                            left: 15,
                                            right: 15),
                                        child: Text(
                                          departments[index].name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline1
                                              .copyWith(
                                                /* fontWeight:
                                                    departmentSelected[index]
                                                        ? FontWeight.bold
                                                        : FontWeight.normal, */
                                                color: departmentSelected[index]
                                                    ? Colors.green
                                                    : Colors.black,
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : selectedIndex == 2
                                  ? new List<Widget>.generate(
                                      categories.length,
                                      (index) {
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              categoriesSelected[index] =
                                                  !categoriesSelected[index];
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(
                                                bottom: 15,
                                                top: 15,
                                                left: 15,
                                                right: 15),
                                            child: Text(
                                              categories[index],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline1
                                                  .copyWith(
                                                    /* fontWeight:
                                                    departmentSelected[index]
                                                        ? FontWeight.bold
                                                        : FontWeight.normal, */
                                                    color: categoriesSelected[
                                                            index]
                                                        ? Colors.green
                                                        : Colors.black,
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : selectedIndex == 3
                                      ? <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Text("Select Feeds\nFrom :",
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline2),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 10),
                                            child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              onPressed: () async {
                                                start = await showDatePicker(
                                                        context: context,
                                                        initialDate: start ??
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(2015),
                                                        lastDate:
                                                            DateTime(2030)) ??
                                                    start;
                                                setState(() {});
                                              },
                                              color: Colors.yellow[600],
                                              child: Text(
                                                start != null
                                                    ? start
                                                        .toIso8601String()
                                                        .substring(0, 10)
                                                    : "Start",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Text("To :",
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline2),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 10),
                                            child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              onPressed: () async {
                                                end = await showDatePicker(
                                                        context: context,
                                                        initialDate: end ??
                                                            start ??
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(2015),
                                                        lastDate:
                                                            DateTime(2030)) ??
                                                    end;
                                                if (end != null) {
                                                  end = end.add(Duration(
                                                      seconds: 24 * 3600 - 1));
                                                }
                                                setState(() {});
                                              },
                                              color: Colors.yellow[600],
                                              child: Text(
                                                end != null
                                                    ? end
                                                        .toIso8601String()
                                                        .substring(0, 10)
                                                    : "End",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                          )
                                        ]
                                      : <Widget>[],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 5),
                  color: Colors.grey[300],
                  blurRadius: 5,
                  spreadRadius: 10,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FlatButton(
                  onPressed: () {
                    setState(() {
                      _sortingType = SortingType.none;
                      start = null;
                      end = null;
                      for (int i = 0; i < departmentSelected.length; i++) {
                        departmentSelected[i] = true;
                      }
                      for (int i = 0; i < categoriesSelected.length; i++) {
                        categoriesSelected[i] = true;
                      }
                    });
                  },
                  child: Text(
                    "Clear all",
                    style: Theme.of(context).textTheme.headline2.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    List<Department> selectedDepartments = [];
                    List<String> selectedCategories = [];
                    for (int i = 0; i < departmentSelected.length; i++) {
                      if (departmentSelected[i]) {
                        selectedDepartments.add(departments[i]);
                      }
                    }
                    for (int i = 0; i < categoriesSelected.length; i++) {
                      if (categoriesSelected[i]) {
                        selectedCategories.add(categories[i]);
                      }
                    }
                    widget.applyFilters(_sortingType, selectedDepartments,
                        selectedCategories, start, end);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Apply Filters",
                    style: Theme.of(context).textTheme.headline2.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  color: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
