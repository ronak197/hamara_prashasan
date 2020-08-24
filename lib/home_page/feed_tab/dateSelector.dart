import 'package:flutter/material.dart';

class MyDateSelector extends StatefulWidget {
  @override
  _MyDateSelectorState createState() => _MyDateSelectorState();
}

class _MyDateSelectorState extends State<MyDateSelector> {
  int day, month, year;
  @override
  void initState() {
    super.initState();
    var d = DateTime.now();
    day = d.day;
    month = d.month;
    year = d.year;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_drop_up),
              onPressed: null,
            ),
            Container(
              padding: EdgeInsets.all(2),
              height: 30,
            ),
            IconButton(
              icon: Icon(Icons.arrow_drop_down),
              onPressed: null,
            ),
          ],
        ),
        Column(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_drop_up),
              onPressed: null,
            ),
            Container(
              padding: EdgeInsets.all(2),
              height: 30,
            ),
            IconButton(
              icon: Icon(Icons.arrow_drop_down),
              onPressed: null,
            ),
          ],
        ),
        Column(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_drop_up),
              onPressed: null,
            ),
            Container(
              padding: EdgeInsets.all(2),
              height: 30,
            ),
            IconButton(
              icon: Icon(Icons.arrow_drop_down),
              onPressed: null,
            ),
          ],
        )
      ],
    );
  }
}
