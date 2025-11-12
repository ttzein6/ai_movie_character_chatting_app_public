import 'dart:convert';
import 'dart:developer';
import 'package:ai_char_chat_app/models/cast_character.dart';
import 'package:ai_char_chat_app/models/chat.dart';
import 'package:ai_char_chat_app/models/message.dart';
import 'package:ai_char_chat_app/services/api_key_service.dart';
import 'package:bloc/bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    CastCharacter? character;
    Chat? chat;
    on<ClearChat>((event, emit) async {
      chat = Chat(id: character?.name, messages: []);
      await saveChatToPref(character, chat).then((_) {
        emit(ChatLoaded(chat: chat!));
      });
    });
    on<InitializeChat>((event, emit) async {
      chat = null;
      character = event.character;

      emit(ChatLoading());
      await getChatIfFound(character).then((value) {
        if (value == false) {
          chat = Chat(id: character?.name, messages: []);
          emit(ChatLoaded(chat: chat!));
        } else {
          log("CHAT ${value.runtimeType}");
          if (value is Chat) {
            // log("HERE ${(value as Chat).messages?[0].messageText}");
            chat = value;
            emit(ChatLoaded(chat: value));
          } else {
            chat = Chat(id: character?.name, messages: []);
            emit(ChatLoaded(chat: chat!));
          }
        }
      }).catchError((e) {
        log("Error loading chat from local db :\n$e");
        chat = Chat(id: character?.name, messages: []);
        emit(ChatLoaded(chat: chat!));
      });
    });
    on<SendMessage>((event, emit) async {
      ///[Sending message state]
      List<Message> tempMessages = chat?.messages ?? [];
      tempMessages
          .add(Message(sender: true, messageText: event.text, isSending: true));
      chat?.messages = tempMessages;
      emit(ChatLoaded(chat: chat!));

      ///[Api call]
      await sendMessage(character!, event.text, chat?.messages ?? [])
          .then((value) {
        ///[Set New State with new message added]
        var lastMessage = tempMessages[tempMessages.length - 1];
        lastMessage.isSending = false;
        tempMessages[tempMessages.length - 1] = lastMessage;
        tempMessages
            .add(Message(sender: false, messageText: value, isSending: false));
        chat?.messages = tempMessages;
        emit(ChatLoaded(chat: chat!));
      }).catchError((e) {
        ///[Todo :show error dialog]
        tempMessages.removeLast();
        chat?.messages = tempMessages;
        emit(ChatLoaded(chat: chat!));
      });
      saveChatToPref(character, chat);
    });
  }
  Future getChatIfFound(character) async {
    var pref = await SharedPreferences.getInstance();
    var chatValue =
        pref.getString("chat_${character?.name}_${character?.movieName}");
    if (chatValue == null || chatValue.isEmpty) {
      return false;
    } else {
      // Try to parse as new format (with character info)
      try {
        final data = json.decode(chatValue);
        if (data is Map<String, dynamic> && data.containsKey('chat')) {
          return Chat.fromMap(data['chat']);
        }
      } catch (_) {}
      // Fallback to old format (just chat)
      return Chat.fromJson(chatValue);
    }
  }

  Future saveChatToPref(character, chat) async {
    var pref = await SharedPreferences.getInstance();
    // Store both character and chat information
    final data = {
      'character': character?.toMap(),
      'chat': chat!.toMap(),
    };
    await pref.setString("chat_${character?.name}_${character?.movieName}",
        json.encode(data));
  }

  Future<String?> sendMessage(CastCharacter character, String sentMessage,
      List<Message> messages) async {
    try {
      // Get user's Gemini API key
      final apiKeyService = ApiKeyService();
      final apiKey = await apiKeyService.getGeminiApiKey();

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
            'Gemini API key not found. Please configure it in settings.');
      }

      // Initialize the Gemini model with user's API key
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      // Build conversation history for context
      String conversationHistory = '';
      for (var i = 0; i < messages.length; i++) {
        final role = messages[i].sender == true ? 'User' : character.name;
        conversationHistory += '$role: ${messages[i].messageText}\n';
      }

      // Create system prompt to set character persona
      String systemPrompt =
          '''You are ${character.name} from ${character.movieName}.
You must stay in character at all times and respond exactly as ${character.name} would.
- Use ${character.name}'s personality, speech patterns, and mannerisms
- Reference events and relationships from ${character.movieName}
- Never break character or mention that you are an AI
- Keep responses conversational and authentic to ${character.name}
- Answer in English

Previous conversation:
$conversationHistory

User: $sentMessage
${character.name}:''';

      log("Sending message to Gemini: $sentMessage");
      log("System prompt: $systemPrompt");

      // Generate response using Gemini
      final response =
          await model.generateContent([Content.text(systemPrompt)]);

      if (response.text != null && response.text!.isNotEmpty) {
        log("Gemini response: ${response.text}");
        return response.text;
      } else {
        log("Empty response from Gemini");
        throw Exception("No response generated");
      }
    } catch (e) {
      log("ERROR OCCURRED with Gemini: $e");
      rethrow;
    }
  }
}
