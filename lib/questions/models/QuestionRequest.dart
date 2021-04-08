import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/questions/models/QuestionData.dart';
part 'QuestionRequest.g.dart';


enum QuestionType {
  USER_QUESTION,
  GENERAL_QUESTION
}
@JsonSerializable()
class QuestionRequest {
  QuestionType type;
  String userSenderId;
  String userReceiverId;
  String interestId;
  QuestionData questionData;


  QuestionRequest({this.type, this.userSenderId, this.userReceiverId,
      this.interestId, this.questionData});

  factory QuestionRequest.fromJson(Map<String, dynamic> json) => _$QuestionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionRequestToJson(this);



}

