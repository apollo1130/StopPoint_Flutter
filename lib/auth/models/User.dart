import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/inbox/models/ActivityData.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/questions/models/QuestionData.dart';

part 'User.g.dart';

@JsonSerializable()
class User {
  String id;
  String firstname;
  String lastname;
  String username;
  String email;
  String password;
  String googleId;
  String facebookId;
  String authToken;
  String avatar;
  String bio;
  String job;
  String education;
  double latitude;
  double longitude;
  String live;
  String phone;
  String xmppPassword;
  bool privateProfile;
  bool notificationEnable;
  //Aditional field for some things like recent List
  int timestamp;
  List<QuestionData> questionsReceived;
  List<QuestionData> questionsAnswered;
  List<QuestionData> questionsAsked;
  List<QuestionData> questionsShared;
  List<Interest> interests;
  List<ActivityData> notifications;
  List<User> following;
  List<User> followers;
  bool followNotification;
  bool questionForYouNotification;
  bool directMessagesNotification;
  bool likeNotification;
  bool commentNotification;
  bool answerNotification;
  bool interestQuestionNotification;
  List<User> blockedUsers;
  List<User> blockedUsersForMessages;


  User({this.id, this.firstname, this.lastname, this.email, this.password,
      this.googleId, this.facebookId, this.authToken, this.avatar, this.bio,
      this.job, this.education, this.latitude, this.longitude, this.live, this.username,this.phone, this.xmppPassword});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  ImageProvider avatarImageProvider() {
    String image = this.avatar;
    if (image != null && image.length > 0) {
      if (image.contains("http://") || image.contains("https://")) {
        return CachedNetworkImageProvider(image);
      } else {
        return FileImage(File(image));
      }
    } else {
      return AssetImage('lib/assets/images/defaultUser.png');
    }
  }

  String getFullName() {
    return (this.firstname != null ? StringUtils.capitalize(this.firstname) : '') + ' ' + (this.lastname != null ? StringUtils.capitalize(this.lastname) : '');
  }

  updateUser(User user) {
    this.id = user.id;
    this.firstname = user.firstname;
    this.lastname = user.lastname;
    this.username = user.username;
    this.email = user.email;
    this.password = user.password;
    this.googleId = user.googleId;
    this.facebookId = user.facebookId;
    this.authToken = user.authToken;
    this.avatar  = user.avatar;
    this.bio = user.bio;
    this.job = user.job;
    this.education = user.education;
    this.latitude = user.latitude;
    this.longitude = user.longitude;
    this.phone = user.phone ;
    this.live = user.live;
    this.privateProfile = user.privateProfile;
    this.followNotification = user.followNotification;
    this.questionForYouNotification = user.questionForYouNotification;
    this.directMessagesNotification = user.directMessagesNotification;
    this.likeNotification = user.likeNotification;
    this.commentNotification =  user.commentNotification;
    this.answerNotification = user.answerNotification;
    this.interestQuestionNotification =  user.interestQuestionNotification;
    this.blockedUsers = user.blockedUsers;
    this.blockedUsersForMessages = user.blockedUsersForMessages;
  }


}
