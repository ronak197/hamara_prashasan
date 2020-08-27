import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hamaraprashasan/app_configurations/app_configurations.dart';
import 'package:hamaraprashasan/home_page/app_drawer/account_tab/edit_account_page.dart';

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
                    return Container(color: Colors.white);
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