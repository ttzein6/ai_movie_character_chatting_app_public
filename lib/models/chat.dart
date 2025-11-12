// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ai_char_chat_app/models/message.dart';

class Chat {
  String? id;
  List<Message>? messages;
  Chat({this.id, this.messages});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'messages': messages?.map((x) => x.toMap()).toList(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] != null ? map['id'] as String : null,
      messages: map['messages'] != null
          ? List<Message>.from(
              (map['messages'] as List<dynamic>).map<Message?>(
                (x) => Message.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);
}
