import 'package:flutter/material.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class CoreProvider extends ChangeNotifier {

  List<Interest> interests = List<Interest>();
  List<QuestionData> feedQuestions = List<QuestionData>();
  List<String> viewedVideos = List<String>();
}