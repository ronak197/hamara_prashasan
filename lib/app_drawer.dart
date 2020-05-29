import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:hamaraprashasan/drawer_icons_icons.dart';
import 'package:hamaraprashasan/sign_in.dart';

class MyAppDrawer extends StatefulWidget {
  @override
  _MyAppDrawerState createState() => _MyAppDrawerState();
}

class _MyAppDrawerState extends State<MyAppDrawer> {

  bool imageLoadFailed = false;

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
                    User.authUser.photoUrl ?? '',
                  errorListener: (){
                      setState(() {
                        imageLoadFailed = true;
                      });
                  }
                ),
                radius: 40.0,
                child: imageLoadFailed ?
                  Text(
                    'RJ',
                    style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.white)
                  ) : SizedBox(),
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
                              color: Color(0xff303046),
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
                    onTap: () {},
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
                            )),
                        Text(
                          'Account',
                          style: Theme.of(context).textTheme.headline2,
                        )
                      ],
                    ),
                  ),
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
                              DrawerIcons.privacy,
                              color: Color(0xff303046),
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
                    onTap: () async{
                      signOutGoogle();
                      AppConfigs.setSigningState = false;
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
