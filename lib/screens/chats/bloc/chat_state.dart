part of 'chat_bloc.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  // List<ChatMessage> messages;
  Chat chat;
  ChatLoaded({required this.chat});
}
