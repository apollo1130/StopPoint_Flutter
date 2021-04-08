import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';

import 'package:video_app/core/widgets/VideoContainer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:basic_utils/basic_utils.dart';

class FullVideoWidget extends StatefulWidget {
  FullVideoWidget({Key key, @required this.videoPath, this.question})
      : super(key: key);

  final String videoPath;
  final QuestionData question;

  @override
  _FullVideoWidgetState createState() => _FullVideoWidgetState();
}

class _FullVideoWidgetState extends State<FullVideoWidget> {
  User _userLogged;

  @override
  void initState() {
    super.initState();
    boot();
  }

  void boot() {
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: VideoContainer(
          videoPath: widget.videoPath,
          question: widget.question,
          userLogged: _userLogged,
        ),);
  }
}
