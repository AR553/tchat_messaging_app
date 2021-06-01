import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/models/message.dart';
import 'package:tchat_messaging_app/models/user.dart';
import 'package:tchat_messaging_app/services/auth.dart';
import 'package:tchat_messaging_app/services/database.dart';
import 'package:tchat_messaging_app/utilities/functions.dart';

import '../nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Database().updateUserPresence(true);
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        Database().updateUserPresence(true);
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        Database().updateUserPresence(false);

        print("app in paused");
        break;
      case AppLifecycleState.detached:
        Database().updateUserPresence(false);
        print("app in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TChat"),
        actions: [
          IconButton(
              onPressed: () {
                Authentication.of(context).signOut(context: context).then((value) {
                  Nav.login(context);
                });
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
            stream: Database().retrieveUsers(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return Center(child: Text(snapshot.error));
              else if (snapshot.hasData)
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    User user = User.fromJson(snapshot.data.docs[index].data());
                    if (user.uid == FirebaseAuth.instance.currentUser.uid)
                      return Container();
                    else
                      return ChatTile(user: user);
                  },
                );
              else
                return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  ChatTile({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;
  final String myId = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    final String chatId = Fns.getChatId(user.uid);
    return ListTile(
        onTap: () => Nav.chat(context, user),
        title: Text('${Fns.camelcase(user.name.split('-').last)}'),
        subtitle: FutureBuilder(
          future: Database().getLastMessage(user.uid),
          builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
            if(snapshot.hasData && snapshot.data.docs.isNotEmpty) {
              Message msg = Message.fromJson(snapshot.data.docs[0].data());
              return Text(msg??'');
              } else {
                return Container();
              }
            }
        ),
        leading: Stack(
          alignment: Alignment.topLeft,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: Image.network(user.photoURL).image,
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: user.presence ? Colors.green : Colors.red),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 97,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(child: Text(Fns.lastSeen(user.lastSeenInEpoch, user.presence), style: TextStyle(fontSize: 12),)),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .doc(chatId)
                      .collection(chatId)
                      .doc(myId)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot<Map>> snapshot) {
                    if (snapshot.hasData) {

                      int count = 0;
                      var data = snapshot.data.data() ?? {};
                      if (data.containsKey('unread_count')) {
                        count = snapshot.data.data()['unread_count'];
                      }
                      if (count > 0)
                        return Container(
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            shape: BoxShape.rectangle,
                            color: Colors.green,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1,horizontal: 8),
                            child: Text('$count unread', style: TextStyle(color: Colors.white, fontSize: 16),),
                          ),
                        );
                      else
                        return Container();
                    } else {
                      return Container();
                    }
                  }),
            ],
          ),
        ));
  }
}
