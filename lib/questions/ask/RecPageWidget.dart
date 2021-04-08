import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class RecPageWidget extends StatefulWidget {
  @override
  _RecPageWidgetState createState() => _RecPageWidgetState();
}

class _RecPageWidgetState extends State<RecPageWidget> {
  String _animationName = 'wait';
  FlareController _flareController;
  bool _hasSpeech = false;
  SpeechToText speech = SpeechToText();
  List<LocaleName> _localeNames = [];
  String _currentLocaleId = "es";
  double level = 0.0;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  bool speechFinished = false;
  bool recordStop = false;
  MediaQueryData queryData;

  @override
  void initState() {
    initSpeechState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    return Scaffold(
        body: Container(
      color: Colors.blueGrey[800],
      child: Center(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 40,
              left: -20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Icon(FontAwesomeIcons.times, color: Colors.white),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 1.4,
                  height: MediaQuery.of(context).size.width / 1.4,
                  child: GestureDetector(
                      onTap: () {
                        print('tap tap tap');
                        setState(() {
                          if (_hasSpeech && !speech.isListening) {
                            print('start');
                            startListening();
                          } else if (_hasSpeech) {
                            print('stopp');
                            stopListening();
                          }
                        });
                      },
                      child: FlareActor(
                        "lib/assets/animations/expertMic.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        animation: _animationName,
                        controller: _flareController,
                      )),
                ),
                Container(
                  transform: Matrix4.translationValues(0, -30, 0),
                  child: Text(
                    'Speak now',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                ..._bottomMessage()
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> initSpeechState() async {
    await requestPermission();
    bool hasSpeech = await speech.initialize(
        debugLogging: true, onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    _hasSpeech = hasSpeech;
  }

  void startListening() {
    resetVariables();
    lastError = "";
    _animationName = "rec";

    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 15),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
    );
  }

  void resetVariables() {
    lastWords = '';
    speechFinished = false;
    recordStop = false;
  }

  void stopListening() async {
    await speech.stop();
    recordStop = true;
    _animationName = "wait";
    setState(() {
      recordStop = true;
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  Future<bool> requestPermission() async {
    PermissionStatus permission = await Permission.microphone.status;

    if (permission != PermissionStatus.granted) {
      await Permission.microphone.request();
    }
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords}";
      speechFinished = result.finalResult && lastWords.length > 0;
    });
  }

  void soundLevelListener(double level) {
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = "$status";
    });
  }

  _afterLayout(_) {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        startListening();
      });
    });
  }

  _bottomMessage() {
    if (recordStop && !speechFinished) {
      return [
        Container(
          width: 100,
          height: 50,
          child: FlareActor(
            "lib/assets/animations/loading.flr",
            alignment: Alignment.center,
            fit: BoxFit.contain,
            animation: 'loading',
          ),
        )
      ];
    } else {
      if (speechFinished) {
        _closeDelay();
      }
      return [
        Container(
          width: queryData.size.width - queryData.size.width * 0.1,
          child: Text(
            lastWords.length > 0 ? lastWords + '?' : '',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }
  }

  _closeDelay() {
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pop(context, lastWords);
    });
  }
}
