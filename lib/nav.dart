import 'package:flutter/material.dart';

import './views/login.dart';
import 'views/home.dart';

class Nav {
  static home(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
        HomePage()), (_) => false);
  }

  static login(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }
}
