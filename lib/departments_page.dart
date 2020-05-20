import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/classes.dart';

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
                    category: 'health',
                    subscribed: true,
                    name: "Ministry of Health",
                    areaOfAdministration: "India",
                  ),
                  DepartmentsMessageBox(
                    category: 'police',
                    subscribed: false,
                    name: "Police Department",
                    areaOfAdministration: "Surat",
                  ),
                  DepartmentsMessageBox(
                    category: 'muncorp',
                    subscribed: true,
                    name: "Municipal Corporation",
                    areaOfAdministration: "Surat",
                  ),
                  DepartmentsMessageBox(
                    category: 'health',
                    subscribed: true,
                    name: "Health Department",
                    areaOfAdministration: "Surat",
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

  final String category, name, areaOfAdministration;
  final bool subscribed;

  DepartmentsMessageBox({this.category, this.name, this.areaOfAdministration, this.subscribed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        color: Color(avatarColorMap[category]),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            child: SvgPicture.asset(
              avatarLocMap[category],
              height: 60.0,
              width: 60.0,
              fit: BoxFit.contain,
              placeholderBuilder: (context){
                return Container(
                  width: 64.0,
                  height: 64.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xfff7f7f7)]
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headline2.copyWith(
                        color: Color(0xff514A4A),
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            areaOfAdministration,
                            style: Theme.of(context).textTheme.headline1.copyWith(
                              color: Color(0xff514A4A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                            decoration: BoxDecoration(
                              color: Color(categoryTagColorMap[category]),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              category,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      RawMaterialButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.all(0.0),
                        fillColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                        child: Text('Subscribe', style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

