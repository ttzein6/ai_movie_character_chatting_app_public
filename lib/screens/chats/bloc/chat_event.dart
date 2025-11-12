part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

class SendMessage extends ChatEvent {
  String text;
  SendMessage({required this.text});
}

class InitializeChat extends ChatEvent {
  CastCharacter character;
  InitializeChat({required this.character});
}

class ClearChat extends ChatEvent {}
