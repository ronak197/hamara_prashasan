import 'package:flutter/material.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:hamaraprashasan/drawer_icons_icons.dart';
import 'package:hamaraprashasan/sign_in.dart';

class MyAppDrawer extends StatefulWidget {
  @override
  _MyAppDrawerState createState() => _MyAppDrawerState();
}

class _MyAppDrawerState extends State<MyAppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              radius: 50.0,
              child: Text('RJ',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.white)),
            ),
            decoration: BoxDecoration(color: Color(0xff02CCFF)),
            accountEmail: Text(
              'jain.ronak197@gmail.com',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  .copyWith(color: Colors.white),
            ),
            accountName: Text('Ronak Jain',
                style: Theme.of(context).textTheme.headline1.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(0.0),
              children: [
                InkWell(
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
                            color: Colors.black,
                            size: 18.0,
                          )),
                      Text(
                        'Make a Public Post',
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
                            DrawerIcons.notifications,
                            color: Colors.black,
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
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                          padding: EdgeInsets.all(20.0),
                          child: Icon(
                            DrawerIcons.general,
                            color: Colors.black,
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
                            DrawerIcons.account,
                            color: Colors.black,
                            size: 18.0,
                          )),
                      Text(
                        'Account',
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
                            DrawerIcons.privacy,
                            color: Colors.black,
                            size: 18.0,
                          )),
                      Text(
                        'Privacy',
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
                            DrawerIcons.blacklist,
                            color: Colors.black,
                            size: 18.0,
                          )),
                      Text(
                        'Block',
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
                            color: Colors.black,
                            size: 18.0,
                          )),
                      Text(
                        'Help',
                        style: Theme.of(context).textTheme.headline2,
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async{
                    signOutGoogle();
                    AppConfigurations.setSigningState = false;
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                          padding: EdgeInsets.all(20.0),
                          child: Icon(
                            Icons.exit_to_app,
                            color: Colors.black,
                            size: 20.0,
                          )),
                      Text(
                        'Logout',
                        style: Theme.of(context).textTheme.headline2,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
