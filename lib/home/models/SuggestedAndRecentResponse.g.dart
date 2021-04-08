// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SuggestedAndRecentResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuggestedAndRecentResponse _$SuggestedAndRecentResponseFromJson(
    Map<String, dynamic> json) {
  return SuggestedAndRecentResponse(
    usersSuggested: (json['usersSuggested'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    interests: (json['interests'] as List)
        ?.map((e) =>
            e == null ? null : Interest.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )
    ..recentUsers = (json['recentUsers'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..recentInterests = (json['recentInterests'] as List)
        ?.map((e) =>
            e == null ? null : Interest.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$SuggestedAndRecentResponseToJson(
        SuggestedAndRecentResponse instance) =>
    <String, dynamic>{
      'usersSuggested': instance.usersSuggested,
      'interests': instance.interests,
      'recentUsers': instance.recentUsers,
      'recentInterests': instance.recentInterests,
    };
