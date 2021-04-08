// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QuestionData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionData _$QuestionDataFromJson(Map<String, dynamic> json) {
  return QuestionData(
    id: json['id'] as String,
    text: json['text'] as String,
    createdAt: json['createdAt'] as int,
    answer: json['answer'] == null
        ? null
        : Answer.fromJson(json['answer'] as Map<String, dynamic>),
    userAsked: json['userAsked'] == null
        ? null
        : User.fromJson(json['userAsked'] as Map<String, dynamic>),
    privacy: _$enumDecodeNullable(_$AudienceTypeEnumMap, json['privacy']),
    job: json['job'] as String,
  )
    ..shares = json['shares'] as int
    ..userShare = json['userShare'] as bool
    ..userReceived = json['userReceived'] == null
        ? null
        : User.fromJson(json['userReceived'] as Map<String, dynamic>)
    ..answers = (json['answers'] as List)
        ?.map((e) =>
            e == null ? null : Answer.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..saveForLater = json['saveForLater'] as bool
    ..archived = json['archived'] as bool
    ..appQuestion = json['appQuestion'] as bool
    ..interest = json['interest'] == null
        ? null
        : Interest.fromJson(json['interest'] as Map<String, dynamic>)
    ..answerCount = json['answerCount'] as int
    ..lastAnswer = json['lastAnswer'] as int;
}

Map<String, dynamic> _$QuestionDataToJson(QuestionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'createdAt': instance.createdAt,
      'shares': instance.shares,
      'userShare': instance.userShare,
      'userAsked': instance.userAsked,
      'userReceived': instance.userReceived,
      'answer': instance.answer,
      'answers': instance.answers,
      'privacy': _$AudienceTypeEnumMap[instance.privacy],
      'saveForLater': instance.saveForLater,
      'archived': instance.archived,
      'job': instance.job,
      'appQuestion': instance.appQuestion,
      'interest': instance.interest,
      'answerCount': instance.answerCount,
      'lastAnswer': instance.lastAnswer,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$AudienceTypeEnumMap = {
  AudienceType.Public: 'Public',
  AudienceType.Anonymous: 'Anonymous',
  AudienceType.Limited: 'Limited',
};
