import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/router.dart';

class QuestionCard extends StatefulWidget {
  final QuestionData question;
  final parent;
  QuestionCard({this.question, this.parent, Key key}) : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  double iconSize;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    iconSize = MediaQuery.of(context).size.height * 0.08;
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: CircleAvatar(
                        backgroundImage:
                            widget.question.userAsked.avatarImageProvider(),
                      ),
                      title: RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 14),
                            children: [
                              TextSpan(text: 'Asked by '),
                              TextSpan(
                                  text: widget.question.userAsked.getFullName(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                      ),
                      subtitle: Text(widget.question.userAsked.getFullName()),
                    ),
                  ),
                  IconButton(
                      padding: EdgeInsets.only(left: 8),
                      icon: Icon(Icons.delete, size: 30),
                      onPressed: () {
                        _archiveQuestion();
                      }),
                ],
              ),
              // _hashTags(),
              Divider(
                color: Colors.transparent,
              ),
              _questionText(widget.question.text),
              Divider(
                color: Colors.transparent,
              ),
              Expanded(
                child: Opacity(
                  opacity: 0.15,
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        FontAwesomeIcons.question,
                        size: iconSize,
                        color: Colors.blueGrey,
                      )),
                ),
              ),
            ],
          ),
        ));
  }

  _hashTags() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
//            _hashTagStyle('#colors'),
//            _hashTagStyle('#pallete'),
//            _hashTagStyle('#art'),
          ],
        ),
        GestureDetector(
          onTap: () {
            _archiveQuestion();
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              FontAwesomeIcons.trashAlt,
              color: Colors.white,
              size: 20,
            ),
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(50))),
          ),
        )
      ],
    );
  }

  _hashTagStyle(String text) {
    return Container(
        margin: EdgeInsets.only(right: 10),
        child: Text(text, style: TextStyle(color: Colors.blue[600])));
  }

  _questionText(String question) {
    return AutoSizeText(
      question + "?",
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 30,
        color: Color(0xff576484),
      ),
      maxLines: 3,
      textAlign: TextAlign.center,
    );
  }

  _loadData() {
    var userList = widget.question.userAsked;
    print('lol');
  }

  _archiveQuestion() async {
    Response response = await QuestionApiService()
        .archiveQuestion({"questionId": widget.question.id});
    if (response.statusCode == 200) {
      widget.parent.archive();
    }
  }
}
