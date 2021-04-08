import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
import 'package:video_app/core/providers/permision_provider.dart';
import 'package:video_app/core/widgets/VideoWidget.dart';
import 'package:video_app/feed/api/FeedApiService.dart';
import 'package:video_app/feed/widgets/CommentsWidget.dart';
import 'package:video_app/feed/widgets/QuestionDetailsWidget.dart';
import 'package:video_app/feed/widgets/QuestionInterestDetails.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:video_app/profile/utils/StringHelper.dart';
import 'package:video_app/profile/widgets/ConfimDeleteDialog.dart';
import 'package:video_app/profile/widgets/EditQuestions.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/ask/AudienceSelect.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class QuestionsTabWidget extends StatefulWidget {
  final List<QuestionData> questions;
  final String view;
  final bool isUserLogged;
  final bool routedPushed;
  final bool isComefromAnotherProfile;
  var edit = false;

  QuestionsTabWidget(
      {this.questions,
      this.view,
      this.isUserLogged,
      this.routedPushed,
      this.isComefromAnotherProfile});

  @override
  _QuestionsTabWidgetState createState() => _QuestionsTabWidgetState();
}

class _QuestionsTabWidgetState extends State<QuestionsTabWidget> {
  List<Widget> listOfQuestionsWidgets = List<Widget>();
  bool loadedVideos = false;
  User _userLogged;
  bool routePushed = false;
  bool _isEnableVideoMenu = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context).userLogged;
    routePushed = widget.routedPushed != null
        ? widget.routedPushed
            ? true
            : routePushed
        : routePushed;
    final _blocPermission = Provider.of<PermisionProvider>(context);
    _removePrivateQuestionsOnOtherUser();
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Container(
        color: Colors.white,
        child: InViewNotifierList(
          padding: EdgeInsets.all(0),
          isInViewPortCondition:
              (double deltaTop, double deltaBottom, double viewPortDimension) {
            return deltaTop < (0.5 * viewPortDimension) &&
                deltaBottom > (0.5 * viewPortDimension);
          },
          itemCount: widget.questions.length,
          builder: (BuildContext context, int index) {
            print('check condition');
            if (widget.questions[index].answers.length > 0) {
              _isEnableVideoMenu = false;
            } else {
              _isEnableVideoMenu = true;
            }
            return _questionItem(
                index, widget.questions[index], _blocPermission);
          },
        ),
      ),
    );
  }

  // TODO: Delete Bottom Sheet
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
                  _deleteQuestion(question);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // TODO: questions
  /// clicked on questions
  /// clicked on answers and move to other screens
  _questionItem(
      int index, QuestionData question, PermisionProvider permisionProvider) {
    return Column(
      children: [
        Container(
          // padding: EdgeInsets.only(bottom: 0),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey[300], width: 8))),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10, right: 0),
                child: Column(
                  children: <Widget>[
                    question.answers != null && question.answers.length > 0
                        ? _askerInfo(question)
                        : _receiverInfo(question),
                    Container(
                      height: 5,
                    ),
                    //New Code Added for Question Tab
                    question.answers != null && question.answers.length > 0
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ProfileHelpers().isLoggedInAsker(
                                      question.userAsked.id, _userLogged.id)
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.only(left: 50),
                                      child: OutlineButton(
                                        onPressed: () async {
                                          setState(() {
                                            routePushed = true;
                                          });
                                          print('check status');
                                          await permisionProvider
                                              .getCameraPermission(
                                                  context, question);
                                          setState(() {
                                            routePushed = false;
                                          });
                                        },
                                        borderSide: BorderSide(
                                            color: Color(0xFF2E6AFF)),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              FlutterIcons.video_fea,
                                              color: Color(0xFF2E6AFF),
                                              size: 14.0,
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                            Text(
                                              'Answer',
                                              style: TextStyle(
                                                  color: Color(0xFF2E6AFF),
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ProfileHelpers().isLoggedInAsker(
                                      question.userAsked.id, _userLogged.id)
                                  ? SizedBox(width: 55)
                                  : Spacer(flex: 1),
                              ...[
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
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
                                          "${question.answers.length} ${StringHelper.puralize("Answer", question.answers.length)} ",
                                      style: TextStyle(
                                        color: Colors.black38,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text:
                                              " • ${timeago.format(DateTime.fromMillisecondsSinceEpoch(question.createdAt))}",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ]),
                                ),
                                Spacer(flex: 1),
                                GestureDetector(
                                  onTap: () async {
                                    var link = await DynamicLinkProvider
                                        .generateDynamicLink(
                                            "question",
                                            Map<String, dynamic>.from(
                                              {
                                                "qid": question.id,
                                                "type": "interest"
                                              },
                                            ),
                                            question);
                                    final ShortDynamicLink shortenedLink =
                                        await DynamicLinkParameters.shortenUrl(
                                            Uri.parse(link.toString()));

                                    final Uri shortUrl = shortenedLink.shortUrl;

                                    await Share.share(shortUrl.toString());
                                    if (!question.userShare) {
                                      Response response = await FeedApiService()
                                          .share(_userLogged.id, question.id);
                                      if (response.statusCode == 200) {
                                        setState(() {
                                          question.userShare = true;
                                          question.shares = question.shares + 1;
                                          _userLogged.questionsShared
                                              .add(question);
                                          Provider.of<UserProvider>(context,
                                                  listen: false)
                                              .updateProvider();
                                        });
                                      }
                                    }
                                  },
                                  //This is
                                  child: Container(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          question.answers.length.toString(),
                                          style: TextStyle(
                                            color: Color(0xFF2E6AFF),
                                          ),
                                        ),
                                        Icon(
                                          FlutterIcons.share_2_fea,
                                          color: Color(0xFF2E6AFF),
                                          size: 16.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  child: IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(Icons.more_vert),
                                      onPressed: () {
                                        showMaterialModalBottomSheet(
                                          expand: false,
                                          context: context,
                                          builder: (context) => Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    child: Center(
                                                      child: Text(
                                                        'Answer',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF939598),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                    color: Colors.grey,
                                                    height: 1,
                                                  ),
                                                  FlatButton(
                                                      onPressed: () {
                                                        showMaterialModalBottomSheet(
                                                          context: context,
                                                          builder: (context) =>
                                                              Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                2,
                                                            child:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    height: 40,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'Report Answer',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xFF939598),
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                    height: 1,
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      _showReportSendSucessfullyDialog();
                                                                    },
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: Center(
                                                                        child: Text(
                                                                            'Harassment',
                                                                            style:
                                                                                TextStyle(color: Colors.black))),
                                                                    height: 30,
                                                                  ),
                                                                  Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                    height: 1,
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      _showReportSendSucessfullyDialog();
                                                                    },
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: Center(
                                                                        child: Text(
                                                                            'Spam',
                                                                            style:
                                                                                TextStyle(color: Colors.black))),
                                                                    height: 30,
                                                                  ),
                                                                  Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                    height: 1,
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      _showReportSendSucessfullyDialog();
                                                                    },
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child:
                                                                        Center(
                                                                      child: Text(
                                                                          'Doesnt Answer the question',
                                                                          style:
                                                                              TextStyle(color: Colors.black)),
                                                                    ),
                                                                    height: 30,
                                                                  ),
                                                                  Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                    height: 1,
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      _showReportSendSucessfullyDialog();
                                                                    },
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: Center(
                                                                        child: Text(
                                                                            'Plagiarism',
                                                                            style:
                                                                                TextStyle(color: Colors.black))),
                                                                    height: 30,
                                                                  ),
                                                                  Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                    height: 1,
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      _showReportSendSucessfullyDialog();
                                                                    },
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: Center(
                                                                        child: Text(
                                                                            'Joke Answer',
                                                                            style:
                                                                                TextStyle(color: Colors.black))),
                                                                    height: 30,
                                                                  ),
                                                                  Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                    height: 1,
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      _showReportSendSucessfullyDialog();
                                                                    },
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: Center(
                                                                        child: Text(
                                                                            'Poor Video',
                                                                            style:
                                                                                TextStyle(color: Colors.black))),
                                                                    height: 30,
                                                                  ),
                                                                  Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                    height: 1,
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      _showReportSendSucessfullyDialog();
                                                                    },
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: Center(
                                                                        child: Text(
                                                                            'Unhelpful Credential',
                                                                            style:
                                                                                TextStyle(color: Colors.black))),
                                                                    height: 30,
                                                                  ),
                                                                  Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                    height: 1,
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      _showReportSendSucessfullyDialog();
                                                                    },
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: Center(
                                                                        child: Text(
                                                                      'Bad Quality',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                    )),
                                                                    height: 30,
                                                                  ),
                                                                  Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                    height: 1,
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      _showReportSendSucessfullyDialog();
                                                                    },
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: Center(
                                                                        child: Text(
                                                                      'Factually Incorrect',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black),
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
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                        textAlign:
                                                            TextAlign.start,
                                                      )),
                                                  Divider(
                                                    color: Colors.grey,
                                                    height: 1,
                                                  ),
                                                  _editButton(question),
                                                  Divider(
                                                    color: Colors.grey,
                                                    height: 1,
                                                  ),
                                                  _deleteButton(question),
                                                  Divider(
                                                    color: Colors.grey,
                                                    height: 1,
                                                  ),
                                                ],
                                              ),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3),
                                        );
                                      }),
                                ),
                              ],
                            ],
                          ),
//End Code Added for Question Tab
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
                        margin: EdgeInsets.only(top: 1), //12
                        color: Colors.transparent,
                        width: double.infinity,
                        height: 2),
                    Container(
                      height: 5,
                    ),
                  ],
                ),
              ),
              ..._answerDepends(question, index),
              Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 0),
                  child: SizedBox()),
              question.answers != null && question.answers.length > 0
                  ? _actionsOnItem(question)
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  // TODO: Report Success
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

  // TODO: Question Asker Info
  _askerInfo(QuestionData question) {
    if (question.userAsked != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListTile(
              onTap: () {},
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                  radius: 16,
                  backgroundImage: question.userAsked.avatarImageProvider()
                  //child: SvgPicture.network(question.interest.icon)
                  ),
              title: RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    children: <TextSpan>[
                      //TextSpan(text: 'Asked by '),
                      TextSpan(
                          text: question.userAsked.getFullName(),
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      //TextSpan(text: " • ${_timeAgoText(question)}")
                    ]),
              ),
              subtitle: Text(
                _jobText(question, isAsker: true),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: SvgPicture.network(question.interest.icon)),
              title: Text('Question asked for ' +
                  ((question.interest == null) ? '' : question.interest.label)),
              subtitle: Text(timeago.format(
                  DateTime.fromMillisecondsSinceEpoch(question.createdAt))),
            ),
          ),
        ],
      );
    }
  }

  void _handleClick(String value, QuestionData question, User user) {
    switch (value) {
      case 'Delete':
        _deleteQuestion(question);
        break;
    }
  }

  // TODO: Receiver Info
  /// Questions details shown
  /// actions like report, edit, delete
  /// used for user profile and other user profile must be check using isUserLogged.
  _receiverInfo(QuestionData question) {
    if (question.userReceived != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListTile(
              onTap: () {
                setState(() {
                  routePushed = true;
                });
                ProfileHelpers()
                    .navigationProfileHelper(context, question.userReceived.id);
                setState(() {
                  routePushed = false;
                });
              },
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                  radius: 16,
                  // backgroundImage: question.userReceived.avatarImageProvider()),
                  backgroundImage: widget.isComefromAnotherProfile
                      ? question.userReceived.avatarImageProvider()
                      : question.userAsked.avatarImageProvider()),
              // title: Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       question.answer != null
              //           ? 'Answered by ' + question.userReceived.getFullName()
              //           : 'Asked to ' + question.userReceived.getFullName(),
              //     ),
              //     Text(
              //       " • ${_timeAgoText(question, isAsker: question.answer == null)}",
              //       style: TextStyle(
              //         fontSize: 12.0,
              //       ),
              //     )
              //   ],
              // ),
              title: GestureDetector(
                onTap: () async {
                  setState(() {
                    routePushed = true;
                  });
                  print("line 145" + question.privacy.toString());
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.answer != null
                        ? 'Answered by ' + question.userReceived.getFullName()
                        : 'Asked to ' + question.userReceived.getFullName(),
                  ),
                  // Text(
                  //   " • ${_timeAgoText(question, isAsker: question.answer == null)}",
                  //   style: TextStyle(
                  //     fontSize: 12.0,
                  //   ),
                  // )
                ],
              ),
              // subtitle: Text(
              //   _jobText(question, isAsker: question.answer == null),
              //   style: TextStyle(fontSize: 12),
              // ),
            ),
          ),
          // Padding(
          //     padding: const EdgeInsets.only(top: 5, right: 15),
          //     child: Visibility(
          //       visible: _isEnableVideoMenu,
          //       child: !widget.isUserLogged
          //           ? Container(
          //         width: 20,
          //         height: 20,
          //         child: IconButton(
          //             alignment: Alignment.topRight,
          //             iconSize: 20,
          //             padding: EdgeInsets.all(0),
          //             icon: Icon(Icons.more_horiz),
          //             onPressed: () {
          //               showMaterialModalBottomSheet(
          //                 expand: false,
          //                 context: context,
          //                 builder: (context) => Container(
          //                     child: Column(
          //                       crossAxisAlignment:
          //                       CrossAxisAlignment.center,
          //                       children: [
          //                         Container(
          //                           height: 40,
          //                           child: Center(
          //                             child: Text(
          //                               'Question',
          //                               style: TextStyle(
          //                                 color: Color(0xFF939598),
          //                                 fontWeight: FontWeight.bold,
          //                               ),
          //                               textAlign: TextAlign.center,
          //                             ),
          //                           ),
          //                         ),
          //                         Divider(
          //                           color: Colors.grey,
          //                           height: 1,
          //                         ),
          //                         // FlatButton(
          //                         //   child: Text('Edit'),
          //                         //   onPressed: () {
          //                         //     print(
          //                         //         '########## ${question.userReceived.getFullName()}');
          //                         //     setState(() {
          //                         //       routePushed = true;
          //                         //     });
          //                         //     Navigator.push(context,
          //                         //         MaterialPageRoute(builder:
          //                         //             (BuildContext context) {
          //                         //       return AskQuestionUpdateWidget(
          //                         //         question: question,
          //                         //       );
          //                         //     }));
          //                         //     setState(() {
          //                         //       routePushed = false;
          //                         //     });
          //                         //   },
          //                         // ),
          //                         // Divider(
          //                         //   color: Colors.grey,
          //                         //   height: 1,
          //                         // ),
          //                         // FlatButton(
          //                         //     onPressed: () {
          //                         //       _deleteQuestion(question);
          //                         //     },
          //                         //     child: Text('Delete')),
          //                         // Divider(
          //                         //   color: Colors.grey,
          //                         //   height: 1,
          //                         // ),
          //                         FlatButton(
          //                             onPressed: () {
          //                               showMaterialModalBottomSheet(
          //                                 context: context,
          //                                 builder: (context) => Container(
          //                                   height: MediaQuery.of(context)
          //                                       .size
          //                                       .height /
          //                                       2,
          //                                   child: SingleChildScrollView(
          //                                     child: Column(
          //                                       children: [
          //                                         Container(
          //                                           height: 40,
          //                                           child: Center(
          //                                             child: Text(
          //                                               'Report Answer',
          //                                               style: TextStyle(
          //                                                 color: Color(
          //                                                     0xFF939598),
          //                                                 fontWeight:
          //                                                 FontWeight
          //                                                     .bold,
          //                                               ),
          //                                               textAlign:
          //                                               TextAlign
          //                                                   .center,
          //                                             ),
          //                                           ),
          //                                         ),
          //                                         Divider(
          //                                           color: Colors.grey,
          //                                           height: 1,
          //                                         ),
          //                                         FlatButton(
          //                                           onPressed: () {
          //                                             _showReportSendSucessfullyDialog();
          //                                           },
          //                                           splashColor: Colors
          //                                               .transparent,
          //                                           highlightColor: Colors
          //                                               .transparent,
          //                                           child: Center(
          //                                               child: Text(
          //                                                   'Harassment',
          //                                                   style: TextStyle(
          //                                                       color: Colors
          //                                                           .black))),
          //                                           height: 30,
          //                                         ),
          //                                         Divider(
          //                                           color: Colors.grey,
          //                                           height: 1,
          //                                         ),
          //                                         FlatButton(
          //                                           onPressed: () {
          //                                             _showReportSendSucessfullyDialog();
          //                                           },
          //                                           splashColor: Colors
          //                                               .transparent,
          //                                           highlightColor: Colors
          //                                               .transparent,
          //                                           child: Center(
          //                                               child: Text(
          //                                                   'Spam',
          //                                                   style: TextStyle(
          //                                                       color: Colors
          //                                                           .black))),
          //                                           height: 30,
          //                                         ),
          //                                         Divider(
          //                                           color: Colors.grey,
          //                                           height: 1,
          //                                         ),
          //                                         FlatButton(
          //                                           onPressed: () {
          //                                             _showReportSendSucessfullyDialog();
          //                                           },
          //                                           splashColor: Colors
          //                                               .transparent,
          //                                           highlightColor: Colors
          //                                               .transparent,
          //                                           child: Center(
          //                                             child: Text(
          //                                                 'Doesnt Answer the question',
          //                                                 style: TextStyle(
          //                                                     color: Colors
          //                                                         .black)),
          //                                           ),
          //                                           height: 30,
          //                                         ),
          //                                         Divider(
          //                                           color: Colors.grey,
          //                                           height: 1,
          //                                         ),
          //                                         FlatButton(
          //                                           onPressed: () {
          //                                             _showReportSendSucessfullyDialog();
          //                                           },
          //                                           splashColor: Colors
          //                                               .transparent,
          //                                           highlightColor: Colors
          //                                               .transparent,
          //                                           child: Center(
          //                                               child: Text(
          //                                                   'Plagiarism',
          //                                                   style: TextStyle(
          //                                                       color: Colors
          //                                                           .black))),
          //                                           height: 30,
          //                                         ),
          //                                         Divider(
          //                                           color: Colors.grey,
          //                                           height: 1,
          //                                         ),
          //                                         FlatButton(
          //                                           onPressed: () {
          //                                             _showReportSendSucessfullyDialog();
          //                                           },
          //                                           splashColor: Colors
          //                                               .transparent,
          //                                           highlightColor: Colors
          //                                               .transparent,
          //                                           child: Center(
          //                                               child: Text(
          //                                                   'Joke Answer',
          //                                                   style: TextStyle(
          //                                                       color: Colors
          //                                                           .black))),
          //                                           height: 30,
          //                                         ),
          //                                         Divider(
          //                                           color: Colors.grey,
          //                                           height: 1,
          //                                         ),
          //                                         FlatButton(
          //                                           onPressed: () {
          //                                             _showReportSendSucessfullyDialog();
          //                                           },
          //                                           splashColor: Colors
          //                                               .transparent,
          //                                           highlightColor: Colors
          //                                               .transparent,
          //                                           child: Center(
          //                                               child: Text(
          //                                                   'Poor Video',
          //                                                   style: TextStyle(
          //                                                       color: Colors
          //                                                           .black))),
          //                                           height: 30,
          //                                         ),
          //                                         Divider(
          //                                           color: Colors.grey,
          //                                           height: 1,
          //                                         ),
          //                                         FlatButton(
          //                                           onPressed: () {
          //                                             _showReportSendSucessfullyDialog();
          //                                           },
          //                                           splashColor: Colors
          //                                               .transparent,
          //                                           highlightColor: Colors
          //                                               .transparent,
          //                                           child: Center(
          //                                               child: Text(
          //                                                   'Unhelpful Credential',
          //                                                   style: TextStyle(
          //                                                       color: Colors
          //                                                           .black))),
          //                                           height: 30,
          //                                         ),
          //                                         Divider(
          //                                           color: Colors.grey,
          //                                           height: 1,
          //                                         ),
          //                                         FlatButton(
          //                                           onPressed: () {
          //                                             _showReportSendSucessfullyDialog();
          //                                           },
          //                                           splashColor: Colors
          //                                               .transparent,
          //                                           highlightColor: Colors
          //                                               .transparent,
          //                                           child: Center(
          //                                               child: Text(
          //                                                 'Bad Quality',
          //                                                 style: TextStyle(
          //                                                     color: Colors
          //                                                         .black),
          //                                               )),
          //                                           height: 30,
          //                                         ),
          //                                         Divider(
          //                                           color: Colors.grey,
          //                                           height: 1,
          //                                         ),
          //                                         FlatButton(
          //                                           onPressed: () {
          //                                             _showReportSendSucessfullyDialog();
          //                                           },
          //                                           splashColor: Colors
          //                                               .transparent,
          //                                           highlightColor: Colors
          //                                               .transparent,
          //                                           child: Center(
          //                                               child: Text(
          //                                                 'Factually Incorrect',
          //                                                 style: TextStyle(
          //                                                     color: Colors
          //                                                         .black),
          //                                               )),
          //                                           height: 30,
          //                                         )
          //                                       ],
          //                                     ),
          //                                   ),
          //                                 ),
          //                               );
          //                             },
          //                             child: Text(
          //                               'Report',
          //                               style:
          //                               TextStyle(color: Colors.red),
          //                               textAlign: TextAlign.start,
          //                             )),
          //                         Divider(
          //                           color: Colors.grey,
          //                           height: 1,
          //                         ),
          //                       ],
          //                     ),
          //                     height:
          //                     MediaQuery.of(context).size.height / 3),
          //               );
          //             }),
          //       )
          //           : Container(
          //         width: 20,
          //         height: 20,
          //         child: IconButton(
          //             alignment: Alignment.topRight,
          //             iconSize: 20,
          //             padding: EdgeInsets.all(0),
          //             icon: Icon(Icons.more_horiz),
          //             onPressed: () {
          //               showMaterialModalBottomSheet(
          //                 expand: false,
          //                 context: context,
          //                 builder: (context) => Container(
          //                     child: Column(
          //                       crossAxisAlignment:
          //                       CrossAxisAlignment.center,
          //                       children: [
          //                         Container(
          //                           height: 40,
          //                           child: Center(
          //                             child: Text(
          //                               'Question',
          //                               style: TextStyle(
          //                                 color: Color(0xFF939598),
          //                                 fontWeight: FontWeight.bold,
          //                               ),
          //                               textAlign: TextAlign.center,
          //                             ),
          //                           ),
          //                         ),
          //                         Divider(
          //                           color: Colors.grey,
          //                           height: 1,
          //                         ),
          //                         FlatButton(
          //                           child: Text('Edit'),
          //                           onPressed: () async {
          //                             setState(() {
          //                               routePushed = true;
          //                             });
          //                                 await Navigator.push(context,
          //                                 MaterialPageRoute(builder:
          //                                     (BuildContext context) {
          //                                   return AskQuestionUpdateWidget(
          //                                     question: question,
          //                                   );
          //                                 }));
          //                             setState(() {
          //                               routePushed = false;
          //                             });
          //                           },
          //                         ),
          //                         Divider(
          //                           color: Colors.grey,
          //                           height: 1,
          //                         ),
          //                         FlatButton(
          //                             onPressed: () {
          //                               _deleteQuestion(question);
          //                             },
          //                             child: Text('Delete')),
          //                         Divider(
          //                           color: Colors.grey,
          //                           height: 1,
          //                         ),
          //                         Divider(
          //                           color: Colors.grey,
          //                           height: 1,
          //                         ),
          //                       ],
          //                     ),
          //                     height:
          //                     MediaQuery.of(context).size.height / 3),
          //               );
          //             }),
          //       ),
          //     ))
          _editButton(question),
          _deleteButton(question)
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: widget.isComefromAnotherProfile
                  ? CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      //child: SvgPicture.network(question.interest.icon))
                      backgroundImage: question.userAsked.avatarImageProvider())
                  : CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          question.userAsked.avatarImageProvider()),
              //backgroundImage: _userLogged.avatarImageProvider()),
              // title: Text('Question asked on ' + question.interest.label),
              // subtitle: Text(timeago.format(
              //     DateTime.fromMillisecondsSinceEpoch(question.createdAt))),
              title: question.answers != null && question.answers.length > 0
                  ? Text('Question asked on ' + question.interest.label)
                  : GestureDetector(
                      onTap: () async {
                        setState(() {
                          routePushed = true;
                        });

                        print("line 145" + question.privacy.toString());
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
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
              subtitle: question.answers != null && question.answers.length > 0
                  ? Text(timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(question.createdAt)))
                  : Text('Question asked on ' + question.interest.label),
            ),
          ),
          //Start Change Question Tab
          question.answers != null && question.answers.length > 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 5, right: 15),
                  child: !widget.isUserLogged
                      ? Container(
                          width: 20,
                          height: 20,
                          child: IconButton(
                              alignment: Alignment.topRight,
                              iconSize: 20,
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.more_horiz),
                              onPressed: () {
                                showMaterialModalBottomSheet(
                                  expand: false,
                                  context: context,
                                  builder: (context) => Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 40,
                                            child: Center(
                                              child: Text(
                                                'Question',
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
                                          // FlatButton(
                                          //   child: Text('Edit'),
                                          //   onPressed: () {
                                          //     print(
                                          //         '########## ${question.userReceived.getFullName()}');
                                          //     setState(() {
                                          //       routePushed = true;
                                          //     });
                                          //     Navigator.push(context,
                                          //         MaterialPageRoute(builder:
                                          //             (BuildContext context) {
                                          //       return AskQuestionUpdateWidget(
                                          //         question: question,
                                          //       );
                                          //     }));
                                          //     setState(() {
                                          //       routePushed = false;
                                          //     });
                                          //   },
                                          // ),
                                          // Divider(
                                          //   color: Colors.grey,
                                          //   height: 1,
                                          // ),
                                          // FlatButton(
                                          //     onPressed: () {
                                          //       _deleteQuestion(question);
                                          //     },
                                          //     child: Text('Delete')),
                                          // Divider(
                                          //   color: Colors.grey,
                                          //   height: 1,
                                          // ),
                                          FlatButton(
                                              onPressed: () {
                                                showMaterialModalBottomSheet(
                                                  context: context,
                                                  builder: (context) =>
                                                      Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            height: 40,
                                                            child: Center(
                                                              child: Text(
                                                                'Report Answer',
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFF939598),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
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
                                                            splashColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Center(
                                                                child: Text(
                                                                    'Harassment',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black))),
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
                                                            splashColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Center(
                                                                child: Text(
                                                                    'Spam',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black))),
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
                                                            splashColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Center(
                                                              child: Text(
                                                                  'Doesnt Answer the question',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black)),
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
                                                            splashColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Center(
                                                                child: Text(
                                                                    'Plagiarism',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black))),
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
                                                            splashColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Center(
                                                                child: Text(
                                                                    'Joke Answer',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black))),
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
                                                            splashColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Center(
                                                                child: Text(
                                                                    'Poor Video',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black))),
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
                                                            splashColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Center(
                                                                child: Text(
                                                                    'Unhelpful Credential',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black))),
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
                                                            splashColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Center(
                                                                child: Text(
                                                              'Bad Quality',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
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
                                                            splashColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Center(
                                                                child: Text(
                                                              'Factually Incorrect',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
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
                                                style: TextStyle(
                                                    color: Colors.red),
                                                textAlign: TextAlign.start,
                                              )),
                                          Divider(
                                            color: Colors.grey,
                                            height: 1,
                                          ),
                                        ],
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3),
                                );
                              }),
                        )
                      : Container(
                          width: 20,
                          height: 20,
                          child: IconButton(
                              alignment: Alignment.topRight,
                              iconSize: 20,
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.more_horiz),
                              onPressed: () {
                                showMaterialModalBottomSheet(
                                  expand: false,
                                  context: context,
                                  builder: (context) => Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 40,
                                            child: Center(
                                              child: Text(
                                                'Question',
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
                                            child: Text('Edit'),
                                            onPressed: () {
                                              setState(() {
                                                routePushed = true;
                                              });
                                              this.widget.edit = true;
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder:
                                                      (BuildContext context) {
                                                return AskQuestionUpdateWidget(
                                                  question: question,
                                                );
                                              }));
                                              setState(() {
                                                routePushed = false;
                                              });
                                            },
                                          ),
                                          Divider(
                                            color: Colors.grey,
                                            height: 1,
                                          ),
                                          FlatButton(
                                              onPressed: () {
                                                _deleteQuestion(question);
                                              },
                                              child: Text('Delete')),
                                          Divider(
                                            color: Colors.grey,
                                            height: 1,
                                          ),
                                          Divider(
                                            color: Colors.grey,
                                            height: 1,
                                          ),
                                        ],
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3),
                                );
                              }),
                        ))
              : SizedBox()

          //End of Change Question Tab

          //       _editButton(question),
          //      _deleteButton(question)
        ],
      );
    }
  }

  // TODO: Answer widget
  /// includes video
  _answerDepends(QuestionData question, int index) {
    if (question.answers != null && question.answers.length > 0) {
      return [
        Container(
            height: MediaQuery.of(context).size.height / 1.6,
            child: Stack(children: [
              InViewNotifierWidget(
                id: '$index',
                builder: (BuildContext context, bool isInView, Widget child) {
                  return VideoWidget(
                    play: isInView,
                    url: question.answers[0].video,
                    question: question,
                    index: 0,
                  );
                },
              ),
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
            ])),
      ];
    } else {
      return [SizedBox()];
    }
  }

  // TODO: Actions Button
  /// Like comment share
  _actionsOnItem(QuestionData question) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
        ),
        SizedBox(
          height: 0.0,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10),
          child: SizedBox(),
        ),
        Container(
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
//                    VerticalDivider(
//                      width: 20,
//                    ),
                    _individualItem(
                      FontAwesomeIcons.comment,
                      "${question.answers[0].comments != null ? question.answers[0].comments.length : 0} Comment",
                      questionData: question,
                      answerId: question.answers[0].id,
                      f: _comments,
                    ),
//                    VerticalDivider(
//                      width: 20,
//                    ),
                    _individualItem(
                      FlutterIcons.send_fea,
                      "${question.shares} Share",
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
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  // TODO: Share Button
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

  // TODO: Like Button
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

  // TODO: Comments Button
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
      if (icon == FlutterIcons.thumbs_up_fea && userAffected) {
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
                  color: icon == FlutterIcons.thumbs_up_fea && userAffected
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

  // TODO: JOb Text
  _jobText(QuestionData question, {bool isAsker = true}) {
    String job;
    if (isAsker) {
      if (question.userAsked == null) {
        return "";
      }
      job = StringUtils.defaultString(question.userAsked.job);
    } else {
      job = StringUtils.defaultString(question.answer.userAnswered.job);
    }

    return job ?? "";
  }

  // TODO: Time Ago Text
  String _timeAgoText(dynamic obj, {bool isAsker = true}) {
    String time = '';
    if (isAsker) {
      time = timeago.format(DateTime.fromMillisecondsSinceEpoch(obj.createdAt));
    } else {
      time = timeago
          .format(DateTime.fromMillisecondsSinceEpoch(obj.answer.createdAt));
    }

    return time;
  }

  // TODO: Delete Question
  _deleteQuestion(QuestionData question) async {
    var result = await showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: 'Warning!',
        subtitle: 'Are you sure you want to delete this question ?',
        onDelete: () {
          Navigator.pop(context, true);
        },
      ),
    );
    if (result) {
      Response response =
          await QuestionApiService().deleteQuestion(question.id);

      if (response.statusCode == 200) {
        int index = _userLogged.questionsAsked
            .indexWhere((element) => element.id == question.id);
        _userLogged.questionsAsked.removeAt(index);
        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: 'ERROR: Cannot delete question',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  // TODO: Delete Button
  _deleteButton(QuestionData question) {
    if (question.answer == null && widget.isUserLogged) {
      return GestureDetector(
        onTap: () {
          _deleteQuestion(question);
        },
        child: Container(
          alignment: Alignment.topCenter,
          width: 50,
          height: 40,
          child: Center(
              child: Text('Delete', style: TextStyle(color: Colors.red))),
          // child: Icon(
          //   Icons.close,
          //   color: Colors.grey[900],
          // ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  // TODO: Edit Button
  _editButton(QuestionData question) {
    if (question.answer == null && widget.isUserLogged) {
      return GestureDetector(
        onTap: () async {
          // print('########## ${question.userReceived.getFullName()}');
          setState(() {
            routePushed = true;
          });
          await Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return AskQuestionUpdateWidget(
              question: question,
            );
          }));
          setState(() {
            routePushed = false;
          });
        },
        child: Container(
          alignment: Alignment.topCenter,
          width: 40,
          height: 40,
          child:
              Center(child: Text('Edit', style: TextStyle(color: Colors.blue))),
          // child: Icon(
          //   Icons.edit,
          //   color: Colors.grey[900],
          // ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  // TODO: On Refresh Button
  Future<void> _onRefresh() async {
    // monitor network fetch
    await reloadUser();
    setState(() {});
    // if failed,use refreshFailed()
    // _refreshController.refreshCompleted();
  }

  // TODO: Reload Button
  Future<User> reloadUser() async {
    LocalStorage _storage = LocalStorage('mainStorage');
    if (await _storage.ready) {
      String authToken = _storage.getItem("authToken");
      Response response =
          await AuthApiService(token: authToken).getProfile(_userLogged.id);
      Provider.of<UserProvider>(context, listen: false).userLogged =
          User.fromJson(response.data);
      Provider.of<UserProvider>(context, listen: false).updateProvider();
    }
    return _userLogged;
  }

  // TODO: Remove Questions on other user
  _removePrivateQuestionsOnOtherUser() {
    if (!widget.isUserLogged) {
      widget.questions
          .removeWhere((element) => element.privacy == AudienceType.Anonymous);
    }
  }
}
