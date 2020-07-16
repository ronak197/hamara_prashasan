import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hamaraprashasan/location_bloc.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        leading: GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Container(
            margin: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
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
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
        titleSpacing: 5.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome ${User.authUser.displayName.split(" ")[0]}',
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(fontWeight: FontWeight.w600)),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    height: 16.0,
                    alignment: Alignment.bottomCenter,
                    child: Center(
                        child: Icon(
                      Icons.location_on,
                      size: 12.0,
                      color: Color(0xff6D6D6D),
                    ))),
                Container(
                    height: 16.0,
                    alignment: Alignment.topLeft,
                    child: Center(
                        child: InkWell(

                          onTap: () => LocationBloc.getNewLocation(),
                          child: StreamBuilder(
                            stream: LocationBloc.locationStream,
                            builder: (context, AsyncSnapshot<String> snapshot){
                              return Text(snapshot.hasData ? snapshot.data : 'Your Location',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(color: Color(0xff6D6D6D)));
                            },
                          ),
                        )))
              ],
            )
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'You will soon be able to chat with the departments',
            style: Theme.of(context).textTheme.headline2,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
