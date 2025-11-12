import 'dart:convert';
import 'package:ai_char_chat_app/models/cast_character.dart';
import 'package:ai_char_chat_app/models/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryItem {
  final CastCharacter character;
  final Chat chat;
  final DateTime lastMessageTime;

  ChatHistoryItem({
    required this.character,
    required this.chat,
    required this.lastMessageTime,
  });
}

class ChatHistoryService {
  /// Gets all chat history from SharedPreferences
  /// Returns a list of ChatHistoryItem sorted by most recent
  Future<List<ChatHistoryItem>> getChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      // Filter keys that start with "chat_"
      final chatKeys = keys.where((key) => key.startsWith('chat_')).toList();

      List<ChatHistoryItem> history = [];

      for (final key in chatKeys) {
        try {
          final chatValue = prefs.getString(key);
          if (chatValue == null || chatValue.isEmpty) continue;

          Chat? chat;
          CastCharacter? character;

          // Try to parse as new format (with character info)
          try {
            final data = Map<String, dynamic>.from(
                const JsonDecoder().convert(chatValue));
            if (data.containsKey('chat') && data.containsKey('character')) {
              chat = Chat.fromMap(data['chat']);
              character = CastCharacter.fromMap(data['character']);
            }
          } catch (_) {}

          // Fallback to old format (just chat)
          if (chat == null) {
            chat = Chat.fromJson(chatValue);

            // Extract character info from key: chat_{characterName}_{movieName}
            final lastUnderscoreIndex = key.lastIndexOf('_');
            final characterName = key.substring(5, lastUnderscoreIndex);
            final movieName = key.substring(lastUnderscoreIndex + 1);

            character = CastCharacter(
              name: characterName,
              movieName: movieName,
              imageUrl: '', // Old format doesn't have imageUrl
            );
          }

          // Skip empty chats
          if (chat.messages == null || chat.messages!.isEmpty) continue;

          history.add(ChatHistoryItem(
            character: character!,
            chat: chat,
            lastMessageTime: DateTime.now(), // We don't store timestamps yet
          ));
        } catch (e) {
          // Skip invalid chat entries
          continue;
        }
      }

      // Sort by most recent (currently all have same time, so keep order)
      history.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      return history;
    } catch (e) {
      return [];
    }
  }

  /// Deletes a specific chat
  Future<void> deleteChat(String characterName, String movieName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_${characterName}_$movieName');
  }

  /// Clears all chat history
  Future<void> clearAllChats() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final chatKeys = keys.where((key) => key.startsWith('chat_')).toList();

    for (final key in chatKeys) {
      await prefs.remove(key);
    }
  }
}
