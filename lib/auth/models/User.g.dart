// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'User.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as String,
    firstname: json['firstname'] as String,
    lastname: json['lastname'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    googleId: json['googleId'] as String,
    facebookId: json['facebookId'] as String,
    authToken: json['authToken'] as String,
    avatar: json['avatar'] as String,
    bio: json['bio'] as String,
    job: json['job'] as String,
    phone: json['phone']as String,
    education: json['education'] as String,
    latitude: (json['latitude'] as num)?.toDouble(),
    longitude: (json['longitude'] as num)?.toDouble(),
    live: json['live'] as String,
    username: json['username'] as String,
    xmppPassword: json['xmppPassword'] as String,
  )
    ..privateProfile = json['privateProfile'] as bool
    ..notificationEnable = json['notificationEnable'] as bool
    ..timestamp = json['timestamp'] as int
    ..questionsReceived = (json['questionsReceived'] as List)
        ?.map((e) =>
            e == null ? null : QuestionData.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..questionsAnswered = (json['questionsAnswered'] as List)
        ?.map((e) =>
            e == null ? null : QuestionData.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..questionsAsked = (json['questionsAsked'] as List)
        ?.map((e) =>
            e == null ? null : QuestionData.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..questionsShared = (json['questionsShared'] as List)
        ?.map((e) =>
            e == null ? null : QuestionData.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..interests = (json['interests'] as List)
        ?.map((e) =>
            e == null ? null : Interest.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..notifications = (json['notifications'] as List)
        ?.map((e) =>
            e == null ? null : ActivityData.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..following = (json['following'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..followers = (json['followers'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..followNotification = json['followNotification'] as bool
    ..questionForYouNotification = json['questionForYouNotification'] as bool
    ..directMessagesNotification = json['directMessagesNotification'] as bool
    ..likeNotification = json['likeNotification'] as bool
    ..commentNotification = json['commentNotification'] as bool
    ..answerNotification = json['answerNotification'] as bool
    ..interestQuestionNotification =
        json['interestQuestionNotification'] as bool
    ..blockedUsers = (json['blockedUsers'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..blockedUsersForMessages = (json['blockedUsersForMessages'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'googleId': instance.googleId,
      'facebookId': instance.facebookId,
      'authToken': instance.authToken,
      'avatar': instance.avatar,
      'bio': instance.bio,
      'job': instance.job,
      'education': instance.education,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'live': instance.live,
      'phone': instance.phone,
      'xmppPassword': instance.xmppPassword,
      'privateProfile': instance.privateProfile,
      'notificationEnable': instance.notificationEnable,
      'timestamp': instance.timestamp,
      'questionsReceived': instance.questionsReceived,
      'questionsAnswered': instance.questionsAnswered,
      'questionsAsked': instance.questionsAsked,
      'questionsShared': instance.questionsShared,
      'interests': instance.interests,
      'notifications': instance.notifications,
      'following': instance.following,
      'followers': instance.followers,
      'followNotification': instance.followNotification,
      'questionForYouNotification': instance.questionForYouNotification,
      'directMessagesNotification': instance.directMessagesNotification,
      'likeNotification': instance.likeNotification,
      'commentNotification': instance.commentNotification,
      'answerNotification': instance.answerNotification,
      'interestQuestionNotification': instance.interestQuestionNotification,
      'blockedUsers': instance.blockedUsers,
      'blockedUsersForMessages': instance.blockedUsersForMessages,
    };
