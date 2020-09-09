import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamaraprashasan/app_configurations/app_configurations.dart';
import 'package:hamaraprashasan/app_auth/google_sign_in/sign_in.dart';

class LoginPage extends StatelessWidget {
  void onSignIn(context) async {
    bool signed = await signInWithGoogle() ?? false;
    if (signed) {
      _showMyDialog(context);
    }
    bool fetchedData =
        await FirebaseMethods.getFirestoreUserDataInfo() ?? false;
    if (signed && fetchedData) {
      print('Signed into google');
      AppConfigs.setSigningState = true;
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      print('ERROR: you did not selected any account');
      Navigator.of(context).pop();
    }
  }

  void _showMyDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 50.0,
                        width: 50.0,
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Logging In...",
                            style: Theme.of(context).textTheme.headline3,
                          )),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 300.0,
                padding: EdgeInsets.only(top: 100.0),
                child: Image.asset(
                  'assets/parliament.png',
                ),
              ),
              /* Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text('Hamara Prashasan', style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 25.0),),
              ), */
              Padding(
                padding: EdgeInsets.only(top: 15.0, left: 25.0, right: 25.0),
                child: Text(
                  'Subscribe to government departments to get regular updates from them',
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .copyWith(color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(
                      top: 50.0, bottom: 50.0, left: 15.0, right: 15.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color(0xfff3f4f8)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: 'Sign in with ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline2
                                      .copyWith(color: Colors.black87)),
                              TextSpan(children: [
                                TextSpan(
                                    text: 'G',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .copyWith(color: Color(0xff4285f4))),
                                TextSpan(
                                    text: 'o',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .copyWith(color: Color(0xffea4335))),
                                TextSpan(
                                    text: 'o',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .copyWith(color: Color(0xfffbbc05))),
                                TextSpan(
                                    text: 'g',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .copyWith(color: Color(0xff4285f4))),
                                TextSpan(
                                    text: 'l',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .copyWith(color: Color(0xff34a853))),
                                TextSpan(
                                    text: 'e',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .copyWith(color: Color(0xffea4335)))
                              ]),
                            ]),
                          ),
                        ),
                        MaterialButton(
                          color: Colors.white,
                          minWidth: 40.0,
                          padding: EdgeInsets.all(7.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 20.0,
                          ),
                          onPressed: () => onSignIn(context),
                          elevation: 0.0,
                          focusElevation: 1.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
