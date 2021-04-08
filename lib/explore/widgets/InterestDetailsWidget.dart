import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/DynamicLinkProvider.dart';
import 'package:video_app/core/providers/permision_provider.dart';
import 'package:video_app/core/widgets/VideoWidget.dart';
import 'package:video_app/feed/api/FeedApiService.dart';
import 'package:video_app/feed/widgets/CommentsWidget.dart';
import 'package:video_app/feed/widgets/QuestionInterestDetails.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:video_app/profile/utils/StringHelper.dart';
import 'package:video_app/questions/Widgets/CameraWidget.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/ask/AskQuestionWidget.dart';
import 'package:video_app/questions/models/Answer.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class InterestDetailsWidget extends StatefulWidget {
  final Interest interest;

  InterestDetailsWidget({this.interest});

  @override
  _InterestDetailsWidgetState createState() => _InterestDetailsWidgetState();
}

class _InterestDetailsWidgetState extends State<InterestDetailsWidget> {
  List<QuestionData> _questions = List<QuestionData>();
  bool routePushed = false;
  User _userLogged;
  bool dataLoaded = false;
  bool iFollow = false;

  @override
  Widget build(BuildContext context) {
    final _blocPermission = Provider.of<PermisionProvider>(context);
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    iFollow =
        ProfileHelpers().isFollowThisInterest(context, widget.interest.id);

    return Material(
      child: FutureBuilder(
          future: _getQuestionBasedOnInterest(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return _mainWidget(_blocPermission);
              } else {
                return Container(
                  child: Text('error'),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  _getQuestionBasedOnInterest() async {
    if (!dataLoaded) {
      Response response = await QuestionApiService()
          .getQuestionsByInterest(widget.interest.id, _userLogged.id);
      dataLoaded = true;
      if (response.statusCode == 200) {
        response.data.forEach((x) {
          _questions.add(QuestionData.fromJson(x));
        });
        return _questions;
      } else if (response.statusCode == 422) {
        return _questions;
      } else {
        Fluttertoast.showToast(
            msg: 'Error: cannot fetch Questions',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return false;
      }
    } else {
      return _questions;
    }
  }

  _mainWidget(PermisionProvider permisionProvider) {
    return _videoList(permisionProvider);
  }

  Widget sectionHeading() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 1,
        margin: EdgeInsets.all(0),
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent, width: 2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      widget.interest.icon,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StringUtils.capitalize(
                        widget.interest.label,
                        allWords: true,
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color(
                          0xFF333333,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(child: _followButton()),
                        Container(
                          width: 10,
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () async {
                              setState(() {
                                routePushed = true;
                              });
                              await Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return AskQuestionWidget(
                                        interestToAsk: widget.interest);
                                  }));
                              setState(() {
                                routePushed = false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.black)),
                            child: Text('Ask Question',
                                style: TextStyle(color: Colors.black)),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _videoList(PermisionProvider permisionProvider) {
    if (_questions.length > 0) {
      return Column(
        children: [
          Expanded(
            child: InViewNotifierList(
              isInViewPortCondition: (double deltaTop, double deltaBottom,
                  double viewPortDimension) {
                return deltaTop < (0.5 * viewPortDimension + 150) &&
                    deltaBottom > (0.5 * viewPortDimension + 150);
              },
              itemCount: _questions.length,
              builder: (BuildContext context, int index) {
                return _questionItem(_questions[index], index,permisionProvider);
              },
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          // sectionHeading(),
          Expanded(
            child: Center(
              child: Text('No questions available. Be the first to ask'),
            ),
          ),
        ],
      );
    }
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

  _questionItem(QuestionData question, int index,PermisionProvider permisionProvider) {
    var texttodis;
    if(question.privacy.toString() == 'AudienceType.Public'){
      texttodis = question.userAsked.getFullName() +' is looking for an answer.';
    }else {
      texttodis = 'An anonymous user is looking for an answer.';
    }
    return Column(
      children: [
        //index == 0 ? sectionHeading() : SizedBox(),
        Container(
          padding: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey[300], width: 8))),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    (question.answers.length == 0)
                        ? Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 20),
                                child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage: question.privacy.toString() == 'AudienceType.Public'
                                        ? question.userAsked.avatarImageProvider():AssetImage('lib/assets/images/defaultUser.png'),
                                  /*question.userAsked.privateProfile ? NetworkImage(
                                        question.userAsked.avatar)
                                        : AssetImage(
                                        'lib/assets/images/defaultUser.png')*/),
                              ),
//                              Container(
//                                margin: EdgeInsets.only(right: 8),
//                                width: 40,
//                                height: 40,
//                                decoration: BoxDecoration(
//                                  color: Colors.black,
//                                  shape: BoxShape.circle,
//                                  image: DecorationImage(
//                                    fit: BoxFit.cover,
//                                    image: question.userAsked.avatar != null ? NetworkImage(
//                                        question.userAsked.avatar
//                                    ):AssetImage('lib/assets/images/defaultUser.png')
//                                  )
//                                ),
//                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      routePushed = true;
                                    });
                                    print("line 308");
                                    await Navigator.push(context,
                                        MaterialPageRoute(builder:
                                            (BuildContext context) {
                                          return QuestionInterestDetailsWidget(
                                              question: question);
                                        }));
                                    setState(() {
                                      routePushed = false;
                                    });
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
//                                      Text(
//                                        "Interest Question",
//                                        style: TextStyle(
//                                          color: Color(0xFF939598),
//                                          fontSize: 12
//                                        ),
//                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 5),
                                        width: double.infinity,
                                        child: Text(
                                              question.text +
                                              '?',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          Flexible(
                                         child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: <Widget>[
                                                Text(
                                                  texttodis,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12),
                                                ),
                                                _checkAnswered(question)
                                                    ? SizedBox()
                                                    : Container(
                                                  child: Text(
                                                    'Asked ${_timeAgoText(question)}',
                                                    style:
                                                    TextStyle(
                                                      color: Color(
                                                          0xFF939598),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.only(right: 0),
                              //   child: Row(
                              //     crossAxisAlignment: CrossAxisAlignment.end,
                              //     children: [
                              //       Text(
                              //         "${question.answers != null ? question.answers.length : 0} ${StringHelper.puralize("Answer", question.answers != null ? question.answers.length : 0)}",
                              //       )
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                          SizedBox(height: 5.0),
                          Container(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              ProfileHelpers().isLoggedInAsker(
                                  question.userAsked.id,
                                  _userLogged.id)
                                  ? SizedBox()
                                  : Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin:
                                    EdgeInsets.only(left: 50),
                                    child: OutlineButton(
                                      onPressed: () async {
                                        setState(() {
                                          routePushed = true;
                                        });
                                        print('check status');
                                        await permisionProvider.getCameraPermission(context,question);
                                        setState(() {
                                          routePushed = false;
                                        });
                                      },
                                      borderSide: BorderSide(
                                          color: Color(0xFF2E6AFF)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              50)),
                                      child: Row(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          Icon(
                                            FlutterIcons.video_fea,
                                            color:
                                            Color(0xFF2E6AFF),
                                            size: 14.0,
                                          ),
                                          Container(
                                            width: 10,
                                          ),
                                          Text(
                                            'Answer',
                                            style: TextStyle(
                                                color: Color(
                                                    0xFF2E6AFF),
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
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
                                          ),question);
                                      final ShortDynamicLink
                                      shortenedLink =
                                      await DynamicLinkParameters
                                          .shortenUrl(Uri.parse(
                                          link.toString()));

                                      final Uri shortUrl =
                                          shortenedLink.shortUrl;

                                      await Share.share(
                                          shortUrl.toString());
                                      if (!question.userShare) {
                                        Response response =
                                        await FeedApiService().share(
                                            _userLogged.id,
                                            question.id);
                                        if (response.statusCode == 200) {
                                          setState(() {
                                            question.userShare = true;
                                            question.shares =
                                                question.shares + 1;
                                            _userLogged.questionsShared
                                                .add(question);
                                            Provider.of<UserProvider>(
                                                context,
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
                                            question.shares.toString(),
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
                                            builder: (context) =>
                                                Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          child: Center(
                                                            child: Text(
                                                              'Answer',
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
                                                          color:
                                                          Colors.grey,
                                                          height: 1,
                                                        ),
                                                        FlatButton(
                                                            onPressed:
                                                                () {
                                                              showMaterialModalBottomSheet(
                                                                context:
                                                                context,
                                                                builder:
                                                                    (context) =>
                                                                    Container(
                                                                      height:
                                                                      MediaQuery.of(context).size.height /
                                                                          2,
                                                                      child:
                                                                      SingleChildScrollView(
                                                                        child:
                                                                        Column(
                                                                          children: [
                                                                            Container(
                                                                              height: 40,
                                                                              child: Center(
                                                                                child: Text(
                                                                                  'Report Answer',
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
                                                                                _showReportSendSucessfullyDialog();
                                                                              },
                                                                              splashColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              child: Center(child: Text('Harassment', style: TextStyle(color: Colors.black))),
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
                                                                              highlightColor: Colors.transparent,
                                                                              child: Center(child: Text('Spam', style: TextStyle(color: Colors.black))),
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
                                                                              highlightColor: Colors.transparent,
                                                                              child: Center(
                                                                                child: Text('Doesnt Answer the question', style: TextStyle(color: Colors.black)),
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
                                                                              highlightColor: Colors.transparent,
                                                                              child: Center(child: Text('Plagiarism', style: TextStyle(color: Colors.black))),
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
                                                                              highlightColor: Colors.transparent,
                                                                              child: Center(child: Text('Joke Answer', style: TextStyle(color: Colors.black))),
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
                                                                              highlightColor: Colors.transparent,
                                                                              child: Center(child: Text('Poor Video', style: TextStyle(color: Colors.black))),
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
                                                                              highlightColor: Colors.transparent,
                                                                              child: Center(child: Text('Unhelpful Credential', style: TextStyle(color: Colors.black))),
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
                                                                              highlightColor: Colors.transparent,
                                                                              child: Center(
                                                                                  child: Text(
                                                                                    'Bad Quality',
                                                                                    style: TextStyle(color: Colors.black),
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
                                                                              highlightColor: Colors.transparent,
                                                                              child: Center(
                                                                                  child: Text(
                                                                                    'Factually Incorrect',
                                                                                    style: TextStyle(color: Colors.black),
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
                                                                  color: Colors
                                                                      .red),
                                                              textAlign:
                                                              TextAlign
                                                                  .start,
                                                            )),
                                                        Divider(
                                                          color:
                                                          Colors.grey,
                                                          height: 1,
                                                        ),
                                                      ],
                                                    ),
                                                    height: MediaQuery.of(
                                                        context)
                                                        .size
                                                        .height /
                                                        3),
                                          );
                                        }),
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 0,
                          ),
                        ],
                      ),
                      //color: Colors.grey[300]
                    )
                        : SizedBox(),
                    question.answers != null
                        ? Container(
                      //margin: EdgeInsets.only(top: 12),
                      //color: Colors.grey[300],
                      //width: double.infinity,
                      //height: 2,
                    )
                        : SizedBox(),
                    _receiverInfo(question),
                    Container(
                      height: 5,
                    ),
                  ],
                ),
              ),
              ..._answerDepends(question, index),
            ],
          ),
        ),
      ],
    );
  }

  _jobText(dynamic obj, {bool isAsker = true}) {
    String job = isAsker ? obj.userAsked.job : "";
    return job ?? "";
  }

  bool _checkAnswered(QuestionData question) {
    return question.answers != null;
  }

  _receiverInfo(QuestionData question) {
    if (question.answers != null && question.answers.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
//          Container(
//            padding:
//            EdgeInsets.only(top: 6),
//            width: double.infinity,
//            child: Text(
//              StringUtils.capitalize(question.text) +
//                  '?',
//              style: TextStyle(
//                  fontSize: 14,
//                  fontWeight: FontWeight.bold),
//            ),
//          ),
//          ProfileHelpers().isLoggedInAsker(
//              question.userAsked.id, _userLogged.id)
//              ? SizedBox()
//              : GestureDetector(
//            onTap: () async {
//              setState(() {
//                routePushed = true;
//              });
//              await Navigator.push(context,
//                  MaterialPageRoute(
//                      builder: (BuildContext context) {
//                        return CameraWidget(question: question);
//                      }));
//              setState(() {
//                routePushed = false;
//              });
//            },
//            child: Container(
//              width: 100,
//              decoration: BoxDecoration(
//                  border: Border.all(color:  Color(0xFF2E6AFF),
//                  ),
//                  borderRadius: BorderRadius.circular(999)
//              ),
//              padding: EdgeInsets.all(10),
//              margin: EdgeInsets.only(left: 6,top: 6),
//              child: Row(
//                children: <Widget>[
//                  Icon(
//                    FlutterIcons.video_fea,
//                    color: Color(0xFF2E6AFF),
//                    size: 16.0,
//                  ),
//                  Container(
//                    width: 10,
//                  ),
//                  Text(
//                    'Answer',
//                    style: TextStyle(
//                      //fontWeight: FontWeight.bold,
//                      color: Color(0xFF2E6AFF),
//                    ),
//                  ),
//                ],
//              ),
//            ),
//          ),
          Column(
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      onTap: () async {
                        setState(() {
                          routePushed = true;
                        });
                        var result = await ProfileHelpers()
                            .navigationProfileHelper(
                            context, question.answers[0].userAnswered.id);
                        setState(() {
                          routePushed = false;
                        });
                      },
                      contentPadding: EdgeInsets.only(left: 0),
                      leading: CircleAvatar(
                          radius: 16,
                          backgroundImage: question.answers[0].userAnswered
                              .avatarImageProvider()),
                      title: RichText(
                        text: TextSpan(
                          style:
                          TextStyle(fontSize: 14, color: Colors.grey[700]),
                          children: <TextSpan>[
                            TextSpan(
                              text:
                              "${question.answers[0].userAnswered.getFullName()}",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                                color: Color(0xFF282829),
                              ),
                            ),
                            /*TextSpan(
                              text: " • ${_timeAgoText(question)}",
                            )*/
                          ],
                        ),
                      ),
                      subtitle: Text(
                        _jobText(question, isAsker: true),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  question.answers[0].userAnswered.id != _userLogged.id
                      ? IconButton(
                    onPressed: () {
//                      iFollow
//                          ? _unFollow(question.answers[0].userAnswered)
//                          : _follow(question.answers[0].userAnswered);
                    print("click here");
                    },
                    icon: Icon(
                      Icons.group_add,
                      size: 25.0,
                      color: iFollow ? Colors.blue : Colors.grey[900],
                    ),
                  )
                      : SizedBox.shrink(),

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
                                          showMaterialModalBottomSheet(
                                            context: context,
                                            builder: (context) => Container(
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height /
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
                                                            color: Color(
                                                                0xFF939598),
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
                                                        _showReportSendSucessfullyDialog();
                                                      },
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
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
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
                                                      child: Center(
                                                          child: Text('Spam',
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
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
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
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
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
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
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
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
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
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
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
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
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
                                                      color: Colors.grey,
                                                      height: 1,
                                                    ),
                                                    FlatButton(
                                                      onPressed: () {
                                                        _showReportSendSucessfullyDialog();
                                                      },
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
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
                  // Container(
                  //   alignment: Alignment.topCenter,
                  //   child: Icon(
                  //     Icons.close,
                  //     color: Colors.grey[900],
                  //   ),
                  // )
                ],
              ),
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              routePushed = true;
                            });
                            print("line 308");
                            await Navigator.push(context,
                                MaterialPageRoute(builder:
                                    (BuildContext context) {
                                  return QuestionInterestDetailsWidget(
                                      question: question);
                                }));
                            setState(() {
                              routePushed = false;
                            });
                            },
                        child: RichText(
                          text: TextSpan(
                            text: question.text + '? ',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                  "\n\n${question.answers.length} ${StringHelper.puralize("Answer", question.answers.length)} ",
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: <TextSpan> [
                                    TextSpan(
                                      text: " • Last answered ${ _timeAgoText(question)}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black26),
                                    ),
                                  ]
                              ),
                            ],
                          ),
                        ),),
                      /*Text((question.text) + '? ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)
                      ),*/
                    ),

                ],

                /*
                  RichText(
                      text:
                        TextSpan(
                          text: StringUtils.capitalize(
                                    question.text) + '? ',
                                    style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                          "${question.answers.length} ${StringHelper.puralize("Answer", question.answers.length)}",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  )*/
              ),
            ],
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

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
                  play: routePushed ? false : isInView,
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
          ]),
        ),
        SizedBox(height: 10.0),
        Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 0),
            child: SizedBox()),
        _actionsOnItem(
            question,
            question.answers[0].likes.toString(),
            question.answers[0].comments != null
                ? question.answers[0].comments.length.toString()
                : '0',
            question.shares.toString()),
        SizedBox(height: 5.0),
      ];
    } else {
      return [SizedBox.shrink()];
    }
  }

  _actionsOnItem(QuestionData question, String likeCount, String commentCount,
      String shareCount) {
    return Container(
      //padding: EdgeInsets.only(top: 0, right: 20, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _individualItem(FlutterIcons.thumbs_up_fea, "${likeCount} Like",
              answerId: question.answers[0].id,
              f: _like,
              question: question,
              userAffected: question.answers[0].userLike),
          _individualItem(
            FontAwesomeIcons.comment,
            '${commentCount} Comment',
            question: question,
            answerId: question.answers[0].id,
            f: _comments,
          ),
          _individualItem(
            FlutterIcons.send_fea,
            '${shareCount} Share',
            question: question,
            answerId: question.answers[0].id,
            type: question.interest != null ? "interest" : "follow",
            f: _share,
          ),
        ],
      ),
    );
  }

  _individualItem(IconData icon, String number,
      {String answerId,
        Function f,
        bool userAffected = false,
        QuestionData question,
        String type}) {
    Color iconColor = Colors.grey[700];
    if (userAffected) {
      iconColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        f(question);
      },
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: iconColor,
            size: 22.0,
          ),
          Container(
            width: 10,
          ),
          Text(
            number,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          )
        ],
      ),
    );
  }

  _share(QuestionData question) async {
    var link = await DynamicLinkProvider.generateDynamicLink(
        "question",
        Map<String, dynamic>.from(
          {"qid": question.id, "type": "interest"},
        ),question);
    final ShortDynamicLink shortenedLink =
    await DynamicLinkParameters.shortenUrl(Uri.parse(link.toString()));

    final Uri shortUrl = shortenedLink.shortUrl;

    await Share.share(shortUrl.toString());
    if (!question.userShare) {
      Response response =
      await FeedApiService().share(_userLogged.id, question.id);
      if (response.statusCode == 200) {
        setState(() {
          question.userShare = true;
          question.shares = question.shares + 1;
          _userLogged.questionsShared.add(question);
          Provider.of<UserProvider>(context, listen: false).updateProvider();
        });
      }
    }
  }

  _like(QuestionData question) async {
    Response response;
    Answer answer = question.answers[0];
    if (answer.userLike) {
      response = await QuestionApiService().dislike(_userLogged.id, answer.id);
    } else {
      response = await QuestionApiService().like(_userLogged.id, answer.id);
    }
    if (response.statusCode == 200) {
      setState(() {
        if (!question.answers[0].userLike) {
          question.answers[0].likes = question.answers[0].likes + 1;
          question.answers[0].userLike = true;
        } else {
          question.answers[0].likes = question.answers[0].likes - 1;
          question.answers[0].userLike = false;
        }
      });
    }
  }

  _comments(QuestionData question) async {
    setState(() {
      routePushed = true;
    });
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
          return CommentsWidget(
            answerId: question.answers[0].id,
          );
        }));
    setState(() {
      routePushed = false;
    });
  }

  String _timeAgoText(dynamic obj, {bool isAsker = true}) {
    String time = '';
    if (isAsker) {
      time = time =
          timeago.format(DateTime.fromMillisecondsSinceEpoch(obj.createdAt));
      print("abc" + time);
    }

    return time;
  }

  _followButton() {
//    isFollow = _getFollowInformation(widget.interest.id);
    if (!iFollow) {
      return InkWell(
        child: SizedBox(
            height: 30,
            child: Icon(FlutterIcons.rss_fea,
                color: Colors.grey[
                400]) //Text("Following",style: TextStyle(color: Colors.grey[400],fontSize: 15),)
        ),
        onTap: () async {
          await ProfileHelpers().followInterest(context, widget.interest.id);
          setState(() {
            // isFollow = !isFollow;
          });
        },
      );
    } else {
      return InkWell(
        onTap: () async {
          await ProfileHelpers().unFollowInterest(context, widget.interest.id);
          setState(() {});
        },
        child: SizedBox(
            height: 30,
            child: Icon(FlutterIcons.rss_fea,
                color: Colors.blue[
                400]) //Text("Follow",style: TextStyle(color: Colors.red[400],fontSize: 15),)//Icon(FlutterIcons.user_unfollow_sli)
        ),
      );
    }
  }
}
