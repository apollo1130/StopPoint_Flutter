import 'dart:io';
import 'dart:math';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/packages/cloudinary/cloudinary_client.dart';
import 'package:video_app/core/packages/cloudinary/models/CloudinaryResponse.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:video_app/core/widgets/SelectInterest.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/ask/AudienceSelect.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/questions/models/QuestionRequest.dart';
import 'package:video_app/videoQuestion/selectInterest.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import 'Confidentiality.dart';
import 'design_course_app_theme.dart';

class QuestionVideo extends StatefulWidget {
  var video;

  QuestionVideo(this.video);

  @override
  _QuestionVideoState createState() => _QuestionVideoState();
}

class _QuestionVideoState extends State<QuestionVideo>
    with TickerProviderStateMixin {
  bool routedPushed = false;
  TextEditingController questionField;
  QuestionData question;

  bool sendingVideo =  false;
  AudienceType result = AudienceType.Public;
  Interest SelectInterest = new Interest(label:" ");
  TabController _tabController;
  User _userLogged;
  Response response;
  bool lockInBackground = true;
  bool notificationsEnabled = true;
  String textToShow ;
  VideoPlayerController _controller;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 1);
    super.initState();
    questionField = TextEditingController();
    File file = new File(widget.video);
    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {}); //when your thumbnail will show.
      });
    _audienceButton();
  }


final _keyform = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          'Post',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: DesignCourseAppTheme.darkerText,
          ),
        ),
        centerTitle: true,
      ),
      body: LoadingOverlay(
      color: Colors.black26,
      isLoading: sendingVideo,
      child: Stack(
        children: <Widget>[SettingsList(
        backgroundColor: Colors.white,
        sections: [
          CustomSection(
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Form(
                    key: _keyform,
                        child: TextFormField(
                        autocorrect: true,
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                        controller: questionField,
                        validator: (s){
                          if(s.isEmpty)
                          return "Required*";
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Type a question for your video...',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.white, width: 2),
                          ),
                        )),
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(top: 10, right: 10, bottom: 0),
                  width: 100.0,
                  height: 120.0,
                  child: VideoPlayer(_controller),
                ),
              ],
            ),
          ),
          CustomSection(
            child: const Divider(
              color: Colors.grey,
              height: 19,
              thickness: 0.4,
              indent: 15,
              endIndent: 15,
            ),
          ),
          CustomSection(
            child: InkWell(
              child: Container(
                  margin: new EdgeInsets.only(
                      top: 10, left: 13, bottom: 10, right: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lock_open_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Public or Anonymous Question',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  wordSpacing: 0,
                                  color: Colors.black87,
                                ),
                              ),
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(textToShow.toString(),style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0,
                                wordSpacing: 0,
                                color: Colors.grey,
                              ),),
                              Icon(Icons.arrow_forward_ios,color: Colors.grey,
                                size: 14)
                            ]),
                      ])),
              onTap: () async {
                if(result != AudienceType.Public){
                  result = AudienceType.Anonymous;
                }else if(result != AudienceType.Anonymous){
                  result = AudienceType.Public;
                }


                result =  await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                  return AudienceSelect(
                    defaultAudience: result,
                  );
                }));
                _audienceButton();
                print(result.toString() +"_audienceSelected" + result.toString());
                if(result != AudienceType.Anonymous){
                  result = AudienceType.Public;
                }else if (result != AudienceType.Public){
                  result =AudienceType.Anonymous;
                }
              },
            ),
          ),
          CustomSection(
            child: const Divider(
              color: Colors.grey,
              height: 19,
              thickness: 0.1,
              indent: 15,
              endIndent: 15,
            ),
          ),
          CustomSection(
            child: InkWell(
              child: Container(
                  margin: new EdgeInsets.only(
                      top: 10, left: 13, bottom: 10, right: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.library_add_check,color: Colors.grey,
                                size: 20,),
                              SizedBox(width: 10),
                              Text('Select your topic',
                                style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                letterSpacing: 0,
                                wordSpacing: 0,
                                color: Colors.black87,
                              ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, bottom: 8, left: 0, right: 0),
                                  child: Icon(Icons.star_rounded,color: Colors.grey, size: 10,)),
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              text(),
                              Icon(Icons.arrow_forward_ios,color: Colors.grey,
                                size: 14,)
                            ]),
                      ])),
              onTap: () async {
                SelectInterest = await Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new SelectCategory(),
                      fullscreenDialog: true,
                    ));
                print(SelectInterest.label);
              },
            ),
          ),
          CustomSection(
            child: Row(
              children: [
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
          CustomSection(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 150,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    showProgress ? Container(width: 20,height: 20,child: Center(child: CircularProgressIndicator(strokeWidth: .5))) :
                    RaisedButton.icon(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 8, left: 50, right: 50),
                      onPressed: showProgress ? null : () {
                        if(_keyform.currentState.validate()){

print('Button Clicked.');
                        _sendQuestion();
                        }
                    
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0.3))),
                      label: Text(
                        'POST',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        Icons.unarchive_rounded,
                        color: Colors.white,
                      ),
                      textColor: Colors.white,
                      splashColor: Colors.blueAccent,
                      color: Colors.lightBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
        ]
    )
      )
    );
  }

bool showProgress = false;
  _sendQuestion() async  {
setState(() {
  showProgress = true;
});
    QuestionRequest _request = QuestionRequest();
    _request.type = QuestionType.GENERAL_QUESTION;
    _request.interestId = SelectInterest.id;
    AudienceType _audienceSelected = AudienceType.Public;
    /*if(AudienceType.Anonymous.toString() == result.toString() ) {
      result= AudienceType.Anonymous as String;
      _audienceSelected = AudienceType.Anonymous;
    }*/
    var question = QuestionData(text: questionField.text, privacy: result);
    _request.userSenderId = _userLogged.id;
    _request.questionData = question;
    try{
    if(SelectInterest.label.length != 1){
    Response response =  await QuestionApiService().sendQuestion(_request);
    if (response.statusCode == 200 ) {
      int count = 0;
      print("id "+ response.data);
      _uploadAndSaveVideo(response.data);
      // Navigator.of(context).popUntil((_) => count++ >= 2);
      //Navigator.of(context).popUntil((route) => route.isFirst);
    }else if(response.statusCode == 422){
      //Navigator.of(context).popUntil((route) => route.isFirst);
    }
    else if(response.statusCode == 404){
      //Navigator.of(context).popUntil((route) => route.isFirst);
    }
    }else{
      setState(() {
  showProgress = false;
});
      print("false");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Required"),
            content: new Text("Please write a description and select a topic"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }}catch(e){
      setState(() {
  showProgress = false;
});
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Required"),
            content: new Text("Please write a description and select a topic"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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

  _uploadAndSaveVideo(id) async {
    // startTimer();
    // showNotification("Uploading", "Answer");

    CachedVideoPlayerController videoController;
    VoidCallback videoPlayerListener;
    final CachedVideoPlayerController vcontroller =
    CachedVideoPlayerController.file(File(widget.video));
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
    setState(() {
      sendingVideo = true;
    });
    CachedVideoPlayerController videoPlayerController = vcontroller;
    QuestionData questiondata = question;

    var rng = new Random();
    _showProgressNotification(rng.nextInt(100));
    print(videoPlayerController.dataSource);
    print('videoPlayerController.dataSource');
    var videoPath = videoPlayerController.dataSource;
    var file = widget.video;
     file = await _compressVideo(file);
    CloudinaryClient client = new CloudinaryClient(ApiUrl.CLOUDINARY_KEY,
        ApiUrl.CLOUDINARY_SECRET, ApiUrl.CLODINARY_CLOUD_NAME);
    try {
      // Navigator.pop(context,200);

      Navigator.pushNamedAndRemoveUntil(context, 'feed', (route) => false);
      CloudinaryResponse result = await client.uploadVideo(file,
          filename: 'question', folder: _userLogged.email.split('@')[0]);
      this.response = await QuestionApiService().answerQuestion({
        'questionId': id,
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

  text() {
    try{
      return Text(SelectInterest.label != null ? SelectInterest.label : "",style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0,
        wordSpacing: 0,
        color: Colors.grey,
      ),);
    }catch(e){
      SelectInterest =new Interest(id: " ",label: " ",icon: " ");
    }
  }


  _audienceButton() {
    IconData icon;
    switch (result) {
      case AudienceType.Public:
        textToShow = 'Public';
        break;
      case AudienceType.Anonymous:
        textToShow = 'Anonymous';
        break;
      case AudienceType.Limited:
        textToShow = 'Limited';
        break;
    }
  }
}
