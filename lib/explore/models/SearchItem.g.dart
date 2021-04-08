// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SearchItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchItem _$SearchItemFromJson(Map<String, dynamic> json) {
  return SearchItem(
    createdAt: json['createdAt'] as int,
    text: json['text'] as String,
    id: json['id'] as String,
    archived: json['archived'] as bool,
    saveForLater: json['saveForLater'] as bool,
    appQuestion: json['appQuestion'] as bool,
    icon: json['icon'] as String,
    label: json['label'] as String,
    firstname: json['firstname'] as String,
    password: json['password'] as String,
    spaces: json['spaces'] as String,
    bio: json['bio'] as String,
    avatar: json['avatar'] as String,
    email: json['email'] as String,
    username: json['username'] as String,
    lastname: json['lastname'] as String,
    googleId: json['googleId'] as String,
    education: json['education'] as String,
    job: json['job'] as String,
    facebookId: json['facebookId'] as String,
    privateProfile: json['privateProfile'] as bool,
    interest: json['interest'] == null
        ? null
        : Interest.fromJson(json['interest'] as Map<String, dynamic>),
  )..privacy = _$enumDecodeNullable(_$AudienceTypeEnumMap, json['privacy']);
}

Map<String, dynamic> _$SearchItemToJson(SearchItem instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'text': instance.text,
      'id': instance.id,
      'archived': instance.archived,
      'saveForLater': instance.saveForLater,
      'appQuestion': instance.appQuestion,
      'privacy': _$AudienceTypeEnumMap[instance.privacy],
      'icon': instance.icon,
      'label': instance.label,
      'firstname': instance.firstname,
      'password': instance.password,
      'spaces': instance.spaces,
      'bio': instance.bio,
      'avatar': instance.avatar,
      'email': instance.email,
      'username': instance.username,
      'lastname': instance.lastname,
      'googleId': instance.googleId,
      'education': instance.education,
      'job': instance.job,
      'facebookId': instance.facebookId,
      'privateProfile': instance.privateProfile,
      'interest': instance.interest,
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
