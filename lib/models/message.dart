import 'package:floor/floor.dart';
import 'package:tchat_messaging_app/utilities/functions.dart';

@entity
class Message {
  final String content;
  final String receiverId;
  final String senderId;
  final String chatId;
  @primaryKey
  final int timestamp;
  final String type;

  Message({this.type, this.content, this.receiverId, this.senderId, this.timestamp}):chatId=Fns.getChatId(receiverId);

  static fromJson(Map<String, dynamic> json){
    return Message(
      content:  json['content'],
      receiverId: json['receiver_id'],
      senderId: json['sender_id'],
      timestamp: json['timestamp'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'content':content,
      'receiver_id': receiverId,
      'sender_id':senderId,
      'timestamp': timestamp,
      'type':type,
      'chat_id': chatId
    };
  }
}
