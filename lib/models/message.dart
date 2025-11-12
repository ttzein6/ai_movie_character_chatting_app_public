// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Message {
  bool? sender;
  String? messageText;
  bool? isSending;
  Message({this.sender, this.messageText, this.isSending});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sender': sender,
      'messageText': messageText,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'] != null ? map['sender'] as bool : null,
      messageText:
          map['messageText'] != null ? map['messageText'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);
}
