import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/models/message.dart';
import 'package:tchat_messaging_app/models/user.dart';
import 'package:tchat_messaging_app/services/database.dart';
import 'package:tchat_messaging_app/utilities/functions.dart';

import 'custom_widgets/chat_app_bar.dart';
import 'custom_widgets/message_box.dart';

class ChatPage extends StatefulWidget {
  final User user;

  ChatPage({Key key, this.user}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final myself = FirebaseAuth.instance.currentUser;
  final _messageController = TextEditingController();

  Future<String> getFile(FileType fileType) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: fileType,
        withData: true,
        allowCompression: true,
        onFileLoading: (status) => Center(child: Text('Loading')));

    if (result != null)
      return result.paths.first;
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
      appBar: ChatAppBar(chatId, widget.user),
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
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: CustomPopupMenu(
                    showArrow: false,
                    barrierColor: Colors.transparent,
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                    menuBuilder: () => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey,
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.image),
                            onPressed: () {
                              getFile(FileType.image).then((value) => send(value, MessageType.image));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.mic),
                            onPressed: () {
                              getFile(FileType.audio).then((value) => send(value, MessageType.audio));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.video_call),
                            onPressed: () {
                              getFile(FileType.video).then((value) => send(value, MessageType.video));
                            },
                          ),
                        ],
                      ),
                    ),
                    pressType: PressType.singleClick,
                  ),
                ),
                SizedBox(width: 15),
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
                SizedBox(width: 15),
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
}


