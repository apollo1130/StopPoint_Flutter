import 'dart:async';

import 'package:basic_utils/basic_utils.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/DynamicLinkProvider.dart';
import 'package:video_app/feed/api/FeedApiService.dart';
import 'package:video_app/feed/widgets/CommentsWidget.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoContainer extends StatefulWidget {
  VideoContainer({
    Key key,
    @required this.videoPath,
    @required this.question,
    @required this.userLogged,
  }) : super(key: key);

  final String videoPath;
  final QuestionData question;
  final User userLogged;

  @override
  VideoContainerState createState() => VideoContainerState(
        videoPath: videoPath,
        question: question,
        userLogged: userLogged,
      );
}

class VideoContainerState extends State<VideoContainer> {
  VideoContainerState({
    Key key,
    @required this.videoPath,
    @required this.question,
    @required this.userLogged,
  });

  User _userLogged;
  Timer _invisibilty;
  String videoPath;
  QuestionData question;
  User userLogged;
  CachedVideoPlayerController _controller;
  String strTime = '00:00';
  bool _visible = true;

  @override
  void initState() {
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    _controller = CachedVideoPlayerController.network(videoPath);
    // print('########### VIDEO PLAYER ${widget.question.answers.length}');
    //print('########### VIDEO PLAYER${widget.question.answer}');
    bootPlayer();
    super.initState();
  }

  void bootPlayer() {
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      _controller.addListener(() {
        if (_controller.value.isPlaying) {
          setState(() {
            strTime = _printDuration(
              _controller.value.duration - _controller.value.position,
            );
          });
        }
      });
    });
    _controller.play();
    _initializeTimer();
  }

  void _initializeTimer() {
    if (_controller.value.isPlaying) {
      if (_invisibilty != null) {
        _invisibilty.cancel();
      }

      _invisibilty = Timer(const Duration(seconds: 3), _triggerInvisibility);
    }
  }

  void _triggerInvisibility() {
    setState(() {
      _visible = false;
    });
  }

  @override
  void dispose() {
    print("Should dispose");
    _controller?.pause();
    _controller.dispose();
    _controller = null;
    super.dispose();
  }

  Widget animatedOpacityWidget(Widget _widget) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: _widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          _visible = true;
        });
        _initializeTimer();
      },
      child: SafeArea(
        child: Stack(
          // alignment: Alignment.,
          // mainAxisSize: MainAxisSize.min,
          children: [
            // SizedBox(
            //   height: 10.0,
            // ),

            // SizedBox(
            //   height: 5,
            // ),
            // Container(
            //   height: 5,
            // ),

            CachedVideoPlayer(_controller),
            // animatedOpacityWidget(
            //   Container(
            //     child: _receiverInfo(widget.question),
            //     padding: EdgeInsets.symmetric(horizontal: 10.0),
            //   ),
            // ),
            // SizedBox(
            //   height: 20.0,
            // ),

            // animatedOpacityWidget(
            //   Container(
            //     padding: EdgeInsets.symmetric(
            //       horizontal: 16.0,
            //       vertical: 10.0,
            //     ),
            //     child: Row(
            //       children: [
            //         _individualItem(
            //           FlutterIcons.thumbs_up_fea,
            //           "",
            //           answerId: widget.question.answer == null?widget.question.answers[0].id:widget.question.answer.id,
            //           f: _upVote,
            //           userAffected: widget.question.answer == null?widget.question.answers[0].userUpVote:widget.question.answer.userUpVote,
            //         ),
            //         VerticalDivider(
            //           width: 20,
            //         ),
            //         _individualItem(
            //           FontAwesomeIcons.comment,
            //           '',
            //           answerId: widget.question.answer == null?question.answers[0].id:question.answer.id,
            //           f: _comments,
            //         ),
            //         VerticalDivider(
            //           width: 20,
            //         ),
            //         _individualItem(
            //           FlutterIcons.send_fea,
            //           '',
            //           questionId: question.id,
            //           type: question.interest != null ? "interest" : "follow",
            //           answerId: widget.question.answer == null?question.answers[0].id:question.answer.id,
            //           f: _share,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // TODO: Question Answer
            animatedOpacityWidget(
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    // alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: animatedOpacityWidget(
                      Row(
                        children: [
                          Text(
                            "${widget.question.answers != null ? question.answers[0].likes : 0} Like",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            child: Text(
                              "•",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                          ),
                          Text(
                            "${widget.question.answers != null ? question.answers[0].comments != null ? question.answers[0].comments : 0 : 0} Comment",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    // margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        IconButton(
                            icon: Icon(
                                (_controller.value.isPlaying)
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white),
                            onPressed: () {
                              (_controller.value.isPlaying)
                                  ? _controller.pause()
                                  : _controller.play();
                              setState(() {});
                            }),
                        SizedBox(width: 0),
                        Expanded(
                            child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors:
                              VideoProgressColors(playedColor: Colors.white),
                        )),
                        SizedBox(width: 5),
                        Text(
                          strTime,
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  // Container(
                  //   padding:
                  //       EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  //   child: Row(
                  //     children: [
                  //       _individualItem(
                  //         FlutterIcons.thumbs_up_fea,
                  //         "",
                  //         answerId: widget.question.answer == null
                  //             ? widget.question.answers[0].id
                  //             : widget.question.answer.id,
                  //         f: _upVote,
                  //         userAffected: widget.question.answer == null
                  //             ? widget.question.answers[0].userUpVote
                  //             : widget.question.answer.userUpVote,
                  //       ),
                  //       VerticalDivider(
                  //         width: 20,
                  //       ),
                  //       _individualItem(
                  //         FontAwesomeIcons.comment,
                  //         '',
                  //         answerId: widget.question.answer == null
                  //             ? question.answers[0].id
                  //             : question.answer.id,
                  //         f: _comments,
                  //       ),
                  //       VerticalDivider(
                  //         width: 20,
                  //       ),
                  //       _individualItem(
                  //         FlutterIcons.send_fea,
                  //         '',
                  //         questionId: question.id,
                  //         type:
                  //             question.interest != null ? "interest" : "follow",
                  //         answerId: widget.question.answer == null
                  //             ? question.answers[0].id
                  //             : question.answer.id,
                  //         f: _share,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
            //TODO:  Question
            // animatedOpacityWidget(
            //   Container(
            //     alignment: Alignment.topCenter,
            //     padding: EdgeInsets.symmetric(
            //       horizontal: 10.0,
            //     ),
            //     width: double.infinity,
            //     child: Text(
            //       StringUtils.capitalize(widget.question.text) + '?',
            //       style: TextStyle(
            //         fontSize: 14.0,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            animatedOpacityWidget(
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        //size: 30.0,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      width: double.infinity,
                      child: Text(
                        StringUtils.capitalize(widget.question.text) + '?',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      child: _receiverInfo(widget.question),
                      padding: EdgeInsets.symmetric(horizontal: 0.0),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _upVote(String answerId) async {
    Response response =
        await FeedApiService().upVote(widget.userLogged.id, answerId);
    if (response.statusCode == 200) {}
  }

  _share(String answerId, {String questionId, String type}) async {
    var link = await DynamicLinkProvider.generateDynamicLink(
        "question",
        Map<String, dynamic>.from(
          {"qid": questionId, "type": type},
        ),question);
    final ShortDynamicLink shortenedLink =
        await DynamicLinkParameters.shortenUrl(Uri.parse(link.toString()));

    final Uri shortUrl = shortenedLink.shortUrl;

    await Share.share(shortUrl.toString());
    if (!question.userShare) {
      Response response =
          await FeedApiService().share(_userLogged.id, questionId);
      if (response.statusCode == 200) {
        setState(() {
          question.userShare = true;
          question.shares = question.shares + 1;
          _userLogged.questionsShared.add(question);
          Provider.of<UserProvider>(context, listen: false).updateProvider();
        });
      }
    }
  }

  _receiverInfo(QuestionData question) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ListTile(
            onTap: () async {
              _controller.pause();
              await ProfileHelpers().navigationProfileHelper(
                  context,
                  question.answer == null
                      ? question.answers[0].userAnswered.id
                      : question.answer.userAnswered.id);
            },
            contentPadding: EdgeInsets.all(0),
            leading: CircleAvatar(
              radius: 16,
              backgroundImage: question.answer == null
                  ? question.answers[0].userAnswered.avatarImageProvider()
                  : question.answer.userAnswered.avatarImageProvider(),
            ),
            title: Row(
              children: [
                Text(
                  question.answer == null
                      ? question.answers[0].userAnswered.getFullName()
                      : 'Asked to ' +
                          question.answer.userAnswered.getFullName(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  " • ${timeago.format(DateTime.fromMillisecondsSinceEpoch(question.answer == null ? question.answers[0].createdAt : question.answer.createdAt), locale: "en_short").replaceAll(" ", "")}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _jobText(question),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _jobText(QuestionData question, {bool isAsker = false}) {
    String job;
    if (isAsker) {
      job = StringUtils.defaultString(question.userAsked.job);
    } else {
      job = StringUtils.defaultString(question.answer == null
          ? question.answers[0].userAnswered.job
          : question.answer.userAnswered.job);
    }

    return job ?? "";
  }

  _comments(String answerId) async {
    _controller.pause();
    var result = Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return CommentsWidget(
        answerId: answerId,
      );
    }));
  }

  _individualItem(IconData icon, String number,
      {String answerId,
      Function f,
      bool userAffected = false,
      String questionId,
      String type}) {
    Color iconColor = Colors.white;

    return GestureDetector(
      onTap: () {
        f(answerId, questionId: questionId, type: type);
      },
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: iconColor,
            size: 22.0,
          ),
          Container(
            width: 10,
          ),
          Text(
            number,
            style: TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0)
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    else
      return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final CachedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 60.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
