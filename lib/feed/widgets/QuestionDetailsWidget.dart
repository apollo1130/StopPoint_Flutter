import 'package:auto_size_text/auto_size_text.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/DynamicLinkProvider.dart';
import 'package:video_app/core/widgets/VideoWidget.dart';
import 'package:video_app/feed/api/FeedApiService.dart';
import 'package:video_app/feed/widgets/CommentsWidget.dart';
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/StringHelper.dart';
import 'package:video_app/questions/Widgets/CameraWidget.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/ask/AudienceSelect.dart';
import 'package:video_app/questions/models/Answer.dart';
import 'package:video_app/questions/models/QuestionData.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/profile/utils/ProfileHelpers.dart';

class QuestionDetailsWidget extends StatefulWidget {
  final QuestionData question;
  final bool needFetch;

  QuestionDetailsWidget({this.question, this.needFetch});

  @override
  _QuestionDetailsWidgetState createState() => _QuestionDetailsWidgetState();
}

class _QuestionDetailsWidgetState extends State<QuestionDetailsWidget> {
  double headerHeight;
  User _userLogged;
  QuestionData question;
  bool iFollow;
  bool dataLoaded = false;
  bool routePushed = false;

  @override
  Widget build(BuildContext context) {
    headerHeight = MediaQuery.of(context).size.height * 0.38;
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    return FutureBuilder<bool>(
      future: _getQuestionFromDatabase(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.hasData && snapshot.data) {
          bool askerFollow =question?.userAsked?.id!=null?_getFollowInformation(question.userAsked.id):false;
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Color(0xffFAFAFA),
              elevation: 1.0,
              leading: Transform.translate(
                offset: Offset(-8, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context,true);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              ),
              title: _askerInfoAppbar(question),
              actions: [
                _userLogged.id != question.userAsked.id
                    ? IconButton(
                  onPressed: () {
                    askerFollow
                        ? _unFollow(question.userAsked)
                        : _follow(question.userAsked);
                  },
                  icon: Icon(
                    Icons.group_add,
                    size: 25.0,
                    color: askerFollow ? Colors.blue : Colors.grey[900],
                  ),
                )
                    : SizedBox()
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Material(
                    elevation: 1,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: Color(0xffFAFAFA)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(bottom: 20),
                            height: MediaQuery.of(context).size.height - 80.0,
                            child: InViewNotifierList(
                              padding: EdgeInsets.only(top: 20),
                              isInViewPortCondition: (double deltaTop,
                                  double deltaBottom,
                                  double viewPortDimension) {
                                return deltaTop < (0.5 * viewPortDimension) &&
                                    deltaBottom > (0.5 * viewPortDimension);
                              },
                              itemCount: 1,
                              builder: (BuildContext context, int index) {
                                return _questionItem(question, index);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

      // else {
      //     return Center(
      //       child: Text('Unknown Error'),
      //     );
      //   }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _questionItem(QuestionData question, int index) {
    print('inside question');
    return question.answer == null && question.answers.isEmpty
        ? _unansweredQuestion()
        : Container(
      padding: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.grey[300], width: 8))),
      child: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 0),
                        width: double.infinity,
                        child: Text(
                            question.text + '?',
                          style: TextStyle(
                            fontSize: 14.0,
                            height: 2,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF282829),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 0.0,
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                color: Colors.grey[300],
                width: double.infinity,
                height: 1,
              ),
              // Container(
              //   padding: EdgeInsets.only(left: 10, right: 0, top: 0),
              //   //padding: EdgeInsets.symmetric(horizontal: 0.0,),
              //   child: _receiverInfo(question),
              // ),
              Container(
                height: 5,
              ),
            ],
          ),
          ..._answerDepends(question, index),
        ],
      ),
    );
  }

  _askerInfo(QuestionData question) {
    if (question.userAsked == null ) {
      return Transform.translate(
          offset: Offset(-8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: ListTile(
                  onTap: () async {
                    await ProfileHelpers().navigationProfileHelper(
                        context, question.userAsked.id);
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
                        ),
                        /*TextSpan(
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
                ),
              ),
              _userLogged.id != question.userAsked.id
                  ? IconButton(
                onPressed: () {
                  iFollow
                      ? _unFollow(question.userAsked)
                      : _follow(question.userAsked);
                },
                icon: Icon(
                  Icons.group_add,
                  size: 25.0,
                  color: iFollow ? Colors.blue : Colors.grey[900],
                ),
              )
                  : SizedBox()
            ],
          ));
    }
    // else {
    //   return Row(
    //     children: <Widget>[
    //       Expanded(
    //         child: ListTile(
    //           contentPadding: EdgeInsets.all(0),
    //           leading: CircleAvatar(
    //             backgroundColor: Colors.white,
    //             radius: 16,
    //             child: Text(
    //               question?.interest?.icon ?? "",
    //               style: TextStyle(fontSize: 14),
    //             ),
    //           ),
    //           title: Text(
    //               'Question asked for ' + (question?.interest?.label ?? "")),
    //           subtitle: Text(timeago.format(
    //               DateTime.fromMillisecondsSinceEpoch(question.createdAt))),
    //         ),
    //       ),
    //       Container(
    //         alignment: Alignment.topCenter,
    //         child: Icon(
    //           Icons.group_add,
    //           color: Colors.grey[900],
    //         ),
    //       )
    //     ],
    //   );
    // }
  }

  _askerInfoAppbar(QuestionData question) {
    return Transform.translate(
      offset: Offset(-30, 0),
      child: question.privacy == AudienceType.Public
          ? ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: CircleAvatar(
            radius: 16,
            backgroundImage: question.userAsked.avatarImageProvider()),
        title: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            children: <TextSpan>[
              TextSpan(
                text: "${question.userAsked.getFullName()}",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0,
                  color: Color(0xFF282829),
                ),
              ),
              TextSpan(
                text: " • ${_timeAgoText(question, isAsker: true)}",
                style: TextStyle(
                  fontSize: 10.0,
                ),
              )
            ],
          ),
        ),
        subtitle: Text(
          _jobText(question, isAsker: true),
          style: TextStyle(fontSize: 11),
        ),
      )
          : ListTile(
        onTap: () async {
          await ProfileHelpers()
              .navigationProfileHelper(context, question.userAsked.id);
        },
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
              )
            ],
          ),
        ),
      ),
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

  _receiverInfo(QuestionData question) {
    if (question?.answer?.userAnswered != null) {
      bool iFollow = _getFollowInformation(question.answer.userAnswered.id);
      return Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
                onTap: () async {
                  await ProfileHelpers().navigationProfileHelper(
                      context, question.answer.userAnswered.id);
                },
                contentPadding: EdgeInsets.all(0),
                leading: CircleAvatar(
                    radius: 16,
                    backgroundImage:
                    question.answer.userAnswered.avatarImageProvider()),
                title: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: question.answer != null
                          ? question.answer.userAnswered.getFullName()
                          : 'Asked to ' +
                          question.answer.userAnswered.getFullName(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF282829),
                      ),
                    ),
                    TextSpan(
                      text:
                      "• ${timeago.format(DateTime.fromMillisecondsSinceEpoch(question.answer.createdAt))}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF636466),
                      ),
                    )
                  ]),
                ),
                subtitle: Text(
                  _jobText(question),
                  style: TextStyle(fontSize: 12),
                )),
          ),
          question.answer.userAnswered.id != _userLogged.id
              ? IconButton(
            onPressed: () {
              iFollow
                  ? _unFollow(question.answer.userAnswered)
                  : _follow(question.answer.userAnswered);
            },
            icon: Icon(
              Icons.group_add,
              size: 25.0,
              color: iFollow ? Colors.blue : Colors.grey[900],
            ),
          )
              : SizedBox.shrink()
          // Container(
          //   alignment: Alignment.topCenter,
          //   child: Icon(
          //     Icons.close,
          //     color: Colors.grey[900],
          //   ),
          // )
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Text(
                  question?.interest?.icon ?? "",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              title: Text(
                  'Question asked for ' + (question?.interest?.label ?? "")),
              subtitle: Text(timeago.format(
                  DateTime.fromMillisecondsSinceEpoch(question.createdAt))),
            ),
          ),
          // Container(
          //   alignment: Alignment.topCenter,
          //   child: Icon(
          //     Icons.close,
          //     color: Colors.grey[900],
          //   ),
          // )
        ],
      );
    }
  }

  _unansweredQuestion() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: _askerInfo(question),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(height: 15.0),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    width: double.infinity,
                    child: Text(
                        question.text + '?',
                      style: TextStyle(
                        fontSize: 14.0,
                        height: 1.57,
                        fontWeight: FontWeight.bold,
                        color: Color(
                          0xFF282829,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          ProfileHelpers()
              .isLoggedInAsker(question.userAsked.id, _userLogged.id)
              ? SizedBox()
              : GestureDetector(
            onTap: () {
              setState(() {
                routePushed = true;
              });
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return CameraWidget(question: question);
                  }));
              setState(() {
                routePushed = false;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(width: 1.0),
                  Icon(
                    FlutterIcons.video_fea,
                    color: Color(0xFF2E6AFF),
                  ),
                  SizedBox(width: 7.0),
                  Text(
                    "Answer",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF636466),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Divider(),
          ),
          Icon(
            FlutterIcons.pencil_sli,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              "No Answers Yet",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider()
        ],
      ),
    );
  }

  // _answerDepends(QuestionData question, int index) {
  //   return [
  //     Container(
  //       height: MediaQuery.of(context).size.height / 1.6,
  //       child: Stack(
  //           children: [InViewNotifierWidget(
  //             id: '$index',
  //             builder: (BuildContext context, bool isInView, Widget child) {
  //               return VideoWidget(
  //                 play:isInView,
  //                 url: question.answers[0].video,
  //                 question: question,
  //               );
  //             },
  //           ),
  //             Positioned(
  //               top: 20,
  //               right: 10,
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.remove_red_eye,color: Colors.white,),
  //                   SizedBox(width: 5,),
  //                   Text(
  //                     "${question.answers[index].views ?? '0'} ${StringHelper.puralize("View", question.answers[index].views ?? '0')}",
  //                     style: TextStyle(
  //                       //color: Color(0xFF636466),
  //                         color: Colors.white
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ]),
  //     ),
  //     SizedBox(height: 0.0),
  //     Padding(
  //       padding: EdgeInsets.only(left: 20, right: 0, top: 10),
  //       child: SizedBox(),
  //     ),
  //     _actionsOnItem(question,index),
  //   ];
  // }

  _answerUserInfo(Answer answer) {
    bool iFollow = _getFollowInformation(answer.userAnswered.id);

    return Row(
      children: <Widget>[
        Expanded(
          child: ListTile(
            onTap: () async {
              await ProfileHelpers()
                  .navigationProfileHelper(context, answer.userAnswered.id);
            },
            contentPadding: EdgeInsets.all(0),
            leading: CircleAvatar(
              radius: 16,
              backgroundImage: answer.userAnswered.avatarImageProvider(),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: answer.userAnswered.getFullName(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282829),
                    ),
                  ),
                  TextSpan(
                    text: " • ",
                    style: TextStyle(
                      color: Color(0xFF636466),
                    ),
                  ),
                  TextSpan(
                    text:
                    "${timeago.format(DateTime.fromMillisecondsSinceEpoch(answer.createdAt))}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF636466),
                    ),
                  )
                ],
              ),
            ),
            subtitle: Text(
              _jobText(question),
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
        answer.userAnswered.id != _userLogged.id
            ? IconButton(
          onPressed: () {
            iFollow
                ? _unFollow(answer.userAnswered)
                : _follow(answer.userAnswered);
          },
          icon: Icon(
            Icons.group_add,
            size: 25.0,
            color: iFollow ? Colors.blue : Colors.grey[900],
          ),
        )
            : SizedBox.shrink()
        // Container(
        //   alignment: Alignment.topCenter,
        //   child: Icon(
        //     Icons.close,
        //     color: Colors.grey[900],
        //   ),
        // )
      ],
    );
  }

  _answerDepends(QuestionData question, int index) {
    if (question.answers.length > 0) {

      print(question.text);
      print("question.text");
      return [
        Container(
          padding: EdgeInsets.only(left: 10, right: 0, top: 0),
          child: _answerUserInfo(question.answers[index]),
        ),
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
                    "${2} ${StringHelper.puralize("View", 2)}",
                    style: TextStyle(
                      //color: Color(0xFF636466),
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ]),
        ),
        SizedBox(height: 0.0),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 0, top: 0, bottom: 10),
          child: SizedBox(),
        ),
        _actionsOnItem(question, index),
      ];
    } else {
      print(question.text);
      print("question.text");

      return [Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: _askerInfo(question),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10.0,
                      ),
                      width: double.infinity,
                      child: Text(question.text + '?',
                        style: TextStyle(
                          fontSize: 14.0,
                          height: 1.57,
                          fontWeight: FontWeight.bold,
                          color: Color(
                            0xFF282829,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            ProfileHelpers()
                .isLoggedInAsker(question.userAsked.id, _userLogged.id)
                ? SizedBox()
                : GestureDetector(
              onTap: () {
                setState(() {
                  routePushed = true;
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return CameraWidget(question: question);
                    }));
                setState(() {
                  routePushed = false;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(width: 1.0),
                    Icon(
                      FlutterIcons.video_fea,
                      color: Color(0xFF2E6AFF),
                    ),
                    SizedBox(width: 7.0),
                    Text(
                      "Answer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF636466),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
              ),
              child: Divider(),
            ),
            Icon(
              FlutterIcons.pencil_sli,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              "No answers yet",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      )];
    }
  }

  // TODO: Actions of video
  /// used when to like comment and share
  _actionsOnItem(QuestionData question, int index) {
    return Container(
      //padding: EdgeInsets.only(top: 0, right: 20, left: 20, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _individualItem(FlutterIcons.thumbs_up_fea,
              "${question.answers[index].likes} Like",
              answerId: question.answers[index].id,
              f: _like,
              userAffected: question.answers[index].userLike),
          _individualItem(
            FontAwesomeIcons.comment,
            '0 Comment',
            answerId: question.answers[index].id,
            f: _comments,
          ),
//          VerticalDivider(
//            width: 40,
//          ),
          _individualItem(
            FlutterIcons.send_fea,
            '${question.shares} Share',
            questionId: question.id,
            answerId: question.answers[index].id,
            type: question.interest != null ? "interest" : "follow",
            f: _share,
          ),
        ],
      ),
    );
  }

  // TODO: Items
  /// using to make icons on the bottom of the video
  _individualItem(IconData icon, String number,
      {String answerId,
        Function f,
        bool userAffected = false,
        String questionId,
        String type}) {
    Color iconColor = Colors.grey[700];

    if (userAffected && icon == FlutterIcons.thumbs_up_fea) {
      iconColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        f(answerId, questionId: questionId, type: type);
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

  // TODO: Share Button
  _share(String answerId, {String questionId, String type, QuestionData questionData}) async {
    var link = await DynamicLinkProvider.generateDynamicLink(
        "question",
        Map<String, dynamic>.from(
          {"qid": questionId, "type": type},
        ),question);
    final ShortDynamicLink shortenedLink =
    await DynamicLinkParameters.shortenUrl(Uri.parse(link.toString()));

    final Uri shortUrl = shortenedLink.shortUrl;

    await Share.share(shortUrl.toString());
    if (!question.userShare) {
      Response response =
      await FeedApiService().share(_userLogged.id, questionId);
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

  // TODO: Like Button
  _like(String answerId,
      {String questionId, String type, QuestionData questionData}) async {
    Response response;
    int answerIndex =
    question.answers.indexWhere((element) => element.id == answerId);
    if (question.answers[answerIndex].userLike) {
      response = await QuestionApiService().dislike(_userLogged.id, answerId);
    } else {
      response = await QuestionApiService().like(_userLogged.id, answerId);
    }
    if (response.statusCode == 200) {
      if (question.answers[answerIndex].id == answerId) {
        setState(() {
          if (!question.answers[answerIndex].userLike) {
            question.answers[answerIndex].likes =
                question.answers[answerIndex].likes + 1;
            question.answers[answerIndex].userLike = true;
          } else {
            question.answers[answerIndex].likes =
                question.answers[answerIndex].likes - 1;
            question.answers[answerIndex].userLike = false;
          }
        });
      }
    }
  }

  // TODO: Comment Button
  _comments(String answerId, {String questionId, String type}) async {
    var result = Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
          return CommentsWidget(
            answerId: answerId,
          );
        }));
  }

  //TODO: Job Text
  _jobText(QuestionData question, {bool isAsker = false}) {
    // print(question.answer.userAnswered.job);
    String job;
    if (isAsker) {
      job = StringUtils.defaultString(question.userAsked.job);
    } else {
      if (question.answer != null) {
        job = StringUtils.defaultString(question.answer.userAnswered.job);
      } else {
        job = StringUtils.defaultString(question.answers[0].userAnswered.job);
      }
    }

    return job ?? "";
  }

  // TODO: Follow Information
  _getFollowInformation(String userId) {
    bool result = false;
    _userLogged.following.forEach((element) {
      if (element.id == userId) {
        result = true;
      }
    });
    return result;
  }

  // TODO: Follow User
  _follow(User _user) async {
    Response response =
    await ProfileApiService().follow(_userLogged.id, _user.id);

    if (response.statusCode == 200) {
      if (_userLogged.following == null) {
        _userLogged.following = [User.fromJson(response.data)];
      } else {
        _userLogged.following.add(User.fromJson(response.data));
      }
      if (_user.followers == null) {
        _user.followers = [_userLogged];
      } else {
        _user.followers.add(_userLogged);
      }
      setState(() {});
    } else if (response.statusCode == 209) {
      Fluttertoast.showToast(
          msg: 'Request Sent',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: 'Error following the user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  // TODO: Unfollow user
  _unFollow(_user) async {
    Response response =
    await ProfileApiService().unfollow(_userLogged.id, _user.id);
    if (response.statusCode == 200) {
      int index =
      _userLogged.following.indexWhere((element) => element.id == _user.id);
      _userLogged.following.removeAt(index);

      int indexLogged =
      _user.followers.indexWhere((element) => element.id == _userLogged.id);
      _user.followers.removeAt(indexLogged);
      setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: 'Error stopping following the user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  // TODO: Get Question data from server
  Future<bool> _getQuestionFromDatabase() async {
    Future<bool> res;
    if (widget.needFetch) {
      if (!dataLoaded) {
        Response response = await QuestionApiService()
            .getQuestionById(widget.question.id, _userLogged.id);
        if (response.statusCode == 200) {
            question = new QuestionData();
            question = QuestionData.fromJson(response.data);
            dataLoaded = true;
          res=Future.value(true);
        } else {
          res=Future.value(false);
          Fluttertoast.showToast(
              msg: 'Error getting the question',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } else {
      question = widget.question;
      dataLoaded=true;
      res=Future.value(true);
    }
    return res??false;
  }
}
