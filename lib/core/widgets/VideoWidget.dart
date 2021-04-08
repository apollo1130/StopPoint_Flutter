import 'package:cached_video_player/cached_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/CoreProvider.dart';
import 'package:video_app/core/widgets/FullVideoWidget.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/models/Answer.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:developer';

class VideoWidget extends StatefulWidget {
  final String url;
  final bool play;
  final QuestionData question;
  final int index;
  const VideoWidget(
      {Key key,
      @required this.url,
      @required this.play,
      @required this.question,
      this.index})
      : super(key: key);
  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  CachedVideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  List<String> _viewedVideos;
  User _user;
  @override
  void initState() {
    super.initState();
    _controller = CachedVideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      _controller.addListener(_markVideoViewed);
      _viewedVideos =
          Provider.of<CoreProvider>(context, listen: false).viewedVideos;
      _user = Provider.of<UserProvider>(context, listen: false).userLogged;
      setState(() {});
    });

    if (widget.play) {
      log('play here ######');
      _controller.play();
      _controller.setLooping(true);
    }
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    if (widget.play) {
      _controller.play();
      _controller.setLooping(true);
    } else {
      _controller.pause();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.dataSource != widget.url) {
      _controller = CachedVideoPlayerController.network(widget.url);
      _initializeVideoPlayerFuture = _controller.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.

        _controller.addListener(_markVideoViewed);
        _viewedVideos =
            Provider.of<CoreProvider>(context, listen: false).viewedVideos;
        _user = Provider.of<UserProvider>(context, listen: false).userLogged;
        setState(() {});
      });
    }

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _controller.value != null && _controller.value.initialized
              ? Stack(alignment: Alignment.topCenter, children: [
                  ClipRRect(
                    child: VisibilityDetector(
                        key: Key(widget.url),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction == 0 &&
                              info.key == Key(widget.url) &&
                              _controller != null) _controller.pause();
                        },
                        child: CachedVideoPlayer(_controller)),
                  ),
                  _PlayPauseOverlay(
                      controller: _controller,
                      url: widget.index == null
                          ? widget.question.answer.getVideoCompress()
                          : widget.question.answers[widget.index]
                              .getVideoCompress(),
                      question: widget.question),
                ])
              : CircularProgressIndicator();
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _markVideoViewed() async {
    if (_controller.value.position.inSeconds > 3) {
      Answer answer = widget.question.answers != null
          ? widget.question.answers[widget.index]
          : widget.question.answer;
      if (!_viewedVideos.contains(answer.id)) {
        _viewedVideos.add(answer.id);
        Response response =
            await QuestionApiService().addViewToAnswer(answer.id, _user.id);
        answer.views = answer.views != null ? answer.views + 1 : null;
      }
    }
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller, this.url, this.question})
      : super(key: key);

  final CachedVideoPlayerController controller;
  final String url;
  final question;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 60.0,
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(10),
            child: IconButton(
              icon: Icon(
                Icons.fullscreen,
                color: Colors.white,
              ),
              onPressed: () async {
                controller.pause();
                var result = await Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return FullVideoWidget(videoPath: url, question: question);
                }));
                controller.play();
              },
            ))
      ],
    );
  }
}
