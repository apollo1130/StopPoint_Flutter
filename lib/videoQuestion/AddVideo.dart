import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:camera/camera.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/Widgets/AnswerSentDialog.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

import '../router.dart';
import 'QuestionVideo.dart';
import 'VideoPreview.dart';
class Addvideo extends StatefulWidget {
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<Addvideo>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver  {

  bool cameraLoaded = false;
  CameraController controller;
  List<CameraDescription> cameras;
  CachedVideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  String videoPath;
  bool recording = false;
  int secondsRecorded = 0;
  double percentage = 0;
  User _userLogged;
  AnimationController _animationController;
  Animation _blinkingTween;
  final double bottomBarHeight = 84;
  final double recordButtonRadius = 24;
  File file;
  @override
  void initState() {
    _loadCameras();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _blinkingTween = ColorTween(begin: Colors.red, end: Colors.transparent)
        .animate(_animationController);

    _animationController.addListener(() {
      if (_animationController.status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
      setState(() {});
    });
    _animationController.forward();
    super.initState();
  }

  String getMinutes(int seconds) {
    seconds = 59 - seconds;
    return seconds < 60 ? "00:${seconds.toString().padLeft(2, '0')}" : "01:00";
  }

  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context).userLogged;
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    if (controller == null ||
        (controller != null && !controller.value.isInitialized)) {
      return Container();
    }

    double xScale = controller.value.aspectRatio / deviceRatio;
    double yScale = 1;
    return Scaffold(
        body: Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: deviceRatio,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(xScale, yScale, 1),
                child: CameraPreview(
                  controller,
                ),
              ),
            ),
            AppBar(
              leading: GestureDetector(
                onTap: () {
                  FlowRouter.router.pop(context);
                },
                child: Container(
                  width: kToolbarHeight,
                  height: kToolbarHeight,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              centerTitle: true,
            ),
            !recording
                ? SizedBox()
                : Positioned(
              right: 0.0,
              left: 0.0,
              bottom: 150.0,
              child: Center(
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 13.0,
                        height: 13.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _blinkingTween.value,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        "${getMinutes(secondsRecorded)}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  //BlueGrey Background
                  recording
                      ? Container()
                      : Container(
                    width: MediaQuery.of(context).size.width,
                    height: bottomBarHeight,
                    color: Colors.transparent,
                  ),

                  GestureDetector(
                    onTap: () {
                      if (recording) {
                        onStopButtonPressed();
                      } else {
                        onVideoRecordButtonPressed();
                      }
                    },
                    child: Container(
                      width: recordButtonRadius * 2,
                      height: recordButtonRadius * 2,
                      margin: EdgeInsets.only(
                          bottom: bottomBarHeight - recordButtonRadius),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Color(0x44FF0000),
                              blurRadius: 4,
                              spreadRadius: 8)
                        ],
                      ),
                      child: Icon(
                        recording ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Container(
                    height: bottomBarHeight - recordButtonRadius,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _cameraTogglesRowWidget(),
                        IconButton(
                            onPressed: null,
                            icon: Icon(Icons.switch_camera,
                                color: Colors.transparent))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  _loadCameras() async {
    if (!cameraLoaded) {
      cameras = await availableCameras();
      controller = CameraController(
          cameras.length > 2 ? cameras[3] : cameras[1],
          ResolutionPreset.high);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          cameraLoaded = true;
        });
      });
    }
  }

  Widget _cameraTogglesRowWidget() {
    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      return IconButton(
          onPressed: () {
            if (controller.description.lensDirection ==
                CameraLensDirection.back) {
              onNewCameraSelected(cameras.length > 2 ? cameras[3] : cameras[1]);
            } else {
              onNewCameraSelected(cameras[0]);
            }
          },
          icon: Image(
            color: Colors.white,
            image: AssetImage('lib/assets/images/3g.png'),
          ));
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      recording = true;
      _startRecCount();
      if (mounted) setState(() {});
      if (filePath != null) print('Saving video to $filePath');
    });
  }

  void onStopButtonPressed() {
    recording = false;
    stopVideoRecording().then((value) {
      if (mounted) setState(() {
        // videoPath = value.path;
      });
      print('Video recorded to: $videoPath');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
     await controller.stopVideoRecording().then((value) => videoPath = value.path);
    } on CameraException catch (e) {
      print(e);
      return null;
    }

    await _startVideoPlayer();
  }

  Future<void> _startVideoPlayer() async {
    final CachedVideoPlayerController vcontroller =
    CachedVideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    final double mirror = controller.description.lensDirection == CameraLensDirection.front ? pi : 0;
    var response = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
         // return QuestionVideo(videoPath);
          return VideoPreview(vcontroller,videoPath);
        }));
    //_manageResponse(response);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  _startRecCount() async {
    percentage = 0;
    bool addSecond = false;
    while (secondsRecorded <= 60 && recording) {
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        if (addSecond) {
          secondsRecorded = secondsRecorded + 1;
        }
        addSecond = !addSecond;
        percentage = percentage + 0.83335;
      });
    }
    onStopButtonPressed();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }
}
