import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/questions/ask/AudienceSelect.dart';
import 'package:video_app/questions/models/Answer.dart';

part 'QuestionData.g.dart';

@JsonSerializable()
class QuestionData {
  String id;
  String text;
  int createdAt;
  int shares;
  bool userShare;
  User userAsked;
  User userReceived;
  Answer answer;
  List<Answer> answers;
  AudienceType privacy;
  bool saveForLater;
  bool archived;
  String job;
  bool appQuestion;
  Interest interest;
  int answerCount;
  int lastAnswer;
  String video;
  String cloudinaryPublicId;

  QuestionData(
      {this.id,
      this.text,
      this.video,
      this.cloudinaryPublicId,
      this.createdAt,
      this.answer,
      this.userAsked,
      this.privacy,
      this.job});

  factory QuestionData.fromJson(Map<String, dynamic> json) =>
      _$QuestionDataFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionDataToJson(this);
}
