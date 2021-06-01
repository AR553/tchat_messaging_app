import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/models/user.dart';
import 'package:tchat_messaging_app/utilities/functions.dart';

class ChatAppBar extends AppBar {
  ChatAppBar(this.chatId, this.user);

  final String chatId;
  final User user;

  @override
  double get titleSpacing => 0;

  @override
  List<Widget> get actions => [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: Text(Fns.lastSeen(user.lastSeenInEpoch, user.presence))),
    )
  ];

  @override
  Widget get title => Row(children: [
    CircleAvatar(
      backgroundColor: Colors.grey,
      backgroundImage: Image.network(user.photoURL).image,
    ),
    SizedBox(width: 10),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Builder(
            builder: (context) => Container(
              width: MediaQuery.of(context).size.width * .4,
              child: Text(
                '${Fns.camelcase(user.name.split('-').last)}',
                overflow: TextOverflow.ellipsis,
              ),
            )),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .doc(chatId)
              .collection(chatId)
              .doc(user.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.data()!=null && snapshot.data.data()['typing_status'])
                return Text(
                  ' typing...',
                  style: TextStyle(fontSize: 14),
                );
              else
                return Container();
            } else {
              return Container();
            }
          },
        )
      ],
    ),
  ]);
}
