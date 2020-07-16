import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:hamaraprashasan/drawer_icons_icons.dart';
import 'package:hamaraprashasan/editAccount.dart';
import 'package:hamaraprashasan/sign_in.dart';

class MyAppDrawer extends StatefulWidget {
  final Function(Widget Function(BuildContext) builder,
      {double elevation,
      ShapeBorder shape,
      Color backgroundColor}) showBottomSheet;
  MyAppDrawer({this.showBottomSheet});
  @override
  _MyAppDrawerState createState() => _MyAppDrawerState();
}

class _MyAppDrawerState extends State<MyAppDrawer> {
  bool imageLoadFailed = false;

  void _logoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          "Are you sure you want to Logout?",
          style: Theme.of(context).textTheme.headline3,
        ),
        actions: [
          FlatButton(
            onPressed: () {
              signOutGoogle();
              AppConfigs.setSigningState = false;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', ModalRoute.withName('/home'));
            },
            child: Text("Yes"),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("No"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.0, bottom: 8.0),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                    User.authUser.photoUrl ?? '', errorListener: () {
                  setState(() {
                    imageLoadFailed = true;
                  });
                }),
                radius: 40.0,
                child: imageLoadFailed
                    ? Text(
                        User.authUser.displayName
                            .split(" ")
                            .reduce((value, element) => value[0] + element[0]),
                        style: Theme.of(context)
                            .textTheme
                            .headline4
                            .copyWith(color: Colors.white))
                    : SizedBox(),
              ),
            ),
            Text(User.authUser.displayName ?? '',
                style: Theme.of(context).textTheme.headline2.copyWith(
                    fontWeight: FontWeight.w600, color: Color(0xff303046))),
            Text(
              User.authUser.email ?? '',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  .copyWith(color: Color(0xffbbbbbe)),
            ),
            Divider(),
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(0.0),
                children: [
                  User.userData.userType == 'department'
                      ? InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed('/sendPost');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: Icon(
                                    DrawerIcons.paper_plane,
                                    color: Color(0xff303046),
                                    size: 18.0,
                                  )),
                              Text(
                                'Make a Public Post',
                                style: Theme.of(context).textTheme.headline2,
                              )
                            ],
                          ),
                        )
                      : SizedBox(),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            padding: EdgeInsets.all(20.0),
                            child: Icon(
                              DrawerIcons.notifications,
                              color: Color(0xff303046),
                              size: 18.0,
                            )),
                        Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.headline2,
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      /* widget.showBottomSheet(
                        (context) {
                          return AccountBottomSheet();
                        },
                        elevation: 20,
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                        ),
                      ); */
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAccountPage(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.0),
                          child: Icon(
                            DrawerIcons.account,
                            color: Color(0xff303046),
                            size: 18.0,
                          ),
                        ),
                        Text(
                          'Account',
                          style: Theme.of(context).textTheme.headline2,
                        )
                      ],
                    ),
                  ),
                  User.userData.userType == 'department'
                      ? InkWell(
                          onTap: () async {
                            Navigator.pushNamed(context, "/myfeeds");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.rss_feed,
                                  color: Color(0xff303046),
                                  size: 18.0,
                                ),
                              ),
                              Text(
                                'My Feeds',
                                style: Theme.of(context).textTheme.headline2,
                              )
                            ],
                          ),
                        )
                      : SizedBox(),
                  Divider(),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            padding: EdgeInsets.all(20.0),
                            child: Icon(
                              DrawerIcons.general,
                              color: Color(0xff303046),
                              size: 18.0,
                            )),
                        Text(
                          'General',
                          style: Theme.of(context).textTheme.headline2,
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            padding: EdgeInsets.all(20.0),
                            child: Icon(
                              DrawerIcons.help,
                              color: Color(0xff303046),
                              size: 18.0,
                            )),
                        Text(
                          'Help',
                          style: Theme.of(context).textTheme.headline2,
                        )
                      ],
                    ),
                  ),
                  Divider(),
                  InkWell(
                    onTap: () async {
                      _logoutDialog();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            padding: EdgeInsets.all(20.0),
                            child: Icon(
                              Icons.exit_to_app,
                              color: Color(0xff303046),
                              size: 20.0,
                            )),
                        Text(
                          'Logout',
                          style: Theme.of(context).textTheme.headline2,
                        )
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(20.0),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'Privacy Policy',
                          style: Theme.of(context).textTheme.headline1.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        TextSpan(
                          text: '  ᛫  ',
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              .copyWith(color: Colors.grey),
                        ),
                        TextSpan(
                          text: 'v1.0.0',
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              .copyWith(color: Colors.grey),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
