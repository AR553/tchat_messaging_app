import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:tchat_messaging_app/models/user.dart';

class Database {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  storeUserData() async {
    var u = FirebaseAuth.instance.currentUser;
    DocumentReference documentReference = userCollection.doc(u.uid);
    User user = User(
      name: u.displayName,
      uid: u.uid,
      presence: true,
      lastSeenInEpoch: DateTime.now().microsecondsSinceEpoch,
      email: u.email,
      photoURL: u.photoURL,
    );
    var data = user.toJson();
    await documentReference.set(data).whenComplete(() {
      print("User Data added to cloud firestore.");
    }).catchError((e) => print("Error firestore: $e"));

    // print('adding.....');
    // var database = FirebaseDatabase.instance.reference();
    // try{
    //   await database.child(u.uid).set(data);
    //   database.child(u.uid).once().then((value) {
    //     print('${value.key}: ${value.value}');
    //   });
    // }
    // catch (e){
    //   print('Exception caught: $e');
    // }
    // finally{
    //   print('try block executed.');
    // }
    // print('added');
  }

  Stream<QuerySnapshot> retrieveUsers() {
    Stream<QuerySnapshot> queryUsers = userCollection.orderBy('last_seen', descending: true).snapshots();
    return queryUsers;
  }

  updateUserPresence(bool presence) async {
    Map<String, dynamic> data = {
      'presence': presence,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };

    var u = FirebaseAuth.instance.currentUser;
    DocumentReference documentReference = userCollection.doc(u.uid);
    await documentReference.update(data).whenComplete(() {
      print("User Data updated to cloud firestore.");
    }).catchError((e) => print("Error firestore: $e"));
  }
}
