import 'package:flutter/material.dart';

var numbers =
"""Andaman and Nicobar Islands,03192-232102;Andhra Pradesh,0866-2410978;Arunachal Pradesh,9436055743;Assam,6913347770;Bihar,104;Chandigarh,9779558282;Chhattisgarh,104;Dadra and Nagar Haveli and Daman & Diu,104;Delhi,011-22307145;Goa,104;Gujarat,104;Haryana,8558893911;Himachal Pradesh,104;Jammu & Kashmir,01912520982,0194-2440283;Jharkhand,104;Karnataka,104;Kerala,0471-2552056;Ladakh,01982256462;Lakshadweep,104;Madhya Pradesh,104;Maharashtra,020-26127394;Manipur,3852411668;Meghalaya,108;Mizoram,102;Nagaland,7005539653;Odisha,9439994859;Puducherry,104;Punjab,104;Rajasthan,0141-2225624;Sikkim,104;Tamil Nadu,044-29510500;Telangana,104;Tripura,0381-2315879;Uttarakhand,104;Uttar,Pradesh,18001805145;West Bengal,1800313444222,03323412600""";

class HelpLineNumbers extends StatefulWidget {
  @override
  _HelpLineNumbersState createState() => _HelpLineNumbersState();
}

class _HelpLineNumbersState extends State<HelpLineNumbers> {

  List<String> helplineNumbers;
  @override
  void initState() {
    helplineNumbers = numbers.split(';');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Helpline Numbers', style: Theme.of(context).textTheme.headline4,),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
      ),
      body: ListView.builder(
        itemCount: helplineNumbers.length,
        itemBuilder: (_, index){
          var helplineCombo = helplineNumbers[index].split(',');
          return helplineRowField(helplineCombo[0], helplineCombo[1], index, context);
        },
      ),
    );
  }
}

Widget helplineRowField(String state, String number, index, BuildContext context){
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 7,
          child: Container(
            margin: EdgeInsets.only(right: 3.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: index%2 == 0 ? Color(0xffF3F5F7) : Colors.white,
            ),
            padding: EdgeInsets.all(10.0),
            child: Text(state, style: Theme.of(context).textTheme.headline3,),          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: index%2 == 0 ? Color(0xffF3F5F7) : Colors.white,
            ),
            padding: EdgeInsets.all(10.0),
            child: Center(child: Text(number, style: Theme.of(context).textTheme.headline3,))
          ),
        ),
      ],
    ),
  );
}