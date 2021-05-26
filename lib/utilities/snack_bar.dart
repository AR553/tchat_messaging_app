import 'package:flutter/material.dart';

class CustomSnackBar{
  static void show(BuildContext context, {String content}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          content,
          style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
