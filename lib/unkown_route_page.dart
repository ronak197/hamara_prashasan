import 'package:flutter/material.dart';

class UnkownRoutePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('We can\'t find an appropriate page to display', style: Theme.of(context).textTheme.headline2,),
      ),
    );
  }
}
