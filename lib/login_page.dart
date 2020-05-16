import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hamaraprashasan/app_configurations.dart';
import 'package:hamaraprashasan/sign_in.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            ClipPath(
              clipper: WhiteTopClipper(),
              child: Container(
                color: Color(0xfff4f5f7),
              ),
            ),
            ClipPath(
              clipper: GreyTopClipper(),
              child: Container(
                color: Color(0xff306eff),
              ),
            ),
            ClipPath(
              clipper: BlueTopClipper(),
              child: Container(
                color: Colors.white,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 30.0),
                  child: Text('hamara', style: TextStyle(fontFamily: 'OpenSans', fontSize: 40.0, fontWeight: FontWeight.w600),),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0, left: 20.0),
                  child: Text('Prashasan', style: TextStyle(fontFamily: 'OpenSans', fontSize: 40.0, fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(20.0),
                    alignment: Alignment.bottomCenter,
                    child: RawMaterialButton(
                      onPressed: () async {
                        if(await signInWithGoogle()){
                          AppConfigurations.setSigningState = true;
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else {
                          print('ERROR');
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Sign In with Google', style: TextStyle(fontFamily: 'OpenSans', color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600, letterSpacing: 1.0),),
                          Container(
                              height: 30.0,
                              width: 30.0,
                              padding: EdgeInsets.all(7.0),
                              margin: EdgeInsets.only(left: 20.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: Colors.white,
                              ),
                              child: SvgPicture.asset('assets/google.svg')
                          ),
                        ],
                      ),
                      fillColor: Color(0xff528df9),
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BlueTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path()
      ..lineTo(0.0, 220.0)
      ..quadraticBezierTo(
        size.width / 2.2,
        260.0,
        size.width,
        170.0,
      )
      ..lineTo(size.width, 0.0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class GreyTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path()
      ..lineTo(0.0, 265.0)
      ..quadraticBezierTo(
        size.width / 2,
        285.0,
        size.width,
        185.0,
      )
      ..lineTo(size.width, 0.0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class WhiteTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path()
      ..lineTo(0.0, 310.0)
      ..quadraticBezierTo(
        size.width / 2,
        310.0,
        size.width,
        200.0,
      )
      ..lineTo(size.width, 0.0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}