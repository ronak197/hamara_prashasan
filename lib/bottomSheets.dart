import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hamaraprashasan/app_configurations.dart';
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
                child: CachedNetworkImage(
                  imageUrl: User.authUser.photoUrl,
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
  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int selectedIndex = 0, sortSelectedIndex;
  List<String> sortingList = ["Date", "Department", "Ratings", "City"],
      departmentList = [
    "Surat Health Department",
    "Delhi Health Department",
    "Delhi Municipal Department",
    "Surat Police Department",
    "Delhi Police Department"
  ];
  List<bool> departmentSelected = [true, true, true, true, true];
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
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: Colors.grey[200],
                      child: Column(
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
                                style: Theme.of(context).textTheme.headline3,
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
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: selectedIndex == 0
                          ? new List<Widget>.generate(
                              sortingList.length,
                              (index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      sortSelectedIndex = index;
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
                                          .headline2
                                          .copyWith(
                                            fontWeight:
                                                sortSelectedIndex == index
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                            color: sortSelectedIndex == index
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
                                  departmentList.length,
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
                                          departmentList[index],
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2
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
                              : <Widget>[],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 80,
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
                      sortSelectedIndex = null;
                      for (int i = 0; i < departmentSelected.length; i++) {
                        departmentSelected[i] = false;
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
