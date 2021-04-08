import 'package:json_annotation/json_annotation.dart';


part 'Interest.g.dart';


@JsonSerializable()
class Interest {

  String id;
  String label;
  String icon;
  int timestamp;

  Interest({this.label, this.icon, this.id});

  factory Interest.fromJson(Map<String, dynamic> json) => _$InterestFromJson(json);

  Map<String, dynamic> toJson() => _$InterestToJson(this);

}