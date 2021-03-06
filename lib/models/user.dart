import 'package:flutter/material.dart';

class User {
  String uid;
  String name;
  bool presence;
  String photoURL;
  int lastSeenInEpoch;
  String email;

  User({
    @required this.uid,
    @required this.name,
    @required this.presence,
    @required this.photoURL,
    @required this.lastSeenInEpoch,
    @required this.email,
  });

  static User fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      name: json['name'],
      presence: json['presence'],
      photoURL: json['photo_url'],
      lastSeenInEpoch: json['last_seen'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['uid'] = this.uid;
    data['name'] = this.name;
    data['presence'] = this.presence;
    data['photo_url'] = this.photoURL;
    data['last_seen'] = this.lastSeenInEpoch;
    data['email'] = this.email;

    return data;
  }
}