// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    json['from'] == null
        ? null
        : User.fromJson(json['from'] as Map<String, dynamic>),
    json['txt'] as String,
    json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'from': instance.from,
      'txt': instance.txt,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
