import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_app/core/packages/cloudinary/cloudinary_client.dart';
import 'package:video_app/core/packages/cloudinary/models/CloudinaryResponse.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/Widgets/trim_part/rangeslider.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:gallery_saver/gallery_saver.dart';

// ignore: must_be_immutable
class Editor extends StatefulWidget {
  File picked;
  Editor({this.picked});

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  TextEditingController timeBoxControllerStart = TextEditingController();
  TextEditingController timeBoxControllerEnd = TextEditingController();
  VideoPlayerController _videoPlayerController;
  var gradesRange = RangeValues(0, 180);
  bool progress = false;
  Duration position = new Duration(hours: 0, minutes: 0, seconds: 0);
  String outPath;
  var _userLogged;

  InputDecoration timeBoxDecoration = InputDecoration(
    contentPadding: EdgeInsets.all(0.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    fillColor: Colors.grey[200],
    filled: true,
  );

  void finishedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Success"),
          content: new Text("Finished!"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String durationFormatter(Duration dur) {
    return dur.toString().substring(
        0, _videoPlayerController.value.position.toString().indexOf('.'));
  }

  void _saveVideo() async {
    String path = outPath;
    Permission permission = Permission.storage;
    bool grant = await permission.isGranted;
    if (grant) {
      GallerySaver.saveVideo(path).then((bool success) {
        print("is it saved");
        setState(() {
          progress = false;
        });
        if (success) {
          Navigator.pop(context, ['answer', path]);
        } else {
          print("something wrong");
        }
      });
    } else {
      permission.request();
      _saveVideo();
    }
  }

  incSecond(which) {
    setState(() {
      if (which == 'start') {
        if (gradesRange.start < gradesRange.end - 1) {
          gradesRange = new RangeValues(gradesRange.start + 1, gradesRange.end);
          timeBoxControllerStart.text = durationFormatter(
              new Duration(seconds: gradesRange.start.truncate()));
          _videoPlayerController
              .seekTo(Duration(seconds: gradesRange.start.truncate()));
        }
      } else {
        if (gradesRange.end <
            _videoPlayerController.value.duration.inSeconds.truncate()) {
          gradesRange = new RangeValues(gradesRange.start, gradesRange.end + 1);
          timeBoxControllerEnd.text = durationFormatter(
              new Duration(seconds: gradesRange.end.truncate()));
          _videoPlayerController
              .seekTo(Duration(seconds: gradesRange.end.truncate()));
        }
      }
      _videoPlayerController.play(); //for preview
      _videoPlayerController
          .pause(); // if not play-pause , seek set position but we cant see preview
    });
  }

  subSecond(which) {
    setState(() {
      if (which == 'start') {
        if (gradesRange.start > 0) {
          gradesRange = new RangeValues(gradesRange.start - 1, gradesRange.end);
          timeBoxControllerStart.text = durationFormatter(
              new Duration(seconds: gradesRange.start.truncate()));
          _videoPlayerController
              .seekTo(Duration(seconds: gradesRange.start.truncate()));
        }
      } else {
        if (gradesRange.end > gradesRange.start + 1) {
          gradesRange = new RangeValues(gradesRange.start, gradesRange.end - 1);
          timeBoxControllerEnd.text = durationFormatter(
              new Duration(seconds: gradesRange.end.truncate()));
          _videoPlayerController
              .seekTo(Duration(seconds: gradesRange.end.truncate()));
        }
      }
      _videoPlayerController.play(); //for preview
      _videoPlayerController
          .pause(); // if not play-pause , seek set position but we cant see preview
    });
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget.picked)
      ..initialize().then((_) {
        setState(() {
          gradesRange = RangeValues(
              0, _videoPlayerController.value.duration.inSeconds.toDouble() > 180.0 ? 180.0 : 
              _videoPlayerController.value.duration.inSeconds.toDouble()
              );
          timeBoxControllerStart.text = durationFormatter(
              new Duration(seconds: gradesRange.start.truncate()));
          timeBoxControllerEnd.text = durationFormatter(
              new Duration(seconds: gradesRange.end.truncate()));
        });

        _videoPlayerController.play();
      });
    outPath = (widget.picked.path
            .toString()
            .substring(0, widget.picked.path.toString().lastIndexOf('/') + 1)) +
        'flutrim' +
        DateTime.now().millisecondsSinceEpoch.toString() +
        '.mp4';
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (mounted)
        setState(() {
          position = _videoPlayerController.value.position;
        });
    });

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white70),
        title: Text(
          'Flutrim',
          style: TextStyle(fontSize: 25, color: Colors.white70),
        ),
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back,
            color: Colors.grey[500],
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: null,
            iconSize: 30,
          )
        ],
      ),
      body: Container(
        height: height,
        width: width,
        child: _videoPlayerController.value.isInitialized
            ? Stack(
                children: <Widget>[
                  Container(
                    height: height / 1.7,
                    padding: EdgeInsets.fromLTRB(width / 28, 20, width / 28, 0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      ),
                    ),
                  ),
                  progress
                      ? Positioned(
                          top: height / 1.5,
                          right: width / 2.4,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.blue[400],
                            strokeWidth: 5,
                          ),
                        )
                      : Positioned(
                          right: width / 2.5,
                          top: height / 1.9,
                          child: Container(
                            color: Colors.black45,
                            padding: EdgeInsets.all(6.0),
                            child: Text(
                              durationFormatter(position),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  Positioned(
                    top: height / 1.7,
                    right: 0,
                    left: 0,
                    child: Container(
                      color: Colors.grey,
                      margin: EdgeInsets.fromLTRB(width / 30, 0, width / 30, 0),
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 20,
                          rangeThumbShape: CustomRangeThumbShape(),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 5),
                        ),
                        child: RangeSlider(
                          min: 0,
                          max: _videoPlayerController.value.duration.inSeconds
                              .toDouble(),
                          activeColor: Colors.blue,
                          inactiveColor: Colors.grey,
                          values: gradesRange,
                          onChangeStart: (RangeValues value) {
                            setState(() {
                              _videoPlayerController.play();
                            });
                          },
                          onChangeEnd: (RangeValues value) {
                            setState(() {
                              _videoPlayerController.pause();
                            });
                          },
                          onChanged: (RangeValues value) {
                            setState(() {
                              if (value.end - value.start >= 2) {
                                if (value.start != gradesRange.start) {
                                  _videoPlayerController.seekTo(Duration(
                                      seconds: value.start.truncate()));
                                }
                                if (value.end != gradesRange.end) {
                                  _videoPlayerController.seekTo(
                                      Duration(seconds: value.end.truncate()));
                                }
                                gradesRange = value;
                                timeBoxControllerStart.text = durationFormatter(
                                    new Duration(
                                        seconds: gradesRange.start.truncate()));
                                timeBoxControllerEnd.text = durationFormatter(
                                    new Duration(
                                        seconds: gradesRange.end.truncate()));
                              } else {
                                if (gradesRange.start == value.start) {
                                  gradesRange = RangeValues(
                                      gradesRange.start, gradesRange.start + 2);
                                } else {
                                  gradesRange = RangeValues(
                                      gradesRange.end - 2, gradesRange.end);
                                }
                              }
                              //gradesRange = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: height / 1.55,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: height / 5,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all()),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text(
                                    'Start',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        color: Colors.grey,
                                        width: 20,
                                        height: 23,
                                        padding: EdgeInsets.all(0),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            subSecond('start');
                                          },
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 12, 0),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.grey,
                                        width: 100,
                                        height: 23,
                                        padding: EdgeInsets.all(0.0),
                                        child: TextField(
                                          enabled: false,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                          textAlign: TextAlign.center,
                                          controller: timeBoxControllerStart,
                                          decoration: timeBoxDecoration,
                                        ),
                                      ),
                                      Container(
                                        color: Colors.grey,
                                        width: 20,
                                        height: 23,
                                        padding: EdgeInsets.all(0),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            incSecond('start');
                                          },
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 12, 0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    'End',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        color: Colors.grey,
                                        width: 20,
                                        height: 23,
                                        padding: EdgeInsets.all(0),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            subSecond('end');
                                          },
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 12, 0),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.grey,
                                        width: 100,
                                        height: 23,
                                        padding: EdgeInsets.all(0.0),
                                        child: TextField(
                                          enabled: false,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                          textAlign: TextAlign.center,
                                          controller: timeBoxControllerEnd,
                                          decoration: timeBoxDecoration,
                                        ),
                                      ),
                                      Container(
                                        color: Colors.grey,
                                        width: 20,
                                        height: 23,
                                        padding: EdgeInsets.all(0),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            incSecond('end');
                                          },
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 12, 0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    _videoPlayerController.value.isPlaying
                                        ? _videoPlayerController.pause()
                                        : _videoPlayerController.play();
                                  });
                                },
                                color: Colors.grey[850],
                                child: Icon(
                                    _videoPlayerController.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white),
                              ),
                              RaisedButton(
                                padding: EdgeInsets.all(10),
                                color: Colors.blue[500],
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(75.0),
                                    side: BorderSide(color: Colors.grey[400])),
                                onPressed: progress
                                    ||
                                    ((gradesRange.end - gradesRange.start) > 182) ?
                                    null
                                    : () async {
                                        if ((gradesRange.end - gradesRange.start) <=
                                            182) {
                                          setState(() {
                                            progress = true;
                                          });
                                          Duration difference = new Duration(
                                              seconds: gradesRange.end
                                                      .truncate() -
                                                  gradesRange.start.truncate());

                                          _flutterFFmpeg
                                              .execute(
                                                  '-i ${widget.picked.path} -ss ${timeBoxControllerStart.text} -t ${durationFormatter(difference)} -c copy $outPath')
                                              .then((value) {
                                            print('Got value $value');
                                            _saveVideo();
                                          }).catchError((error) {
                                            print('Error');
                                          });
                                        } else {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'Video duration should not not greater than 3 min',
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 4,
                                              backgroundColor:
                                                  Colors.blueAccent,
                                              textColor: Colors.white,
                                              fontSize: 14.0);
                                        }
                                      },
                                child: Text(
                                  'Next',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    _videoPlayerController
                                        .seekTo(Duration(seconds: 0));
                                    _videoPlayerController.pause();
                                    gradesRange = RangeValues(
                                        0,
                                        _videoPlayerController
                                            .value.duration.inSeconds
                                            .toDouble());
                                    timeBoxControllerStart.text =
                                        durationFormatter(new Duration(
                                            seconds:
                                                gradesRange.start.truncate()));
                                    timeBoxControllerEnd.text =
                                        durationFormatter(new Duration(
                                            seconds:
                                                gradesRange.end.truncate()));
                                  });
                                },
                                color: Colors.grey[850],
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
