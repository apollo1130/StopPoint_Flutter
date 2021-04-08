import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:video_app/auth/models/User.dart' as UserE;
import 'package:video_app/core/widgets/BottomNavigationMenu.dart';
import 'package:video_app/core/widgets/ProfileAppbarPic.dart';
import 'package:video_app/home/Widgets/SendListWidget.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/ask/AudienceSelect.dart';
import 'package:video_app/questions/ask/RecPageWidget.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  GlobalKey btnKey = GlobalKey();
  double overlayRight;
  SpeechToText speech = SpeechToText();
  double level = 0.0;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  bool speechFinished = false;
  PopupMenu menu;
  final List<double> values = [];
  double percentage = 0;
  bool recordStop = false;
  MediaQueryData queryData;
  double lefAnimation = -120;
  double rightAnimation = 120;
  bool anonymous = false;
  FocusNode _focusNodeQuestion = FocusNode();

  TextEditingController _questionController = TextEditingController();
  UserE.User _userProvider;

  AudienceType _audienceSelected = AudienceType.Public;

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context).userLogged;
    overlayRight = -(MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width / 1.3)) / 2 -
        (MediaQuery.of(context).size.width / 1.3) +
        10;
    queryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        title: Text('New Question', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: ProfileAppbarPic(),
      ),
      body: KeyboardActions(
        tapOutsideToDismiss: true,
        config: KeyboardActionsConfig(actions: [
//          KeyboardAction(
//            focusNode: _focusNodeQuestion,
//            displayArrows: false,
//          ),
        ]),
        child: Container(
          padding: EdgeInsets.all(20),
          height: kBottomNavigationBarHeight,
          width: MediaQuery.of(context).size.width,
          color: Colors.blueGrey[900],
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      'Ask a question to anyone',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Container(
                      height: 60,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              height: 200,
                              child: TextField(
                                focusNode: _focusNodeQuestion,
                                controller: _questionController,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.center,
                                textAlign: TextAlign.center,
                                onChanged: (t) {
                                  setState(() {});
                                },
                                onEditingComplete: () {},
                                expands: true,
                                maxLines: null,
                                maxLength: null,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
//                    alignLabelWithHint: true,
                                  hintText: 'Start your question with "What","Why", etc',
//                      hintStyle: TextStyle(fontSize: 12),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: Colors.transparent)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: Colors.transparent)),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 20, right: 5),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Text(
                                    _userProvider.getFullName() + ' asked',
                                    style: TextStyle(color: Colors.black),
                                  )),
                                  VerticalDivider(),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[_audienceButton()],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        GestureDetector(
                          onTap: () async {
                            var result = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                              return RecPageWidget();
                            }));
                            setState(() {
                              _questionController.text = result + '?';
                            });
                          },
                          child: Container(
                            child: Icon(
                              FontAwesomeIcons.microphone,
                              color: Colors.white,
                              size: 30,
                            ),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  onPressed: _questionController.text.length > 0
                      ? () async {
                          var result = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                            return SendListWidget(questionData: QuestionData(text: _questionController.text, privacy: _audienceSelected));
                          }));
                          if (result != null) {
                            setState(() {
                              _questionController.text = '';
                            });
                          }
                        }
                      : null,
                  disabledColor: Colors.blue[300],
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: Icon(
                    FontAwesomeIcons.arrowRight,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(15),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationMenu(iconColor: Colors.white, backgroundColor: Colors.blueGrey[800]),
    );
  }

  _audienceButton() {
    String textToShow;
    IconData icon;
    switch (_audienceSelected) {
      case AudienceType.Public:
        textToShow = 'Public';
        icon = FontAwesomeIcons.users;
        break;
      case AudienceType.Anonymous:
        textToShow = 'Anonymous';
        icon = FontAwesomeIcons.userSlash;
        break;
      case AudienceType.Limited:
        textToShow = 'Limited';
        icon = FontAwesomeIcons.solidUser;
        break;
    }
    return OutlineButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
      color: Colors.blueGrey[700],
      borderSide: BorderSide(color: Colors.grey),
      onPressed: () async {
        _audienceSelected = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
          return AudienceSelect(
            defaultAudience: _audienceSelected,
          );
        }));
        setState(() {});
      },
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.blueGrey,
            size: 16,
          ),
          Container(
            width: 10,
          ),
          Text(
            textToShow,
            style: TextStyle(color: Colors.blueGrey),
          ),
          Container(
            width: 5,
          ),
          Icon(
            FontAwesomeIcons.chevronDown,
            color: Colors.blueGrey,
            size: 16,
          )
        ],
      ),
    );
  }
}
