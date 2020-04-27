import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DepartmentsPage extends StatefulWidget {
  @override
  _DepartmentsPageState createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 60.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DepartmentsMessageBox(
                    imageLoc: 'assets/health_avatar.svg',
                    subscribed: true,
                    title: "Ministry of Health",
                    subtitle: "India",
                  ),
                  DepartmentsMessageBox(
                    imageLoc: 'assets/police_avatar.svg',
                    subscribed: false,
                    title: "Police Department",
                    subtitle: "Surat",
                  ),
                  DepartmentsMessageBox(
                    imageLoc: 'assets/muncorp_avatar.svg',
                    subscribed: true,
                    title: "Municipal Corporation",
                    subtitle: "Surat",
                  ),
                  DepartmentsMessageBox(
                    imageLoc: 'assets/muncorp_avatar.svg',
                    subscribed: true,
                    title: "Municipal Corporation",
                    subtitle: "Surat",
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Color(0xffF0F0F0),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Text(
                    "Search City, State or Department",
                    style: Theme.of(context)
                        .textTheme
                        .headline1
                        .copyWith(color: Color(0xff6F6F6F)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Icon(Icons.search),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class DepartmentsMessageBox extends StatelessWidget {

  final String imageLoc, title, subtitle;
  final bool subscribed;

  DepartmentsMessageBox({this.imageLoc, this.title, this.subtitle, this.subscribed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        color: Color(0xffFFFCED),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                child: SvgPicture.asset(
                  imageLoc,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headline3.copyWith(
                            color: Color(0xff514A4A),
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.headline2.copyWith(
                            color: Color(0xff514A4A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: CupertinoButton(
              padding: EdgeInsets.all(0.0),
              onPressed: (){},
              child: Text(
                subscribed ? "SUBSCRIBE" : "UNSUBSCRIBE",
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
