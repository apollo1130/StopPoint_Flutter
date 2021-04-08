import 'dart:io';
import 'dart:math';
import 'package:basic_utils/basic_utils.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_app/core/packages/cloudinary/cloudinary_client.dart';
import 'package:video_app/core/packages/cloudinary/models/CloudinaryResponse.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/Widgets/trim_part/editor.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_app/videoQuestion/QuestionVideo.dart';
import 'package:video_compress/video_compress.dart';

class CameraWidget extends StatefulWidget {
  final QuestionData question;
  CameraWidget({this.question});

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool cameraLoaded = false;
  CameraController controller;
  List<CameraDescription> cameras;
  CachedVideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  String videoPath;
  bool recording = false;
  int secondsRecorded = 0;
  double percentage = 0;
  AnimationController _animationController;
  Animation _blinkingTween;
  final double bottomBarHeight = 84;
  final double recordButtonRadius = 24;
  File file;
  @override
  void initState() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('mipmap/launcher_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);

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

  // String getMinutes(int seconds) {
  //   seconds = 179 - seconds;
  //   return seconds < 180 ? "00:${seconds.toString().padLeft(2, '0')}" : "03:00";
  // }

  String getMinutes(int seconds) {
    int newseconds = 179 - seconds;
    var d = Duration(seconds: newseconds);
    List<String> parts = d.toString().split(':');
    print("List<String> parts = d.toString().split(':');");
    print(parts);
    return seconds < 180
        ? '${parts[1].padLeft(2, '0')}:${parts[2].padLeft(2, '0').substring(0, 2)}'
        : "03:00";
  }

  var _userLogged;
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

    double _getImageZoom(MediaQueryData data) {
      final double logicalWidth = data.size.width;
      final double logicalHeight =
          controller.value.previewSize.aspectRatio * logicalWidth;

      final double maxLogicalHeight = data.size.height;

      return maxLogicalHeight / logicalHeight;
    }

    return Scaffold(
        body: IgnorePointer(
      ignoring: startUploading,
      child: Stack(
        children: <Widget>[
          startUploading
              ? Container()
              : AspectRatio(
                  aspectRatio: deviceRatio,
                  child: Transform.scale(
                    scale: _getImageZoom(MediaQuery.of(context)),
                    child: CameraPreview(
                      controller,
                    ),
                  ),
                ),
          AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: kToolbarHeight,
                height: kToolbarHeight,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Icon(
                  Icons.arrow_back,
                  //FontAwesomeIcons.times,
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            title: widget.question == null
                ? null
                : Text(
                    StringUtils.capitalize(widget.question.text) + '?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: 5,
                  ),
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
                Container(
                  height: bottomBarHeight - recordButtonRadius,
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          icon: new Icon(
                            Icons.add_photo_alternate,
                            size: 36,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final _picker = ImagePicker();
                            PickedFile file = await _picker.getVideo(
                                source: ImageSource.gallery);
                            if (file != null) {
                              setState(() {
                                videoPath = file.path;
                              });
                              _startVideoPlayer();
                            }
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          startUploading
              ? Center(
                  child: Container(
                      width: MediaQuery.of(context).size.width * .7,
                      height: 100,
                      color: Colors.white,
                      child: Center(child: CircularProgressIndicator())))
              : Container()
        ],
      ),
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
          cameras.length > 2 ? cameras[3] : cameras[1], ResolutionPreset.high);
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

  void onStopButtonPressed() async {
    recording = false;
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
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
      await controller
          .stopVideoRecording()
          .then((value) => videoPath = value.path);
    } on CameraException catch (e) {
      print(e);
      return null;
    }

    await _startVideoPlayer();
  }

  bool startUploading = false;
  Future<void> _startVideoPlayer() async {
    List<dynamic> resList = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Editor(picked: File(videoPath))),
    );
    if (resList[0] == 'answer' && widget.question != null) {
      setState(() {
        startUploading = true;
      });
      _uploadAndSaveVideo(resList[1]);
    } else {
      await Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return QuestionVideo(resList[1]);
      }));
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  _startRecCount() async {
    percentage = 0;
    bool addSecond = false;
    while (secondsRecorded <= 180 && recording) {
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

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  Future<void> _showProgressNotification(int id) async {
    print("==================Notification");
    print(id);
    print("==================Notification 2");
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
      print("==================Notification error");
      print(e);
    }
  }

  Response response;
  _uploadAndSaveVideo(String value) async {
    print("_uploadAndSaveVideo");
    try {
      if (value != null) {
        QuestionData question = widget.question;
        var rng = new Random();
        CloudinaryClient client = new CloudinaryClient(ApiUrl.CLOUDINARY_KEY,
            ApiUrl.CLOUDINARY_SECRET, ApiUrl.CLODINARY_CLOUD_NAME);
        // Navigator.pop(context,200);
        value = await _compressVideo(value);
        _showProgressNotification(rng.nextInt(100));
        Navigator.pushNamedAndRemoveUntil(context, 'feed', (route) => false);
        try {
          CloudinaryResponse result = await client.uploadVideo(value,
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
          print("Error what is");
          print(e);
          setState(() {
            startUploading = false;
            print('Video is saved');
            _manageResponse(e);
          });
        }
      }
    } catch (e) {
      print("line 468" + e);
      setState(() {
        print('Video is saved');
        startUploading = false;
        _manageResponse(e);
      });
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

  double rotateVideo = 0;
  _needRotation() {
    if (Platform.isAndroid) {
      rotateVideo = pi;
    } else {
      rotateVideo = 0;
    }
  }
}
