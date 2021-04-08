// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) {
  return Answer(
    id: json['id'] as String,
    video: json['video'] as String,
  )
    ..createdAt = json['createdAt'] as int
    ..userAnswered = json['userAnswered'] == null
        ? null
        : User.fromJson(json['userAnswered'] as Map<String, dynamic>)
    ..userDownVote = json['userDownVote'] as bool
    ..userUpVote = json['userUpVote'] as bool
    ..upVotes = json['upVotes'] as int
    ..downVotes = json['downVotes'] as int
    ..views = json['views'] as int
    ..localView = json['localView'] as bool
    ..likes = json['likes'] as int
    ..userLike = json['userLike'] as bool
    ..comments = (json['comments'] as List)
        ?.map((e) =>
            e == null ? null : Comment.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
      'id': instance.id,
      'video': instance.video,
      'createdAt': instance.createdAt,
      'userAnswered': instance.userAnswered,
      'userDownVote': instance.userDownVote,
      'userUpVote': instance.userUpVote,
      'upVotes': instance.upVotes,
      'downVotes': instance.downVotes,
      'views': instance.views,
      'localView': instance.localView,
      'likes': instance.likes,
      'userLike': instance.userLike,
      'comments': instance.comments,
    };
