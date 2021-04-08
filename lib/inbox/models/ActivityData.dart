import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/questions/models/QuestionData.dart';
part 'ActivityData.g.dart';


@JsonSerializable()
class ActivityData {
  String id;
  String type;
  int createdAt;
  bool read;
  User user;
  QuestionData question;
  User relatedUser;
  String followStatus;


  ActivityData({this.id, this.type, this.createdAt, this.read, this.user,
      this.question, this.relatedUser});

  factory ActivityData.fromJson(Map<String, dynamic> json) => _$ActivityDataFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityDataToJson(this);



}