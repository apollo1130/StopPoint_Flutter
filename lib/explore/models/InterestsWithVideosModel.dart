
import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/questions/models/QuestionData.dart';

part 'InterestsWithVideosModel.g.dart';

@JsonSerializable()
class InterestsWithVideosModel {

  Interest interest;
  List<QuestionData> videos;

  InterestsWithVideosModel(this.interest, this.videos);


  factory InterestsWithVideosModel.fromJson(Map<String, dynamic> json) => _$InterestsWithVideosModelFromJson(json);
  Map<String, dynamic> toJson() => _$InterestsWithVideosModelToJson(this);
}