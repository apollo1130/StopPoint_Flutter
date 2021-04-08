import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/auth/models/User.dart';
part 'Comment.g.dart';

@JsonSerializable()
class Comment {
  int id;
  String body;
  int date;
  User user;
  List<Comment> answers;
  List<User> upVotes;
  List<User> downVotes;
  Comment parentComment;


  Comment({this.id, this.body, this.date, this.user, this.answers, this.upVotes,
      this.downVotes, this.parentComment});

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);


}