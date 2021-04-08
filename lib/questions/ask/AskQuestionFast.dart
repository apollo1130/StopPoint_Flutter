
import 'dart:async';

import 'package:basic_utils/basic_utils.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:spell_checker/spell_checker.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/explore/selectCategory.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/ask/ConfirmAskQuestion.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import '../../router.dart';
import 'AudienceSelect.dart';
import 'RecPageWidget.dart';

class AskQuestionFast extends StatefulWidget {
  final User userToAsk;
  final Interest interestToAsk;

  AskQuestionFast({this.interestToAsk, this.userToAsk});

  @override
  _AskQuestionFastState createState() => _AskQuestionFastState();
}

class _AskQuestionFastState extends State<AskQuestionFast> {
  AudienceType _audienceSelected = AudienceType.Public;
  FocusNode _focusNodeQuestion = FocusNode();
  TextEditingController _questionController = TextEditingController();
  User _userLogged;
  Timer _debounce;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context, listen:false).userLogged;

    return Scaffold(
      appBar:AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: <Color>[
                    Color(0xff2D4379),
                    Color(0xff2171B8)
                  ])
          ),
        ),
        leading: GestureDetector(
          onTap: (){
            FlowRouter.router.pop(context);
          },
          child: Container(
            width: 40,
            child: Icon(Icons.arrow_back,color: Colors.white,)//Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, ),
          ),
        ),
        title: Text('New Question', style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
//            Container(
//              color: Colors.white,
//              child: ListTile(
//                contentPadding: EdgeInsets.all(10),
//                leading: widget.userToAsk != null ?
//                CircleAvatar(
//                  radius: 26,
//                  backgroundImage: widget.userToAsk.avatarImageProvider() ,
//                ):
//                CircleAvatar(
//                  child: Text(widget.interestToAsk.icon),
//                ),
//                title: widget.userToAsk != null ?
//                Text('Ask a question to ' + widget.userToAsk.getFullName(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),):
//                Text('Ask a question on ' + widget.interestToAsk.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//              ),
//            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundImage: _userLogged.avatarImageProvider(),
                    ),
                    title: Text(_userLogged.getFullName()),
                    subtitle: Text(StringUtils.defaultString(_userLogged.job, defaultStr: '')),
                    trailing: Container(
                      width: 118,
                      height: 30,
                      child: _audienceButton(),
                    ),
                  ),
                  Stack(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left:12),
                            hintText: 'Start your question with "What", "Why", etc',
                            border: UnderlineInputBorder(

                            )
                        ),
                        controller: _questionController,
                        onChanged: (x) {
                          setState(() {
                          });
                        },
                        maxLines: 3,
                        minLines: 1,
                      ),
                      Container(
                        margin: EdgeInsets.only(top:15, ),
                        color: Colors.blue,
                        width: 2,
                        height: 20,
                      )
                    ],
                  ),
                  Divider(color: Colors.transparent,),
                  // _correctionText(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: ()async {
                          var result = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                            return RecPageWidget();
                          }));
                          setState(() {
                            _questionController.text = result + '?';
                          });
                        },
                        child: CircleAvatar(

                          backgroundColor: Color(0xffEB0038),
                          child: Icon(FontAwesomeIcons.microphone, color: Colors.white,),
                        ),
                      )
                    ],
                  )
                ],
              ),
              decoration: BoxDecoration(
                  color: Color(0xffF8F8F8),
                  border: Border.all( color: Color(0xffE4E4E4)),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 2.0), //(x,y)
                      blurRadius: 2.0,
                    ),
                  ]
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: RaisedButton(
                padding:EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                onPressed: _questionController.text.length > 0
                    ? () async {

                  print("_questionController.toString()");
                  print(_questionController.text.toString());
                  var result = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                   // print('###### ${widget.userToAsk.id} #######');
                    return SelectCategory(
                        question: QuestionData(text: _questionController.text.replaceAll("?", ""), privacy: _audienceSelected, ),
                        userId: widget.userToAsk != null ? widget.userToAsk.id : null,
                        interestId:  widget.interestToAsk != null ? widget.interestToAsk.id: null,
                        privacy: _audienceSelected.toString()
                    );
                  }));
                  if (result != null) {
                    setState(() {
                      _questionController.text = '';
                    });
                  }
//                  Navigator.push(context, MaterialPageRoute(
//                      builder: (BuildContext context) {
//                        return SelectCategory();
//                      }));
                }
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                ),
                color: Colors.blue,
                child: Text('Next', style: TextStyle(color: Colors.white,),),
              ),
            )
          ],
        ),
      ),
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
      padding: EdgeInsets.all(6),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.blueGrey,
            size: 13,
          ),
          Container(
            width: 8,
          ),
          Text(
            textToShow,
            style: TextStyle(color: Colors.blueGrey, fontSize: 12),
          ),
          Container(
            width: 4,
          ),
          Icon(
            FontAwesomeIcons.chevronDown,
            color: Colors.blueGrey,
            size: 13,
          )
        ],
      ),
    );
  }



  _oldDesing () {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        title: Text('New Question', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading:   GestureDetector(
          onTap: (){
            FlowRouter.router.pop(context);
          },
          child: Container(
            width: 40,
            child: Icon(Icons.arrow_back,color: Colors.white,)//Icon(FontAwesomeIcons.chevronLeft, color: Colors.white, ),
          ),
        ),
      ),
      body: KeyboardActions(
        tapOutsideToDismiss: true,
        config: KeyboardActionsConfig(actions: [
          KeyboardActionsItem(
            focusNode: _focusNodeQuestion,
            displayArrows: false,
          ),
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
                      widget.userToAsk != null ?
                      'Ask a question to ' + widget.userToAsk.getFullName():
                      'Ask a question on ' + widget.interestToAsk.label,
                      style: TextStyle(color: Colors.white, fontSize: 18, ),
                      textAlign: TextAlign.center,
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
                                  setState(() {
                                  });
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
                                        _userLogged.getFullName() + ' asked',
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
                      return ConfirmAskQuestion(
                          question: QuestionData(text: _questionController.text, privacy: _audienceSelected, ),
                          userId: widget.userToAsk != null ? widget.userToAsk.id : null,
                          interestId:  widget.interestToAsk != null ? widget.interestToAsk.id: null
                      );
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
    );
  }


// _correctionText() {
//   List<TextSpan> textSpanItems = List<TextSpan>();
//   if(textChecked.length > 0) {
//     textChecked.forEach((element) {
//       var subArray = element.split('/');
//       if(subArray.length > 1) {
//         textSpanItems.add(TextSpan(
//           text: subArray[0] + " ",
//           style: TextStyle(color: Color(0xffEB0038), decoration: TextDecoration.underline)
//         ));
//         textSpanItems.add(TextSpan(
//           text: subArray[1] + " ",
//           style: TextStyle(color: Color(0xff21B8A3), decoration: TextDecoration.underline)
//         ));
//       }else {
//         textSpanItems.add(TextSpan(
//           text: subArray[0]+ " ",
//           style: TextStyle(color: Colors.black)
//         ));
//       }
//     });
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         RichText(
//           textAlign:TextAlign.start,
//           text: TextSpan(
//            text: 'Did you mean: ',
//             style: TextStyle(color: Colors.grey),
//             children: textSpanItems
//           ),
//         ),
//       ],
//     );
//   }else {
//     return SizedBox.shrink();
//   }
// }
}
