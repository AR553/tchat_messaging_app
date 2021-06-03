import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tchat_messaging_app/services/auth.dart';
import 'package:tchat_messaging_app/services/database.dart';

import '../nav.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Widget illustration = FittedBox(child:SvgPicture.asset(
      'assets/login.svg',
      placeholderBuilder: (context) => CircularProgressIndicator(),
      fit: BoxFit.scaleDown,
    ));
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      body: orientation == Orientation.landscape
          ? Center(
            child: FittedBox(
        fit: BoxFit.fitHeight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      illustration,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Tchat Messaging App\n',
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                  fontSize: 30,
                                ),
                          ),
                          Container(
                            width: width / 2,
                            child: Text(
                              'Phasellus eget massa et augue sollicitudin tempor in eget nisl. Duis tempus sem ligula, ac ornare metus molestie ac. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Vestibulum quis nulla vitae tortor la.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 20),
                            ),
                          ),
                          SizedBox(height: 40),
                          GoogleSignInButton(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
          )
          : Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('TChat Messaging App', style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 30),),
                  illustration,
                  GoogleSignInButton(),
                ],
              ),
          ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          User user = await Authentication.of(context).signInWithGoogle(context: context);
          if (user != null) {
            Database().storeUserData();
            Nav.home(context);
          }
        },
        child: Container(
          padding: EdgeInsets.all(4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  padding: EdgeInsets.all(5.0),
                  color: Colors.white,
                  child: Image.asset(
                    'assets/google.png',
                    width: 20,
                    height: 20,
                  )),
              SizedBox(width: 5),
              Text('Sign in with Google'),
            ],
          ),
        ),
      ),
    );
  }
}
