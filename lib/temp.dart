import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:hamaraprashasan/helpline_numbers.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('Welcome Ronak', style: Theme.of(context).textTheme.headline6,),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(15.0),
              padding: EdgeInsets.all(15.0),
              color: Color(0xffF3F5F7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hospitals', style: Theme.of(context).textTheme.headline5,),
                  Text('During these covid times find nearby hospitals verified for covid tests.', style: Theme.of(context).textTheme.bodyText1),
                  CupertinoButton(
                    onPressed: (){
                      Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => HelpLineNumbers()));
                    },
                    padding: EdgeInsets.all(0.0),
                    child: Row(
                      children: [
                        Text('Find Nearby hospitals', style: TextStyle(fontFamily: 'Poppins', color: Colors.blue),),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(15.0),
              padding: EdgeInsets.all(15.0),
              color: Color(0xffF3F5F7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Covid Stats', style: Theme.of(context).textTheme.headline5,),
                  Text('See number of Coronavirus cases in different states of india and their statistics', style: Theme.of(context).textTheme.bodyText1),
                  CupertinoButton(
                    onPressed: (){
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => WebviewScaffold(
                                scrollBar: true,
                                url: "https://www.covid19india.org",
                                appBar: new AppBar(
                                  iconTheme: IconThemeData(
                                      color: Colors.black
                                  ),
                                  automaticallyImplyLeading: true,
                                  backgroundColor: Colors.white,
                                  elevation: 0.5,
                                  title: new Text("Covid-19 Stats", style: Theme.of(context).textTheme.headline4,),
                                ),
                              )
                          ));
                    },
                    padding: EdgeInsets.all(0.0),
                    child: Row(
                      children: [
                        Text('Check Number of cases', style: TextStyle(fontFamily: 'Poppins', color: Colors.blue),),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.blue,
                        ),
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
