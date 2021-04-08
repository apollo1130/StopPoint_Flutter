// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return Comment(
    id: json['id'] as int,
    body: json['body'] as String,
    date: json['date'] as int,
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    answers: (json['answers'] as List)
        ?.map((e) =>
            e == null ? null : Comment.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    upVotes: (json['upVotes'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    downVotes: (json['downVotes'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    parentComment: json['parentComment'] == null
        ? null
        : Comment.fromJson(json['parentComment'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'body': instance.body,
      'date': instance.date,
      'user': instance.user,
      'answers': instance.answers,
      'upVotes': instance.upVotes,
      'downVotes': instance.downVotes,
      'parentComment': instance.parentComment,
    };
