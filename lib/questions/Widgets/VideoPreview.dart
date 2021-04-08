import 'dart:math';
import 'dart:async';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/packages/cloudinary/cloudinary_client.dart';
import 'package:video_app/core/packages/cloudinary/models/CloudinaryResponse.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/Widgets/TrimmerView.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/router.dart';
import 'package:video_compress/video_compress.dart';
import 'dart:io' show File, Platform;



class VideoPreview extends StatefulWidget {
  final CachedVideoPlayerController vcontroller;
  final QuestionData question;
  final double mirrorAngle;

  VideoPreview({this.vcontroller, this.question, this.mirrorAngle});

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


 

  Future<void> _showProgressNotification(int id) async {
    const int maxProgress = 10;
    for (int i = 0; i <= maxProgress; i++) {
      await Future<void>.delayed(const Duration(seconds: 1), () async {
        final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails("Channel", 'progress channel',
            'progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: i);
        final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            id,
            'Uploading',
            'Answer',
            platformChannelSpecifics,
            payload: 'item x');
      });

      if(i==maxProgress){
        await Future<void>.delayed(const Duration(seconds: 1), () async {
          final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('Channel', 'progress channel',
              'progress channel description',
              channelShowBadge: false,
              importance: Importance.max,
              priority: Priority.high,
              onlyAlertOnce: true,
              showProgress: false,
              maxProgress: 0,
              progress: 0);
          final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
          await flutterLocalNotificationsPlugin.show(
              id,
              'Uploaded successfully',
              'Answer',
              platformChannelSpecifics,
              payload: 'item x');
        });
      }
    }
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
    _needRotation();

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
                  onPressed: () {
                    _uploadAndSaveVideo();
                  },
                  shape: CircleBorder(),
                  // RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(50))),
                  color: Colors.blue,
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
           /* Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: RaisedButton(
                  padding: EdgeInsets.all(15),
                  onPressed: () async {
                    print(widget.vcontroller);
                    // ignore: deprecated_member_use
                    File file = new File(widget.vcontroller.dataSource);
                    if (file != null) {
                      await _trimmer.loadVideo(videoFile: file);
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return TrimmerView(_trimmer, widget.vcontroller, widget.question, widget.mirrorAngle);
                      }));
                    }
                    },
                  shape: CircleBorder(),
                  // RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(50))),
                  color: Colors.blue,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ),
            )*/
          ],
        ),
      ),
    );
  }

  _cancelVideo() async {
    await widget.vcontroller.pause();
    FlowRouter.router.pop(context);
  }

  _uploadAndSaveVideo() async {
    // startTimer();
    // showNotification("Uploading", "Answer");

    setState(() {
      sendingVideo = true;
    });
    CachedVideoPlayerController videoPlayerController = widget.vcontroller;
    QuestionData question = widget.question;

    var rng = new Random();
    _showProgressNotification(rng.nextInt(100));
    print(videoPlayerController.dataSource);
    print('videoPlayerController.dataSource');
    videoPath = videoPlayerController.dataSource;
    CloudinaryClient client = new CloudinaryClient(ApiUrl.CLOUDINARY_KEY,
        ApiUrl.CLOUDINARY_SECRET, ApiUrl.CLODINARY_CLOUD_NAME);
    try {
      // Navigator.pop(context,200);
      Navigator.pushNamedAndRemoveUntil(context, 'feed', (route) => false);
      videoPath = await _compressVideo(videoPath);
      CloudinaryResponse result = await client.uploadVideo(videoPath,
          filename: 'question', folder: _userLogged.email.split('@')[0]);
      this.response = await QuestionApiService().answerQuestion({
        'questionId': question.id,
        'answer': {
          'video': result.secure_url,
          'cloudinaryPublicId': result.public_id
        },
        'userId': _userLogged.id,
      });
      print("response.statusCode");
      print(response.statusCode);
      print(result.error);

      // if (response.statusCode == 200) {
      //   Navigator.pop(context, 200);
      // }
    } catch (e) {
      print(e);
    }
  }

  _compressVideo(String videoPath) async {
    try {
      // videoPath = videoPath.replaceAll('file:///', '');
      MediaInfo mediaInfo = await VideoCompress.compressVideo(videoPath,
          quality: VideoQuality.DefaultQuality,
          deleteOrigin: false,
          includeAudio: true // It's false by default
          );
      return mediaInfo.path;
    } catch (e) {
      print(e);
      return '';
    }
  }

  _needRotation() {
    if (Platform.isAndroid) {
      rotateVideo = pi;
    } else {
      rotateVideo = 0;
    }
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
