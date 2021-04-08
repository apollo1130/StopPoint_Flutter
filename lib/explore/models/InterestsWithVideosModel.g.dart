// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'InterestsWithVideosModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterestsWithVideosModel _$InterestsWithVideosModelFromJson(
    Map<String, dynamic> json) {
  return InterestsWithVideosModel(
    json['interest'] == null
        ? null
        : Interest.fromJson(json['interest'] as Map<String, dynamic>),
    (json['videos'] as List)
        ?.map((e) =>
            e == null ? null : QuestionData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$InterestsWithVideosModelToJson(
        InterestsWithVideosModel instance) =>
    <String, dynamic>{
      'interest': instance.interest,
      'videos': instance.videos,
    };
