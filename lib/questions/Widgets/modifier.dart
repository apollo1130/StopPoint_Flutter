import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_app/core/packages/cloudinary/cloudinary_client.dart';
import 'package:video_app/core/packages/cloudinary/models/CloudinaryResponse.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/router.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import 'CameraWidget.dart';

class Gallery extends StatefulWidget {
  final question;

  Gallery(this.question);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  // This will hold all the assets we fetched
  List<AssetEntity> assets = [];

  @override
  void initState() {
    _fetchAssets();
    super.initState();
  }

  _fetchAssets() async {
    final albums = await PhotoManager.getVideoAsset();
    final recentAlbum = albums.first;

    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );
    setState(() => assets = recentAssets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Gallery'),
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // A grid view with 3 items per row
          crossAxisCount: 3,
        ),
        itemCount: assets.length,
        itemBuilder: (_, index) {
          return AssetThumbnail(assets[index], widget.question);
        },
      ),
    );
  }

  _cancelVideo() async {
    Navigator.pop(context);
  }
}

class AssetThumbnail extends StatefulWidget {
  final AssetEntity asset;
  final QuestionData question;

  AssetThumbnail(this.asset, this.question);

  @override
  _AssetThumbnail createState() => _AssetThumbnail();
}

class _AssetThumbnail extends State<AssetThumbnail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // We're using a FutureBuilder since thumbData is a future

    return FutureBuilder<Uint8List>(
      future: widget.asset.thumbData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return CircularProgressIndicator();
        // If there's data, display it as an image
        return InkWell(
          onTap: () async {
            /*if (widget.asset.file != null) {
              File file = await widget.asset.file;
              final CachedVideoPlayerController vcontroller =
              CachedVideoPlayerController.file(file);
              videoPlayerListener = () {
                if (videoController != null &&
                    videoController.value.size != null) {
                  // Refreshing the state to update video player with the correct ratio.
                  if (mounted) setState(() {});
                  videoController.removeListener(videoPlayerListener);
                }
              };
              vcontroller.addListener(videoPlayerListener);
              await vcontroller.setLooping(true);
              await vcontroller.initialize();
              print("file");
              try {
                await _trimmer.loadVideo(videoFile: file);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return TrimmerView(_trimmer, vcontroller, widget.question);
                }));

                print("video is so small");
              } catch (e) {
                print("video is so big");
              }

            }*/
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  // if it's not, navigate to VideoScreen
                  return VideoScreen(widget.asset.file, widget.question);
                },
              ),
            );
          },
          child: Stack(
            children: [
              // Wrap the image in a Positioned.fill to fill the space
              Positioned.fill(
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
              // Display a Play icon if the asset is a video
              if (widget.asset.type == AssetType.video)
                Center(
                  child: Container(
                    color: Colors.blue,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class VideoScreen extends StatefulWidget {
  final QuestionData question;
  final Future<File> videoFile;

  const VideoScreen(this.videoFile, this.question);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController _controller;
  bool initialized = false;
  bool sendingVideo = false;
  var _userLogged;
  double _startValue = 0.0;
  double _endValue = 60000.0;
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
  void initState() {
    _initVideo();
    if(initialized){
      print("init is true");
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _initVideo() async {
    final video = await widget.videoFile;
    _controller = VideoPlayerController.file(video);
      // Play the video again when it ends
    _controller.setLooping(true);
    _controller.initialize().then((_) =>
        _inittremmer(video));


    // initialize the controller and notify UI when done
  }

  _inittremmer(video) async {
    //File file = new File(video.dataSource);
    try {
      // await trimmer.loadVideo(videoFile: video);
      setState(() => initialized = true);
    }catch(e)
    { print(e);
      print("line 254");
      setState(() => initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(initialized);
    double xScale ;
    double yScale ;

    if(initialized) {
      if (sendingVideo) {
        _controller.pause();
      }
      _userLogged = Provider
          .of<UserProvider>(context)
          .userLogged;
      final size = MediaQuery
          .of(context)
          .size;
      final deviceRatio = size.width / size.height;
      xScale = _controller.value.aspectRatio / deviceRatio;
      yScale = 1;
      _needRotation();
    }
    return Scaffold(
        body: initialized
        // If the video is initialized, display it
            ?  LoadingOverlay(
            color: Colors.black26,
            isLoading: sendingVideo,
            child: Stack(children: <Widget>[
              Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(xScale, yScale, 1),
                  child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: VideoPlayer(_controller))),
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
              //       child:
              //       TrimEditor(
              //         viewerHeight: 50.0,
              //         viewerWidth: MediaQuery.of(context).size.width,
              //         maxVideoLength: Duration(seconds: 60),
              //         onChangeStart: (value) {
              //           _startValue = value;
              //         },
              //         onChangeEnd: (value) {
              //           _endValue = value;
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
                    // bool playbackState = await trimmer.videPlaybackControl(
                    //   startValue: _startValue,
                    //   endValue: _endValue,
                    // );
                    setState(() {
                      // _isPlaying = playbackState;
                    });
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
            ])) : Center(child: CircularProgressIndicator())
    );/*
    print(initialized);
    return Scaffold(
      body: initialized
          // If the video is initialized, display it
          ? Scaffold(
              body: Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(_controller),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Wrap the play or pause in a call to `setState`. This ensures the
                  // correct icon is shown.
                  setState(() {
                    // If the video is playing, pause it.
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      // If the video is paused, play it.
                      _controller.play();
                    }
                  });
                },
                // Display the correct icon depending on the state of the player.
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            )
          // If the video is not yet initialized, display a spinner
          : Center(child: CircularProgressIndicator()),
    );*/
  }

  _cancelVideo() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CameraWidget(question: widget.question)),
    );
  }

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });
    print("save");
    try {
      // await trimmer
      //     .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
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
          print("line 468 " + e);
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

  _needRotation() {
    if (Platform.isAndroid) {
      rotateVideo = pi;
    } else {
      rotateVideo = 0;
    }
  }
}
