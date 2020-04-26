import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DepartmentsPage extends StatefulWidget {
  @override
  _DepartmentsPageState createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.grey.withOpacity(0.2),
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
                        .copyWith(color: Color(0xff8C8C8C)),
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
        ],
      ),
    );
  }
}

class DepartmentsMessageBox extends StatelessWidget {
  final String imageLoc, title, subtitle;
  final bool subscribed;
  DepartmentsMessageBox(
      {this.imageLoc, this.title, this.subtitle, this.subscribed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
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
                        style: Theme.of(context).textTheme.headline3.copyWith(
                            color: Color(0xff514A4A),
                            fontWeight: FontWeight.bold),
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
            alignment: Alignment.topRight,
            child: Container(
              margin: EdgeInsets.only(top: 10.0),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Text(
                subscribed ? "Subscribed" : "Unsubscribed",
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(color: Color(0xff8C8C8C)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
