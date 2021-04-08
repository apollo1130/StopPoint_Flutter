// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ActivityData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityData _$ActivityDataFromJson(Map<String, dynamic> json) {
  return ActivityData(
    id: json['id'] as String,
    type: json['type'] as String,
    createdAt: json['createdAt'] as int,
    read: json['read'] as bool,
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    question: json['question'] == null
        ? null
        : QuestionData.fromJson(json['question'] as Map<String, dynamic>),
    relatedUser: json['relatedUser'] == null
        ? null
        : User.fromJson(json['relatedUser'] as Map<String, dynamic>),
  )..followStatus = json['followStatus'] as String;
}

Map<String, dynamic> _$ActivityDataToJson(ActivityData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'createdAt': instance.createdAt,
      'read': instance.read,
      'user': instance.user,
      'question': instance.question,
      'relatedUser': instance.relatedUser,
      'followStatus': instance.followStatus,
    };
