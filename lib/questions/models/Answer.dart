import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/feed/models/Comment.dart';


part 'Answer.g.dart';



@JsonSerializable()
class Answer {
  String id;
  String video;
  int createdAt;
  User userAnswered;
  bool userDownVote;
  bool userUpVote;
  int upVotes;
  int downVotes;
  int views;
  bool localView;
  int likes;
  bool userLike;
  List<Comment> comments;

  Answer({this.id, this.video});

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerToJson(this);

  String getVideoCompress() {
     return video.split("upload").join("upload/q_auto,vc_auto");
  }
}