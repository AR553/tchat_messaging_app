import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './views/login.dart';
import 'views/home.dart';

class Nav {
  static home(BuildContext context, User user) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
        HomePage(user:user)), (_) => false);
  }

  static login(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }
}
