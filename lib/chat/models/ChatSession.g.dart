// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChatSession.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSession _$ChatSessionFromJson(Map<String, dynamic> json) {
  return ChatSession(
    (json['chatSessions'] as List)
        ?.map(
            (e) => e == null ? null : Chat.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ChatSessionToJson(ChatSession instance) =>
    <String, dynamic>{
      'chatSessions': instance.chatSessions,
    };
