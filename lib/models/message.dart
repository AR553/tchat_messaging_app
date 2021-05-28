class Message {
  final String content;
  final String receiverId;
  final String senderId;
  final int timestamp;
  final String type;

  Message({this.type, this.content, this.receiverId, this.senderId, this.timestamp});

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
    };
  }
}

class MessageType{
  static final String text = 'text';
  static final String image = 'image';
  static final String audio = 'audio';
  static final String video = 'video';
}
