import 'package:json_annotation/json_annotation.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/models/Interest.dart';


part 'SuggestedAndRecentResponse.g.dart';


@JsonSerializable()
class SuggestedAndRecentResponse {
  List<User> usersSuggested;
  List<Interest> interests;
  List<User> recentUsers;
  List<Interest> recentInterests;


  SuggestedAndRecentResponse({this.usersSuggested, this.interests});

  factory SuggestedAndRecentResponse.fromJson(Map<String, dynamic> json) => _$SuggestedAndRecentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestedAndRecentResponseToJson(this);


}