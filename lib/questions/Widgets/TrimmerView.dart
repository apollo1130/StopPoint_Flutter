import 'dart:io';
import 'dart:math';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:video_app/core/packages/cloudinary/cloudinary_client.dart';
import 'package:video_app/core/packages/cloudinary/models/CloudinaryResponse.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/router.dart';
import 'package:video_compress/video_compress.dart';
// import 'package:video_trimmer/video_trimmer.dart';

import 'AnswerSentDialog.dart';

// ignore: must_be_immutable
class TrimmerView extends StatefulWidget {
  // Trimmer trimmer;
  final CachedVideoPlayerController vcontroller;
  final QuestionData question;

  TrimmerView(this.vcontroller, this.question);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  var _userLogged;
  double _endValue = 60000.0;

  bool sendingVideo = false;
  double rotateVideo = 0;
  CachedVideoPlayerController videoController;
  Response response;
  String videoPath;
  String _value;
  VoidCallback videoPlayerListener;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  bool _isPlaying = false;
  bool _progressVisibility = false;

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
                    // child: VideoViewer()
                )
            ),
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
            // Padding(
            //     padding: EdgeInsets.fromLTRB(0, 0, 0, 500),
            //     child: Center(
            //       child: TrimEditor(
            //         viewerHeight: 40.0,
            //         showDuration: true,
            //         maxVideoLength: Duration(milliseconds: 60000),
            //         circleSize: 3.0,
            //         viewerWidth: MediaQuery.of(context).size.width,
            //         borderPaintColor: Colors.blue,
            //         circlePaintColor: Colors.blueAccent,
            //         onChangeStart: (value) {
            //           _startValue = value;
            //           print(_endValue);
            //         },
            //         onChangeEnd: (value) {
            //           _endValue = value;
            //           print(_endValue);
            //         },
            //         onChangePlaybackState: (value) {
            //           setState(() {
            //             _isPlaying = value;
            //           });
            //         },
            //       ),
            //     )),
            Container(
              alignment: Alignment.center,
              child: FlatButton(
                child: _isPlaying
                    ? Icon(
                        Icons.pause,
                        size: 80.0,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.play_arrow,
                        size: 80.0,
                        color: Colors.white,
                      ),
                onPressed: () async {
                  // bool playbackState = await widget.trimmer.videPlaybackControl(
                  //   startValue: _startValue,
                  //   endValue: _endValue,
                  // );
                  // setState(() {
                  //   _isPlaying = playbackState;
                  // });
                },
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 15, 680),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: sizeVideo(),
                )),
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Align(
                alignment: Alignment.bottomRight,
                child: RaisedButton(
                  onPressed: () async {
                    print(_endValue - _startValue);
                    //if ((_endValue) <= (60000.0)) {
                    _saveVideo().then((outputPath) {
                      print('OUTPUT PATH: $outputPath');
                    });
                    /*} else if ((_endValue - _startValue) <= (60000.0)) {
                        _saveVideo().then((outputPath) {
                          print('OUTPUT PATH: $outputPath');
                        });
                      } else {
                        showAlertDialog(context);
                      }*/
                  },
                  shape: CircleBorder(),
                  color: Colors.blue,
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    /*return Scaffold(
      body: LoadingOverlay(
        color: Colors.black26,
        isLoading: sendingVideo,
        child: Stack(
          children: <Widget>[
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
            Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(xScale, yScale, 1),
                child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: CachedVideoPlayer(
                      widget.vcontroller,
                    ))),
            /*AppBar(
              backgroundColor: Colors.transparent,
              leading: GestureDetector(
                  onTap: () async {
                    _cancelVideo();
                  },
                  child: Container(
                      width: kToolbarHeight,
                      height: kToolbarHeight,
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_back,
                        //FontAwesomeIcons.times,
                        color: Colors.white,
                      ))),
            ),*/
            Container(
              padding: EdgeInsets.only(bottom: 30.0),
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Center(
                    child: TrimEditor(
                      viewerHeight: 40.0,
                      viewerWidth: MediaQuery.of(context).size.width,
                      borderPaintColor: Colors.blue,
                      circlePaintColor: Colors.blueAccent,
                      onChangeStart: (value) {
                        _startValue = value;
                        print(_endValue);
                      },
                      onChangeEnd: (value) {
                        _endValue = value;
                        print(_endValue);
                      },
                      onChangePlaybackState: (value) {
                        setState(() {
                          _isPlaying = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    child: _PlayPauseOverlay(controller: widget.vcontroller),
                  ),
                  /*FlatButton(
                    child: _isPlaying
                        ? Icon(
                            Icons.pause,
                            size: 80.0,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.play_arrow,
                            size: 80.0,
                            color: Colors.white,
                          ),
                    onPressed: () async {
                      bool playbackState =
                          await widget.trimmer.videPlaybackControl(
                        startValue: _startValue,
                        endValue: _endValue,
                      );
                      setState(() {
                        _isPlaying = playbackState;
                      });
                    },
                  ),*/

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: RaisedButton(
                              onPressed: () async {
                                print(_endValue - _startValue);
                                if (_startValue == 0) {
                                  if ((_endValue) <= (60000.0)) {
                                    _saveVideo().then((outputPath) {
                                      print('OUTPUT PATH: $outputPath');
                                    });
                                  } else if ((_endValue - _startValue) <= (60000.0)) {
                                    _saveVideo().then((outputPath) {
                                      print('OUTPUT PATH: $outputPath');
                                    });
                                  } else {
                                    showAlertDialog(context);
                                  }
                                }
                              },
                              shape: CircleBorder(),
                              color: Colors.blue,
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );*/
  }

  sizeVideo() {
    if (_endValue == 60000.0) {
      return Text(" ");
    } else {
      var y = ((_endValue - _startValue) / 1000).toStringAsFixed(0);
      return RichText(
          text: TextSpan(
        text: "00:" + y.toString(),
        style: TextStyle(color: Colors.black, fontSize: 14),
      ));
    }
  }

  Future<void> _showProgressNotification(int id) async {
    const int maxProgress = 10;
    try {
      for (int i = 0; i <= maxProgress; i++) {
        await Future<void>.delayed(const Duration(seconds: 1), () async {
          final AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
                  "Channel", 'progress channel', 'progress channel description',
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
              id, 'Uploading', 'Answer', platformChannelSpecifics,
              payload: 'item x');
        });

        if (i == maxProgress) {
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
                id, 'Uploaded successfully', 'Answer', platformChannelSpecifics,
                payload: 'item x');
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });
    print("save");
    try {
      // await widget.trimmer
      //     .saveTrimmedVideo(startValue: _startValue, endValue: _endValue,
      //     ffmpegCommand:
      //     '-vf "fps=10,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0',
      //     customVideoFormat: '.mp4'
      // )
      //     .then((value) {
      //   //File file = File(value);
      //   _uploadAndSaveVideo(value);
      //   setState(() {
      //     _progressVisibility = false;
      //     _value = value;
      //   });
      // });
    } catch (e) {
      print(e);
      print("line 396");
    }
    return _value;
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {},
    );
    AlertDialog alert = AlertDialog(
      title: Text("Stoppoint"),
      content: Text("Edit your video to be less than 60 second"),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _uploadAndSaveVideo(value) async {
    print("_uploadAndSaveVideo");
    try {
      if (value != null) {
        File file = File(value);
        final CachedVideoPlayerController vcontroller =
            CachedVideoPlayerController.file(file);
        videoPlayerListener = () {
          if (videoController != null && videoController.value.size != null) {
            if (mounted) setState(() {});
            videoController.removeListener(videoPlayerListener);
          }
        };
        vcontroller.addListener(videoPlayerListener);
        await vcontroller.setLooping(true);
        await vcontroller.initialize();
        setState(() {
          sendingVideo = true;
        });
        QuestionData question = widget.question;
        var rng = new Random();
        _showProgressNotification(rng.nextInt(100));
        videoPath = vcontroller.dataSource;
        CloudinaryClient client = new CloudinaryClient(ApiUrl.CLOUDINARY_KEY,
            ApiUrl.CLOUDINARY_SECRET, ApiUrl.CLODINARY_CLOUD_NAME);
        // Navigator.pop(context,200);
        videoPath = await _compressVideo(vcontroller.dataSource);
        print("line472 " + videoPath);
        Navigator.pushNamedAndRemoveUntil(context, 'feed', (route) => false);
        try {
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
          _manageResponse(response.statusCode);
          print(result.error);
        } catch (e) {
          print("line 468 "+ e);
          _manageResponse(e);
        }
      }
    } catch (e) {
      print("line 468" + e);
    }
  }

  _manageResponse(responseCode) async {
    if (responseCode != null) {
      if (responseCode == 200) {
        Fluttertoast.showToast(
            msg: 'Answer Upload with successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
            fontSize: 14.0);
        /*showDialog(
            context: context,
            builder: (BuildContext context) {
              return AnswerSentDialog();
            });*/
        var index = _userLogged.notifications.indexWhere((element) {
          if (element.question != null) {
            if (element.question.id == widget.question.id) {
              return true;
            }
          }
          return false;
        });
        _userLogged.notifications.removeAt(index);

        await Future.delayed(Duration(milliseconds: 1000));

        _userLogged.questionsReceived.removeWhere((element) {
          if (widget.question.id == element.id) {
            return true;
          } else {
            return false;
          }
        });
        Provider.of<UserProvider>(context, listen: false).updateProvider();
      } else {
        Fluttertoast.showToast(
            msg: 'Server Error try again',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0);
      }
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

  _cancelVideo() async {
    await widget.vcontroller.pause();
    FlowRouter.router.pop(context);
  }

  _needRotation() {
    if (Platform.isAndroid) {
      rotateVideo = pi;
    } else {
      rotateVideo = 0;
    }
  }
}
