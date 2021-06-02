import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/views/chat.dart';

import './views/login.dart';
import 'models/user.dart';
import 'views/home.dart';
import 'views/settings.dart';

class Nav {
  static home(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (_) => false);
  }

  static login(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }

  static chat(BuildContext context, User user) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(user: user)));
  }

  static setting(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  static pop(BuildContext context) {
    Navigator.pop(context);
  }

}
