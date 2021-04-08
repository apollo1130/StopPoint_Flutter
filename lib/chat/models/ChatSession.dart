import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/chat/models/Chat.dart';
import 'package:video_app/auth/models/User.dart';

part 'ChatSession.g.dart';

@JsonSerializable()
class ChatSession {
  List<Chat> chatSessions;

  ChatSession(this.chatSessions);

  getUserFromChatSessions(String id) {
    var index = chatSessions.indexWhere((element) => element.chatWith.id == id);
    return index == -1 ? null : chatSessions[index].chatWith;
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) => _$ChatSessionFromJson(json);
  Map<String, dynamic> toJson() => _$ChatSessionToJson(this);
}
