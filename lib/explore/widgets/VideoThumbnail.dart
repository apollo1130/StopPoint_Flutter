import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/CoreProvider.dart';

import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class VideoThumbnail extends StatefulWidget {
  final String url;
  final bool play;
  final QuestionData question;
  final int index;
  const VideoThumbnail(
      {Key key,
        @required this.url,
        @required this.play,
        @required this.question,
        this.index})
      : super(key: key);
  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  CachedVideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  List<String> _viewedVideos;
  User _user;
  @override
  void initState() {
    super.initState();
    _controller = CachedVideoPlayerController.network(widget.url);
    print("Init State Video Player - ${widget.url}");
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });

    if (widget.play) {
      _controller.play();
      _controller.setLooping(true);
    }
  }

  @override
  void didUpdateWidget(VideoThumbnail oldWidget) {
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
    _viewedVideos = Provider.of<CoreProvider>(context, listen: false).viewedVideos;
    _user = Provider.of<UserProvider>(context, listen: false).userLogged;
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(alignment: Alignment.topCenter, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedVideoPlayer(_controller),
            ),
            Center(
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white60,
                size: 60.0,
              ),
            ),
          ]);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

}

