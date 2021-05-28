import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tchat_messaging_app/models/message.dart';
import 'package:tchat_messaging_app/models/user.dart';
import 'package:tchat_messaging_app/services/database.dart';
import 'package:tchat_messaging_app/utilities/functions.dart';

class ChatPage extends StatefulWidget {
  final User user;

  ChatPage({Key key, this.user}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final myself = FirebaseAuth.instance.currentUser;
  final _messageController = TextEditingController();
  final picker = ImagePicker();

  Future<String> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null)
      return pickedFile.path;
    else
      return null;
  }

  String chatId;
  int count;

  @override
  void initState() {
    Database().resetUnread(widget.user.uid);
    chatId = Fns.getChatId(widget.user.uid);
    Timer.periodic(Duration(seconds: 5), (timer) {
      Database().updateTypingStatus(chatId, false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: Image.network(widget.user.photoURL).image,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width*.4,
                child: Text(
                  '${Fns.camelcase(widget.user.name.split('-').last)}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(chatId)
                    .collection(chatId)
                    .doc(widget.user.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.data()['typing_status'])
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
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text(Fns.lastSeen(widget.user.lastSeenInEpoch, widget.user.presence))),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatId)
                  .collection(chatId)
                  .orderBy('timestamp', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error));
                } else if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> messages = snapshot.data.docs;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => MessageBox(Message.fromJson(messages[index].data())),
                    itemCount: messages.length,
                    reverse: true,
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
            height: 60,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    String path = await getImage();
                    send(path, MessageType.image);
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none),
                    onChanged: (value) {
                      value = value.trim();
                      Database().updateTypingStatus(chatId, value.isNotEmpty);
                    },
                    onSubmitted: (value) {
                      send(_messageController.text, MessageType.text);
                    },
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                FloatingActionButton(
                  onPressed: () => send(_messageController.text, MessageType.text),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                  backgroundColor: Colors.blue,
                  elevation: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void send(String content, String type) {
    content = content.trim();
    if (content.isNotEmpty) {
      var message = Message(
          content: content,
          senderId: myself.uid,
          type: type,
          receiverId: widget.user.uid,
          timestamp: DateTime.now().millisecondsSinceEpoch);

      if (type == MessageType.text) _messageController.clear();

      Database().onSendMessage(message, widget.user.uid);
    } else {
      //TODO
      // Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(QueryDocumentSnapshot msg) {
    Message message = Message.fromJson(msg.data());
    return Container(
      padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment: (message.receiverId == myself.uid ? Alignment.topLeft : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (message.receiverId == myself.uid ? Colors.grey.shade200 : Colors.blue[200]),
          ),
          padding: EdgeInsets.all(16),
          child: message.type == MessageType.text
              ? SelectableText(
                  message.content,
                  style: TextStyle(fontSize: 15),
                )
              : Container(
                  child: Material(
                    child: CachedNetworkImage(
                      placeholder: (context, _) => Container(
                        child: CircularProgressIndicator(),
                        width: 200.0,
                        height: 200.0,
                        padding: EdgeInsets.all(70.0),
                      ),
                      errorWidget: (context, _, __) => Material(
                        child: Image.asset(
                          'images/img_not_available.jpeg',
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                      imageUrl: message.content,
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
        ),
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  MessageBox(this.message, {Key key}) : super(key: key);
  final String myId = FirebaseAuth.instance.currentUser.uid;
  final Message message;

  @override
  Widget build(BuildContext context) {
    print(message.content);
    return Container(
      padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment: (message.receiverId == myId ? Alignment.topLeft : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (message.receiverId == myId ? Colors.grey.shade200 : Colors.blue[200]),
          ),
          padding: EdgeInsets.all(16),
          child: message.type == MessageType.text
              ? SelectableText(
                  message.content,
                  style: TextStyle(fontSize: 15),
                )
              : Container(
                  child: Material(
                    child: CachedNetworkImage(
                      placeholder: (context, _) => Container(
                        child: CircularProgressIndicator(),
                        width: 200.0,
                        height: 200.0,
                        padding: EdgeInsets.all(70.0),
                      ),
                      errorWidget: (context, _, __) => Material(
                        child: Text('Image cannot be opened.'),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                      imageUrl: message.content,
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
        ),
      ),
    );
  }
}
