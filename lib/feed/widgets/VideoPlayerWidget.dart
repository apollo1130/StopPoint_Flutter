import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {

  final String videoUrl;

  VideoPlayerWidget({this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {

  CachedVideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = CachedVideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _controller..play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _controller.value.initialized ?
          CachedVideoPlayer(_controller) : Center(child: CircularProgressIndicator())
    );
  }
}
