import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tchat_messaging_app/services/auth.dart';
import 'package:tchat_messaging_app/services/database.dart';

import '../nav.dart';

const users = const {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

class LoginPage extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
            child: ElevatedButton(
              onPressed: () async {
                print('button just pressed.');
                User user = await Authentication.of(context).signInWithGoogle(context: context);
                print('signing in.');
                if (user != null) {
                  Database().storeUserData();
                  Nav.home(context);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.google),
                  Text('Google Sign In'),
                ],
              ),
            ),
          )),
    );
  }
}
