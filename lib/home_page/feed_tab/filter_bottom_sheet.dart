import 'package:flutter/material.dart';
import 'package:hamaraprashasan/helper_classes/other_classes.dart';
import 'package:hamaraprashasan/helper_classes/user_classes/department_user_class.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> departments, prevVal;
  final Function(SortingFeeds sortingFeeds, List<Department> departments,
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
  SortingFeeds sortingFeeds = new SortingFeeds();
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
    sortingFeeds = widget.prevVal['sortingFeeds'] ?? SortingFeeds();
    start = widget.prevVal['start'];
    end = widget.prevVal['end'];
  }

  void clearFilers() {
    sortingFeeds.type = SortingType.none;
    sortingFeeds.increasing = true;
    start = null;
    end = null;
    for (int i = 0; i < departmentSelected.length; i++) {
      departmentSelected[i] = true;
    }
    for (int i = 0; i < categoriesSelected.length; i++) {
      categoriesSelected[i] = true;
    }
    applyFilters();
  }

  void applyFilters() {
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
    widget.applyFilters(
        sortingFeeds, selectedDepartments, selectedCategories, start, end);
    Navigator.pop(context);
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
    bool filtered = this.sortingFeeds.type != SortingType.none ||
        this.departmentSelected.any((e) => !e) ||
        this.categoriesSelected.any((e) => !e) ||
        start != null ||
        end != null;
    bool sorted = this.sortingFeeds.type != SortingType.none,
        departmentsFiltered = this.departmentSelected.any((e) => !e),
        categoriesFiltered = this.categoriesSelected.any((e) => !e),
        dateProvided = start != null || end != null;
    return Container(
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
                              child: Stack(
                                children: <Widget>[
                                      Container(
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                      ),
                                    ] +
                                    (sorted
                                        ? <Widget>[
                                            Positioned(
                                              right: 5,
                                              top: 5,
                                              child: Container(
                                                height: 7,
                                                width: 7,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            )
                                          ]
                                        : <Widget>[]),
                              ),
                            ),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = 1;
                                  });
                                },
                                child: Stack(
                                  children: <Widget>[
                                        Container(
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                        )
                                      ] +
                                      (departmentsFiltered
                                          ? <Widget>[
                                              Positioned(
                                                right: 5,
                                                top: 5,
                                                child: Container(
                                                  height: 7,
                                                  width: 7,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              )
                                            ]
                                          : <Widget>[]),
                                )),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = 2;
                                  });
                                },
                                child: Stack(
                                  children: <Widget>[
                                        Container(
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                        )
                                      ] +
                                      (categoriesFiltered
                                          ? <Widget>[
                                              Positioned(
                                                right: 5,
                                                top: 5,
                                                child: Container(
                                                  height: 7,
                                                  width: 7,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              )
                                            ]
                                          : <Widget>[]),
                                )),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = 3;
                                });
                              },
                              child: Stack(
                                children: <Widget>[
                                      Container(
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                      )
                                    ] +
                                    (dateProvided
                                        ? <Widget>[
                                            Positioned(
                                              right: 5,
                                              top: 5,
                                              child: Container(
                                                height: 7,
                                                width: 7,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            )
                                          ]
                                        : <Widget>[]),
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
                                        sortingFeeds.type =
                                            SortingType.values[index];
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
                                              fontWeight: index ==
                                                      sortingFeeds.type.index
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: index ==
                                                      sortingFeeds.type.index
                                                  ? Colors.green
                                                  : Colors.black,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              ) +
                              <Widget>[
                                SizedBox(height: 50),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                      bottom: 15, top: 15, left: 35, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Decreasing:",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2
                                            .copyWith(
                                                decoration:
                                                    TextDecoration.underline),
                                      ),
                                      Checkbox(
                                        value: !sortingFeeds.increasing,
                                        onChanged: (value) {
                                          setState(() {
                                            sortingFeeds.increasing = !value;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ]
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
                                          //MyDateSelector()
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 10),
                                            child: RaisedButton(
                                              elevation: 0.0,
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
                                              color: Color(0xfff1c40f),
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
                                              elevation: 0.0,
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
                                              color: Color(0xfff1c40f),
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
                  onPressed: filtered ? clearFilers : null,
                  child: Text(
                    "Clear all",
                    style: Theme.of(context).textTheme.headline2.copyWith(
                          color: filtered ? Colors.red : Colors.grey,
                        ),
                  ),
                ),
                RaisedButton(
                  onPressed: applyFilters,
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
