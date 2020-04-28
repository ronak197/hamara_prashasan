import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/feedClasses.dart';
import 'package:hamaraprashasan/feedInfoPage.dart';

class NewsFeedPage extends StatefulWidget {
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => FeedInfoPage(
                      content: [
                        TextData(
                            text:
                                "Citizens are informed that curfew has been imposed starting from today till further announcement by the government of India. Following locations are the places where you can get shelter homes."),
                        TableData(
                          headers: List.generate(6, (index) => "Head"),
                          contents: List.generate(
                            4,
                            (i) => List.generate(6, (j) => "Row ${i + 1}"),
                          ),
                        ),
                        ImageData(
                            url:
                                "https://firebasestorage.googleapis.com/v0/b/elare-bd2f2.appspot.com/o/cover_images%2FMLDC_cover.png?alt=media&token=b375c390-bf56-47e2-9fcf-d6ba5d7d39f8"),
                      ],
                    )));
          },
          child: MessageBox(),
        ),
      ],
    );
  }
}

class MessageBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
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
                  'assets/police_avatar.svg',
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
                        'Surat Police Department',
                        style: Theme.of(context).textTheme.headline3.copyWith(
                            color: Color(0xff514A4A),
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Curfew Till 12th of May',
                        style: Theme.of(context)
                            .textTheme
                            .headline2
                            .copyWith(color: Color(0xff514A4A)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: 10.0),
            child: Text(
              'Citizens are informed that curfew has been imposed starting from today till further announcement.',
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: 10.0),
            child: Text(
              'Surat, 11:00 AM',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Color(0xff8C8C8C)),
            ),
          ),
        ],
      ),
    );
  }
}
