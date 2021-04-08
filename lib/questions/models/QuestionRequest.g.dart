// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QuestionRequest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionRequest _$QuestionRequestFromJson(Map<String, dynamic> json) {
  return QuestionRequest(
    type: _$enumDecodeNullable(_$QuestionTypeEnumMap, json['type']),
    userSenderId: json['userSenderId'] as String,
    userReceiverId: json['userReceiverId'] as String,
    interestId: json['interestId'] as String,
    questionData: json['questionData'] == null
        ? null
        : QuestionData.fromJson(json['questionData'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$QuestionRequestToJson(QuestionRequest instance) =>
    <String, dynamic>{
      'type': _$QuestionTypeEnumMap[instance.type],
      'userSenderId': instance.userSenderId,
      'userReceiverId': instance.userReceiverId,
      'interestId': instance.interestId,
      'questionData': instance.questionData,
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

const _$QuestionTypeEnumMap = {
  QuestionType.USER_QUESTION: 'USER_QUESTION',
  QuestionType.GENERAL_QUESTION: 'GENERAL_QUESTION',
};
