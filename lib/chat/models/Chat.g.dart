// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) {
  return Chat(
    json['chatWith'] == null
        ? null
        : User.fromJson(json['chatWith'] as Map<String, dynamic>),
    (json['messages'] as List)
        ?.map((e) =>
            e == null ? null : Message.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'chatWith': instance.chatWith,
      'messages': instance.messages,
    };
