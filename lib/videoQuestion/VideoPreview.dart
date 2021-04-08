import 'dart:math';
import 'dart:async';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/router.dart';
import 'package:video_compress/video_compress.dart';


import 'QuestionVideo.dart';


class VideoPreview extends StatefulWidget {
  final CachedVideoPlayerController vcontroller;
  var videoPath ;
  VideoPreview(this.vcontroller, this.videoPath);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  User _userLogged;
  bool sendingVideo = false;
  var _subscription;
  double rotateVideo = 0;
  Response response;
  String videoPath;
  var androidPlatformChannelSpecifics;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    var initializationSettingsAndroid =
    new AndroidInitializationSettings('mipmap/launcher_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);

    widget.vcontroller.addListener(() {
      setState(() {});
    });

    try {
      _subscription = VideoCompress.compressProgress$.subscribe((progress) {
        debugPrint('progress: $progress');
      });
    }catch(e){}
  }
  

  @override
  Widget build(BuildContext context) {
    if (sendingVideo) {
      widget.vcontroller.pause();
    }

    _userLogged = Provider.of<UserProvider>(context).userLogged;
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    double xScale = widget.vcontroller.value.aspectRatio / deviceRatio;
    double yScale = 1;

    return Scaffold(
      body: LoadingOverlay(
        color: Colors.black26,
        isLoading: sendingVideo,
        child: Stack(
          children: <Widget>[
            Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(xScale, yScale, 1),
                child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: CachedVideoPlayer(
                      widget.vcontroller,
                    ))),
            AppBar(
              backgroundColor: Colors.transparent,
              leading: GestureDetector(
                  onTap: () async {
                    _cancelVideo();
                  },
                  child: Container(
                      width: kToolbarHeight,
                      height: kToolbarHeight,
                      padding: EdgeInsets.all(0),
                      child: Icon(
                        Icons.arrow_back,
                        //FontAwesomeIcons.times,
                        color: Colors.white,
                      ))),
            ),
            Container(
              margin: EdgeInsets.all(100),
              child: _PlayPauseOverlay(controller: widget.vcontroller),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: Alignment.bottomRight,
                child: RaisedButton(
                  padding: EdgeInsets.all(15),
                  onPressed: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                            return QuestionVideo(widget.videoPath);
                          }));
                   // _uploadAndSaveVideo();
                  },
                  shape: CircleBorder(),
                  // RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(50))),
                  color: Colors.blue,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _cancelVideo() async {
    await widget.vcontroller.pause();
    FlowRouter.router.pop(context);
  }

  @override
  void dispose() {
    widget.vcontroller.dispose();
    _subscription.unsubscribe();
    super.dispose();
  }
}

class _PlayPauseOverlay extends StatefulWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final CachedVideoPlayerController controller;

  @override
  _PlayOverlayState createState() => _PlayOverlayState();
}

class _PlayOverlayState extends State<_PlayPauseOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
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
            widget.controller.value.isPlaying
                ? widget.controller.pause()
                : widget.controller.play();
            setState(() {});
          },
        ),
      ],
    );
  }
}
