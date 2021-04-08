// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Interest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Interest _$InterestFromJson(Map<String, dynamic> json) {
  return Interest(
    label: json['label'] as String,
    icon: json['icon'] as String,
    id: json['id'] as String,
  )..timestamp = json['timestamp'] as int;
}

Map<String, dynamic> _$InterestToJson(Interest instance) => <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'icon': instance.icon,
      'timestamp': instance.timestamp,
    };
