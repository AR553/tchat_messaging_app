import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tchat_messaging_app/services/auth.dart';
import 'package:tchat_messaging_app/services/database.dart';

import '../nav.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SvgPicture.asset('assets/login.svg'),
          SizedBox(height: 30),
          Center(
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
            ),
          ),
        ],
      ),
    );
  }
}
