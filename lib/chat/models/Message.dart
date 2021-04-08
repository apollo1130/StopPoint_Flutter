import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/auth/models/User.dart';

part 'Message.g.dart';

@JsonSerializable()
class Message {
  User from;
  String txt;
  DateTime createdAt;

  Message(this.from, this.txt, this.createdAt);

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
