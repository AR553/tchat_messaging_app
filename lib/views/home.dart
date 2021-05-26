import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/models/user.dart';
import 'package:tchat_messaging_app/services/auth.dart';
import 'package:tchat_messaging_app/services/database.dart';

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
                    return PersonTile(user: user);
                  },
                );
              else
                return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}

class PersonTile extends StatelessWidget {
  const PersonTile({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;

  String lastSeen(){
    DateTime lastSeen =
    DateTime.fromMillisecondsSinceEpoch(user.lastSeenInEpoch);
    DateTime currentDateTime = DateTime.now();

    Duration differenceDuration = currentDateTime.difference(lastSeen);
    String durationString = differenceDuration.inSeconds > 59
        ? differenceDuration.inMinutes > 59
        ? differenceDuration.inHours > 23
        ? '${differenceDuration.inDays} ${differenceDuration.inDays == 1 ? 'day' : 'days'}'
        : '${differenceDuration.inHours} ${differenceDuration.inHours == 1 ? 'hour' : 'hours'}'
        : '${differenceDuration.inMinutes} ${differenceDuration.inMinutes == 1 ? 'minute' : 'minutes'}'
        : 'few moments';

    String presenceString = user.presence ? 'Online' : '$durationString ago';
    return presenceString;
  }
String camelcase(String name){
    String n = '';
    name.split(' ').forEach((word) => n+=word.substring(0,1).toUpperCase()+word.substring(1).toLowerCase()+" " );
    return n;
}
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text('${camelcase(user.name.split('-').last)}'),
        subtitle: Text('${user.email}'),
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
        trailing: Text(lastSeen()));
  }
}
