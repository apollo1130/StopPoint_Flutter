import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:localstorage/localstorage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/auth/api/AuthApiService.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/DynamicLinkProvider.dart';
import 'package:video_app/core/widgets/VideoWidget.dart';
import 'package:video_app/feed/api/FeedApiService.dart';
import 'package:video_app/feed/widgets/CommentsWidget.dart';
import 'package:video_app/feed/widgets/QuestionDetailsWidget.dart';
import 'package:video_app/feed/widgets/QuestionInterestDetails.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:video_app/profile/utils/StringHelper.dart';
import 'package:video_app/profile/widgets/ConfimDeleteDialog.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/ask/AudienceSelect.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class AnswersTabWidget extends StatefulWidget {
  final List<QuestionData> questions;
  final bool isUserLogged;
  final bool routedPushed;

  AnswersTabWidget({this.questions, this.isUserLogged, this.routedPushed});

  @override
  _AnswersTabWidgetState createState() => _AnswersTabWidgetState();
}

class _AnswersTabWidgetState extends State<AnswersTabWidget> {
  List<Widget> listOfQuestionsWidgets = List<Widget>();
  bool loadedVideos = false;
  User _userLogged;
  bool routePushed = false;
  User _user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    routePushed = widget.routedPushed != null
        ? widget.routedPushed
            ? true
            : routePushed
        : routePushed;
    _userLogged = Provider.of<UserProvider>(context).userLogged;
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Container(
        color: Colors.white,
        child: InViewNotifierList(
          padding: EdgeInsets.only(top: 0),
          isInViewPortCondition:
              (double deltaTop, double deltaBottom, double viewPortDimension) {
            return deltaTop < (0.5 * viewPortDimension) &&
                deltaBottom > (0.5 * viewPortDimension);
          },
          itemCount: widget.questions.length,
          builder: (BuildContext context, int index) {
            print("print question " +
                index.toString() +
                " " +
                widget.questions[index].text.toString());
            print("print answer " +
                index.toString() +
                " " +
                widget.questions[index].answers[0].video.toString());
            return _questionItem(widget.questions[index], index);
          },
        ),
      ),
    );
  }

  _showReportSendSucessfullyDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Report was successfully sent."),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _questionItem(QuestionData question, int index) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.grey[300], width: 8))),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10, right: 0),
            child: Column(
              children: <Widget>[
                _askerInfo(question),
                /*Container(height: 5),*/
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            routePushed = true;
                          });
                          await Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            if (question.interest != null) {
                              return QuestionInterestDetailsWidget(
                                question: question,
                              );
                            } else {
                              return QuestionDetailsWidget(
                                question: question,
                                needFetch: true,
                              );
                            }
                          }));
                          setState(() {
                            routePushed = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          width: double.infinity,
                          child: Text(
                            StringUtils.capitalize(question.text) + '?',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),*/
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
 /*                         Text(
                            StringUtils.capitalize(question.text) + '?',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "${question.answers != null ? question.answers.length.toString() : 0} ${StringHelper.puralize("Answer", question.answers != null ? question.answers.length : 0)}",
                          ),
                          question.answers != null ? Text(" • Last answered ${ _timeAgoText(question)}",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black26)) : Container()
*/
                          RichText(
                            text: TextSpan(
                              text: question.text +
                                  '? ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () async {
                                        setState(() {
                                          routePushed = true;
                                        });
                                        await Navigator.push(context,
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                              if (question.interest != null) {
                                                print(question.text);
                                                print("question.text");
                                                return QuestionInterestDetailsWidget(
                                                  question: question,
                                                );
                                              } else {
                                                print(question.text);
                                                print("question.text");
                                                return QuestionDetailsWidget(
                                                  question: question,
                                                  needFetch: false,
                                                );
                                              }
                                            }));
                                        setState(() {
                                          routePushed = false;
                                        });
                                      },
                                    text:
                                    "\n \n${question.answers.length} ${StringHelper.puralize("Answer", question.answers.length)} ",
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    children: <TextSpan> [
                                      TextSpan(
                                        text: " • ${timeago.format(
                                            DateTime.fromMillisecondsSinceEpoch(question.createdAt))}",
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                          ),

                        ]),



                    /*
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 0),
                        child: Column(
                          children: [
                            Text(
                              "${question.answers != null ? question.answers.length.toString() : 0} ${StringHelper.puralize("Answer", question.answers != null ? question.answers.length : 0)}",
                            )
                          ],
                        ),
                      ),
                      onTap: () async {
                        setState(() {
                          routePushed = true;
                        });
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          if (question.interest != null) {
                            return QuestionInterestDetailsWidget(
                              question: question,
                              needFetch: true,
                            );
                          } else {
                            print('QuestionDetailsWidget=>');
                            return QuestionDetailsWidget(
                              question: question,
                              needFetch: true,
                            );
                          }
                        }));
                        setState(() {
                          routePushed = false;
                        });
                      },
                    )*/
                  ],
                ),
                Container(
                    margin: EdgeInsets.only(top: 12),
                    color: Colors.transparent,
                    width: double.infinity,
                    height: 2),
                Container(height: 5),
              ],
            ),
          ),
          ..._answerDepends(question, index),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: SizedBox(),
          ),
          _actionsOnItem(
              question,
              question.answers[0].likes.toString(),
              question.answers[0].comments != null
                  ? question.answers[0].comments.length.toString()
                  : '0',
              question.shares.toString()),
        ],
      ),
    );
  }

  void _handleClick(String value, QuestionData question, User user) {
    switch (value) {
      case 'Delete':
        _deleteAnswer(question);
        break;
    }
  }

  _askerInfo(QuestionData question) {
    if (question.userAsked != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: question.privacy == AudienceType.Public
                ? ListTile(
                    onTap: () async {
                      setState(() {
                        routePushed = true;
                      });
                      await ProfileHelpers().navigationProfileHelper(
                          context, question.userAsked.id);
                      setState(() {
                        routePushed = false;
                      });
                    },
                    contentPadding: EdgeInsets.all(0),
                    leading: CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            question.userAsked.avatarImageProvider()),
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        children: <TextSpan>[
                          TextSpan(
                            text: "${question.userAsked.getFullName()}",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.0,
                              color: Color(0xFF282829),
                            ),
                          ), /*
                          TextSpan(
                            text: " • ${_timeAgoText(question, isAsker: true)}",
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                          )*/
                        ],
                      ),
                    ),
                    subtitle: Text(
                      _jobText(question, isAsker: true),
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                : ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            AssetImage('lib/assets/images/defaultUser.png')),
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Anonymous",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.0,
                              color: Color(0xFF282829),
                            ),
                          ),
                          TextSpan(
                            text: " • ${_timeAgoText(question, isAsker: true)}",
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          //widget.isUserLogged ?  GestureDetector(
          // onTap: () {
          // _deleteAnswer(question);
          //},
          //child: Container(
          //  alignment: Alignment.topCenter,
          //  width: 40,
          //   height: 40,
          //   child: Icon(Icons.close, color: Colors.grey[900]),
          // ),
          // ) : SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 15),
            child: Container(
              alignment: Alignment.topRight,
              width: 20,
              height: 30,
              child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.more_horiz),
                  onPressed: () {
                    showMaterialModalBottomSheet(
                      expand: false,
                      context: context,
                      builder: (context) => Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,
                                child: Center(
                                  child: Text(
                                    'Answer',
                                    style: TextStyle(
                                      color: Color(0xFF939598),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                              FlatButton(
                                onPressed: () {
                                  _deleteAnswer(question);
                                },
                                child: Text('Delete'),
                              ),
                              Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                              FlatButton(
                                  onPressed: () {
                                    showMaterialModalBottomSheet(
                                      context: context,
                                      builder: (context) => Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    'Report Answer',
                                                    style: TextStyle(
                                                      color: Color(0xFF939598),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                                height: 1,
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  _showReportSendSucessfullyDialog();
                                                },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Center(
                                                    child: Text('Harassment',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black))),
                                                height: 30,
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                                height: 1,
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  _showReportSendSucessfullyDialog();
                                                },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Center(
                                                    child: Text('Spam',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black))),
                                                height: 30,
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                                height: 1,
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  _showReportSendSucessfullyDialog();
                                                },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Center(
                                                  child: Text(
                                                      'Doesnt Answer the question',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                                height: 30,
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                                height: 1,
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  _showReportSendSucessfullyDialog();
                                                },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Center(
                                                    child: Text('Plagiarism',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black))),
                                                height: 30,
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                                height: 1,
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  _showReportSendSucessfullyDialog();
                                                },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Center(
                                                    child: Text('Joke Answer',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black))),
                                                height: 30,
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                                height: 1,
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  _showReportSendSucessfullyDialog();
                                                },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Center(
                                                    child: Text('Poor Video',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black))),
                                                height: 30,
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                                height: 1,
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  _showReportSendSucessfullyDialog();
                                                },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Center(
                                                    child: Text(
                                                        'Unhelpful Credential',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black))),
                                                height: 30,
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                                height: 1,
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  _showReportSendSucessfullyDialog();
                                                },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Center(
                                                    child: Text(
                                                  'Bad Quality',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )),
                                                height: 30,
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                                height: 1,
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  _showReportSendSucessfullyDialog();
                                                },
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: Center(
                                                    child: Text(
                                                  'Factually Incorrect',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )),
                                                height: 30,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Report',
                                    style: TextStyle(color: Colors.red),
                                    textAlign: TextAlign.start,
                                  )),
                              Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                            ],
                          ),
                          height: MediaQuery.of(context).size.height / 3),
                    );
                  }),
            ),
          )
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: SvgPicture.network(question.interest.icon)),
              title: Text('Question asked for ' + question.interest.label),
              subtitle: Text(timeago.format(
                  DateTime.fromMillisecondsSinceEpoch(question.createdAt))),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Icon(
              Icons.close,
              color: Colors.grey[900],
            ),
          )
        ],
      );
    }
  }

  void _deleteBottomSheet(context, question) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.delete, color: Colors.red),
                title: new Text('Delete Question'),
                onTap: () {
                  _deleteAnswer(question);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _timeAgoText(QuestionData question, {bool isAsker = false}) {
    String time = '';
    if (isAsker) {
      time = time = timeago
          .format(DateTime.fromMillisecondsSinceEpoch(question.createdAt));
    } else if (question.answer != null) {
      time = timeago.format(
          DateTime.fromMillisecondsSinceEpoch(question.answer.createdAt));
    }

    return time ?? "";
  }

  _jobText(QuestionData question, {bool isAsker = false}) {
    String job;
    if (isAsker) {
      job = StringUtils.defaultString(question.userAsked.job);
    } else {
      job = StringUtils.defaultString(question.answer.userAnswered.job);
    }

    return job ?? "";
  }

  _answerDepends(QuestionData question, int index) {
    if (question.answers != null && question.answers.length > 0) {
      print("_answerDepends" + question.answers[0].video);
      return [
        Stack(children: [
          Container(
              height: MediaQuery.of(context).size.height / 1.6,
              child: InViewNotifierWidget(
                id: '$index',
                builder: (BuildContext context, bool isInView, Widget child) {
                  return VideoWidget(
                    play: routePushed ? false : isInView,
                    url: question.answers[0].video,
                    question: question,
                    index: 0,
                  );
                },
              )),
          Positioned(
            top: 20,
            right: 10,
            child: Row(
              children: [
                Icon(
                  Icons.remove_red_eye,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "${question.answers[0].views} ${StringHelper.puralize("View", question.answers[0].views)}",
                  style: TextStyle(
                      //color: Color(0xFF636466),
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ])
      ];
    } else {
      return [
        SizedBox(),
      ];
    }
  }

  _individualItem(
    IconData icon,
    String number, {
    String answerId,
    Function f,
    bool userAffected = false,
    String questionId,
    QuestionData questionData,
    String type,
  }) {
    Color iconColor = Colors.grey[700];
    if (questionData != null && questionData.answers != null) {
      if (icon == FlutterIcons.thumbs_up_fea &&
          questionData.answers[0].userLike != null &&
          questionData.answers[0].userLike) {
        iconColor = Colors.blue;
      }
      return Container(
        //padding: EdgeInsets.only(top: 5.0, right: 20, left: 20, bottom: 0),
        child: GestureDetector(
          onTap: () {
            f(
              answerId,
              questionId: questionId,
              type: type,
              questionData: questionData,
            );
          },
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: iconColor,
                size: 22.0,
              ),
              Container(
                width: 8,
              ),
              Text(
                number,
                style: TextStyle(
                  color: icon == FlutterIcons.thumbs_up_fea &&
                          questionData.answers[0].userLike != null &&
                          questionData.answers[0].userLike
                      ? Colors.blue
                      : Colors.grey[700],
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  _actionsOnItem(QuestionData question, String likeCount, String commentCount,
      String shareCount) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _individualItem(FlutterIcons.thumbs_up_fea,
                    "${question.answers[0].likes} Like",
                    answerId: question.answers[0].id,
                    f: _like,
                    questionData: question,
                    userAffected: question.answers[0].userLike),
//                VerticalDivider(
//                  width: 20,
//                ),
                _individualItem(
                  FontAwesomeIcons.comment,
                  "${commentCount} Comment",
                  questionData: question,
                  answerId: question.answers[0].id,
                  f: _comments,
                ),
//                VerticalDivider(
//                  width:0,
//                ),
                _individualItem(
                  FlutterIcons.send_fea,
                  "${shareCount} Share",
                  questionData: question,
                  questionId: question.id,
                  answerId: question.answers[0].id,
                  type: "interest",
                  f: _share,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _share(String answerId,
      {String questionId, String type, QuestionData questionData}) async {
    var link = await DynamicLinkProvider.generateDynamicLink(
        "question",
        Map<String, dynamic>.from(
          {"qid": questionId, "type": type},
        ),
        questionData);
    final ShortDynamicLink shortenedLink =
        await DynamicLinkParameters.shortenUrl(Uri.parse(link.toString()));

    final Uri shortUrl = shortenedLink.shortUrl;

    await Share.share(shortUrl.toString());
    if (!questionData.userShare) {
      Response response =
          await FeedApiService().share(_userLogged.id, questionId);
      if (response.statusCode == 200) {
        setState(() {
          questionData.userShare = true;
          questionData.shares = questionData.shares + 1;
          _userLogged.questionsShared.add(questionData);
          Provider.of<UserProvider>(context, listen: false).updateProvider();
        });
      }
    }
  }

  _like(String answerId,
      {String questionId, String type, QuestionData questionData}) async {
    Response response;
    if (questionData.answers[0].userLike) {
      response = await QuestionApiService().dislike(_userLogged.id, answerId);
    } else {
      response = await QuestionApiService().like(_userLogged.id, answerId);
    }
    if (response.statusCode == 200) {
      if (questionData.answers[0].id == answerId) {
        setState(() {
          if (!questionData.answers[0].userLike) {
            questionData.answers[0].likes = questionData.answers[0].likes + 1;
            questionData.answers[0].userLike = true;
          } else {
            questionData.answers[0].likes = questionData.answers[0].likes - 1;
            questionData.answers[0].userLike = false;
          }
        });
      }
    }
  }

  _comments(String answerId,
      {String questionId, String type, QuestionData questionData}) async {
    setState(() {
      routePushed = true;
    });
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return CommentsWidget(
        answerId: answerId,
      );
    }));
    setState(() {
      routePushed = false;
    });
  }

  _deleteAnswer(QuestionData question) async {
    var result = await showDialog(
      context: context,
      builder:(context) => ConfirmDeleteDialog(
        title: 'Warning!',
        subtitle: 'Are you sure you want to delete this answer ?',
        onDelete: () {
          Navigator.pop(context, true);
        },
      ),
    );
    if (result) {
      Navigator.pop(context);
      Response response =
          await QuestionApiService().deleteAnswer(question.answers[0].id);

      if (response.statusCode == 200) {
        int index = _userLogged.questionsAnswered.indexWhere(
            (element) => element.answers[0].id == question.answers[0].id);
        _userLogged.questionsAnswered.removeAt(index);
        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: 'ERROR: Cannot delete answer',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0);
      }
    }
  }

  Future<void> _onRefresh() async {
    // monitor network fetch
    setState(() {
      routePushed = true;
    });
    await reloadUser();
    // if failed,use refreshFailed()
    // _refreshController.refreshCompleted();
  }

  Future<User> reloadUser() async {
    // widget.questions.clear();
    // for(int i=0;i<widget.questions.length;i++){
    //   widget.questions[i].answers.clear();
    // }

    // Provider.of<UserProvider>(context, listen: false).userLogged.questionsAnswered.clear();

    // routePushed = widget.routedPushed != null ? widget.routedPushed  ? true : routePushed : routePushed;
    // _userLogged = Provider.of<UserProvider>(context).userLogged;

    LocalStorage _storage = LocalStorage('mainStorage');
    if (await _storage.ready) {
      String authToken = _storage.getItem("authToken");
      Response response =
          await AuthApiService(token: authToken).getProfile(_userLogged.id);
      Provider.of<UserProvider>(context, listen: false).userLogged =
          User.fromJson(response.data);
      Provider.of<UserProvider>(context, listen: false).updateProvider();
    }

    // _user = Provider.of<UserProvider>(context, listen: true).userLogged;

    // routePushed = widget.routedPushed != null ? widget.routedPushed  ? true : routePushed : routePushed;
    // _userLogged = Provider.of<UserProvider>(context).userLogged;

    // if (response.statusCode == 200) {
    //   _userLogged=Provider.of<UserProvider>(context, listen: false).userLogged = User.fromJson(response.data);
    //   Provider.of<UserProvider>(context, listen: false).updateProvider();
    //
    //   print("response.statusCode");
    //   setState(() {});
    // }

    // _userLogged = Provider.of<UserProvider>(context).userLogged;

    // setState(() {
    //
    // });
    // initState();
    return _userLogged;
  }
}
