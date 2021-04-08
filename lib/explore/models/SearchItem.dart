import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/questions/ask/AudienceSelect.dart';

part 'SearchItem.g.dart';

@JsonSerializable()
class SearchItem {
  int createdAt;
  String text;
  String id;
  bool archived;
  bool saveForLater;
  bool appQuestion;
  AudienceType privacy;
  String icon;
  String label;
  String firstname;
  String password;
  String spaces;
  String bio;
  String avatar;
  String email;
  String username;
  String lastname;
  String googleId;
  String education;
  String job;
  String facebookId;
  bool privateProfile;
  Interest interest;
  SearchItem({
    this.createdAt,
    this.text,
    this.id,
    this.archived,
    this.saveForLater,
    this.appQuestion,
    this.icon,
    this.label,
    this.firstname,
    this.password,
    this.spaces,
    this.bio,
    this.avatar,
    this.email,
    this.username,
    this.lastname,
    this.googleId,
    this.education,
    this.job,
    this.facebookId,
    this.privateProfile,
    this.interest
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) => _$SearchItemFromJson(json);
  Map<String, dynamic> toJson() => _$SearchItemToJson(this);

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
    return StringUtils.capitalize(StringUtils.defaultString(this.firstname, defaultStr: '')) + ' ' + (this.lastname != null ? StringUtils.capitalize(this.lastname) : '');
  }
}


