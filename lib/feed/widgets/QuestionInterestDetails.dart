import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:video_app/auth/api/AuthApiService.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/DynamicLinkProvider.dart';
import 'package:video_app/core/providers/permision_provider.dart';
import 'package:video_app/core/utils/JwtHelper.dart';
import 'package:video_app/core/widgets/VideoWidget.dart';
import 'package:video_app/feed/api/FeedApiService.dart';
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

import 'CommentsWidget.dart';

class QuestionInterestDetailsWidget extends StatefulWidget {
  final QuestionData question;
  final bool needFetch;
  QuestionInterestDetailsWidget({this.question, this.needFetch});
  @override
  _QuestionInterestDetailsWidgetState createState() =>
      _QuestionInterestDetailsWidgetState();
}

class _QuestionInterestDetailsWidgetState
    extends State<QuestionInterestDetailsWidget> {
  double headerHeight;
  User _userLogged;
  bool routePushed = false;
  QuestionData question = new QuestionData() ;
  bool dataLoaded = false;
  bool iFollow;

  @override
  Widget build(BuildContext context) {
    final _blocPermission = Provider.of<PermisionProvider>(context);
    headerHeight = MediaQuery.of(context).size.height * 0.38;
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    return FutureBuilder<bool>(
      future: _getQuestionFromDatabase(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // if(dataLoaded){
        //   return Scaffold(
        //       appBar:AppBar(),
        //       body: Center(
        //           child:Text(" 1234"+_userLogged?.id??" NA "+" 1234"+snapshot.data.toString())
        //       )
        //   );
        // }
        // return Scaffold(
        //   appBar:AppBar(),
        //   body: Center(
        //     child:Text(" laoding "+ _userLogged?.id??"NA "+" 22 "+widget.question.id)
        //   )
        // );
        if (dataLoaded) {
          bool askerFollow = _getFollowInformation(question.userAsked.id);
          return Scaffold(
            backgroundColor: Colors.white,
            appBar:AppBar(
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
                      color: Color(0xffFAFAFA),
                      //decoration: BoxDecoration(color: Color(0xffFAFAFA)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          question.answers.length == 0
                              ? Container(
                            child: Column(
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: <Widget>[
                                      SizedBox(height: 10.0),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                            vertical: 10.0,
                                          ),
                                          width: double.infinity,
                                          child: Text(
                                                question.text +
                                                '?',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              height: 1.57,
                                              fontWeight:
                                              FontWeight.bold,
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
                                  height: 0.0,
                                ),
                                ProfileHelpers().isLoggedInAsker(
                                    question.userAsked.id,
                                    _userLogged.id)
                                    ? SizedBox()
                                    : GestureDetector(
                                  onTap: () async{
                                    await _blocPermission.getCameraPermission(context,question);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      children: [
                                        SizedBox(width: 1.0),
                                        Icon(
                                            FlutterIcons.video_fea,
                                            color: Color(0xFF2E6AFF),
                                            size: 16
                                        ),
                                        SizedBox(width: 7.0),
                                        Text(
                                          "Answer",
                                          style: TextStyle(
                                            //fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E6AFF),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 60.0,
                                  ),
                                  //child: Divider(),
                                ),
                                Icon(
                                  FlutterIcons.pencil_sli,
                                ),
                                SizedBox(
                                  height: 0.0,
                                ),
                                Text(
                                  "No answers yet",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          )
                              : Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 10.0,
                            ),
                            height: MediaQuery.of(context).size.height - 100,
                            child: InViewNotifierList(
                              padding: EdgeInsets.only(top: 0),
                              isInViewPortCondition: (double deltaTop,
                                  double deltaBottom,
                                  double viewPortDimension) {
                                return deltaTop <
                                    (0.5 * viewPortDimension) &&
                                    deltaBottom >
                                        (0.5 * viewPortDimension);
                              },
                              itemCount: question.answers.length,
                              builder:
                                  (BuildContext context, int index) {
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
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
        // else {
        //   return Center(
        //     child: Text('Unknown Error'),
        //   );
        // }
      },
    );
  }


  @override
  void dispose() {
    print('hello');
    super.dispose();
  }

  _questionItem(QuestionData question, int index) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Color(0xffFAFAFA),
          border:
          Border(bottom: BorderSide(color: Colors.grey[300], width: 8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          index > 0
              ? SizedBox()
              : Column(
            children: [
              Container(
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // SizedBox(height: 15.0),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.0,
//                                vertical: 10.0,
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
//                          Padding(
//                            padding: const EdgeInsets.only(right:25),
//                            child: Row(
//                              crossAxisAlignment: CrossAxisAlignment.end,
//                              children: [
//                                Icon(FlutterIcons.video_fea,
//                                    color:
//                                    Color(0xFF2E6AFF),size: 18),
//                                SizedBox(width: 5,),
//                                Text('1 Answer')
//                              ],
//                            ),
//                          )

                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              ProfileHelpers().isLoggedInAsker(
                  question.userAsked.id, _userLogged.id)
                  ? SizedBox()
                  : GestureDetector(
                onTap: () {
                  setState(() {
                    routePushed = true;
                  });
                  Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context) {
                        return CameraWidget(question: question);
                      }));

                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  alignment: Alignment.centerLeft,
                  child: Column(

                    children: [
                      SizedBox(width: 1.0),
                      Icon(
                          FlutterIcons.video_fea,
                          color: Color(0xFF2E6AFF),
                          size: 16
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        "Answer",
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          color: Color(0xFF2E6AFF),
                        ),
                      )
                    ],
                  ),
                ),
              ),
//                    SizedBox(
//                      height: 0.0,
//                    ),
//                    Divider(
//                      height: 10.0,
//                    ),
              Container(
                margin: EdgeInsets.only(top: 10),
                color: Colors.grey[300],
                width: double.infinity,
                height: 1,
              ),
              question.answers.length == 0
                  ? SizedBox()
                  : Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(
                      vertical: 10.0,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "${question.answers.length} ${StringHelper.puralize("Answer", question.answers.length)}",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xFF282829),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 0),
                    color: Colors.grey[300],
                    width: double.infinity,
                    height: 1,
                  ),
//                              Divider(
//                                height: 10.0,
//                              ),

                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 0, right: 0, top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 0,
                ),
              ],
            ),
          ),
          ..._answerDepends(question, index),
          //Divider()
        ],
      ),
    );
  }

  _askerInfo(QuestionData question) {

    bool iFollow = _getFollowInformation(question.userAsked.id);
    if (question.userAsked != null) {
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
                  backgroundImage: question.userAsked.avatarImageProvider()),
              title: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  children: <TextSpan>[
                    TextSpan(
                      text: question.userAsked.getFullName(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF282829),
                      ),
                    ),
                    /*TextSpan(
                      text:
                      "• ${timeago.format(DateTime.fromMillisecondsSinceEpoch(question.createdAt))}",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )*/
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _jobTextQuestioner(question),
                    style: TextStyle(fontSize: 12),
                  ),
                ],
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
                  question.interest.icon,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              title: Text('Question asked for ' + question.interest.label),
              /*subtitle: Text(timeago.format(
                  DateTime.fromMillisecondsSinceEpoch(question.createdAt))),*/
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

  _askerInfoAppbar (QuestionData question) {
    print(question.privacy);
    return Transform.translate(
        offset: Offset(-30,0),
        child: question.privacy == AudienceType.Public ?
        ListTile(
          onTap: () async {
            await ProfileHelpers().navigationProfileHelper(
                context, question.userAsked.id);
          },
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatar(
              radius: 16,
              backgroundImage: question.userAsked.avatarImageProvider()),
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              children: <TextSpan>[
                TextSpan(
                  text: question.userAsked.getFullName(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF282829),
                  ),
                ),
                /*TextSpan(
                  text:
                  "• ${timeago.format(DateTime.fromMillisecondsSinceEpoch(question.createdAt))}",
                  style: TextStyle(
                    fontSize: 10,
                  ),
                )*/
              ],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _jobTextQuestioner(question),
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ):
        ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('lib/assets/images/defaultUser.png')
          ),
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              children: <TextSpan>[
                TextSpan(
                  text: 'Anonymous',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF282829),
                  ),
                ),
                TextSpan(
                  text:
                  "• ${timeago.format(DateTime.fromMillisecondsSinceEpoch(question.createdAt))}",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

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
              _jobText(answer),
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

  _jobText(Answer answer) {
    return answer.userAnswered.job ?? "";
  }

  String _jobTextQuestioner(QuestionData question) {
    return question.userAsked.job ?? "";
  }

  _answerDepends(QuestionData question, int index) {
    if (question.answers.length > 0) {
      return [
        Container(
          padding: EdgeInsets.only(left: 10, right: 0, top: 0),
          child: _answerUserInfo(question.answers[index]),
        ),
        Container(
          height: MediaQuery.of(context).size.height / 1.6,
          child: Stack(
              children:[ InViewNotifierWidget(
                id: '$index',
                builder: (BuildContext context, bool isInView, Widget child) {
                  return VideoWidget(
                    play: routePushed ? false : isInView,
                    url: question.answers[index].video,
                    question: question,
                    index: index,
                  );
                },
              ),
                Positioned(
                  top: 20,
                  right: 10,
                  child: Row(
                    children: [
                      Icon(Icons.remove_red_eye,color: Colors.white,),
                      SizedBox(width: 5,),
                      Text(
                        "${2} ${StringHelper.puralize("View", 2)}",
                        style: TextStyle(
                          //color: Color(0xFF636466),
                            color: Colors.white
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
        SizedBox(height: 0.0),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 0, top: 0, bottom:10),
          child: SizedBox(),
        ),
        _actionsOnItem(question, index),
      ];
    } else {
      return [
        Container(
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
        )
      ];
    }
  }

  _actionsOnItem(QuestionData question, int index) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _individualItem(FlutterIcons.thumbs_up_fea, "${question.answers[index].likes} Like",
              answerId: question.answers[index].id,
              f: _like,
              questionData: question,
              index: index,
              userAffected: question.answers[index].userLike),
//          VerticalDivider(
//            width: 0,
//          ),
          _individualItem(FontAwesomeIcons.comment, "${question.answers[index].comments== null ? 0: question.answers[index].comments== null }  Comment",
              questionData: question,
              answerId: question.answers[index].id,
              f: _comments,
              index: index),
//          VerticalDivider(
//            width: 0,
//          ),
          _individualItem(
            FlutterIcons.send_fea,
            "${question.shares} Share",
            questionData: question,
            questionId: question.id,
            answerId: question.answers[index].id,
            type: "interest",
            index: index,
            f: _share,
          ),
        ],
      ),
    );
//    return Container(
//      child: Row(
//        children: <Widget>[
//          Expanded(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: <Widget>[
//                _individualItem(FlutterIcons.thumbs_up_fea, "${likeCount} Like",
//                    answerId: question.answers[index].id,
//                    f: _upVote,
//                    questionData: question,
//                    userAffected: question.answers[index].userUpVote),
//                VerticalDivider(
//                  width: 20,
//                ),
//                _individualItem(
//                  FontAwesomeIcons.comment,
//                  "${commentCount} Comment",
//                  questionData: question,
//                  answerId: question.answers[index].id,
//                  f: _comments,
//                ),
//                VerticalDivider(
//                  width:0,
//                ),
//                _individualItem(
//                  FlutterIcons.send_fea,
//                  "${shareCount} Share",
//                  questionData: question,
//                  questionId: question.id,
//                  answerId: question.answers[index].id,
//                  type: "interest",
//                  f: _share,
//                ),
//              ],
//            ),
//          ),
//        ],
//      ),
//    );
  }

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

  _unFollow(_user) async {
    print(_userLogged);
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

  _individualItem(
      IconData icon,
      String number, {
        String answerId,
        Function f,
        bool userAffected = false,
        String questionId,
        QuestionData questionData,
        String type,
        int index,
      }) {
    Color iconColor = Colors.grey[700];
    if (questionData != null && questionData.answers[index] != null) {
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
              index: index,
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
                  width: 8
              ),
              Text(
                number,
                style: TextStyle(
                  color: icon == FlutterIcons.thumbs_up_fea &&
                      questionData.answers[index].userUpVote != null &&
                      questionData.answers[index].userUpVote
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

  _share(
      String answerId, {
        String questionId,
        String type,
        QuestionData questionData,
        int index,
      }) async {
    var link = await DynamicLinkProvider.generateDynamicLink(
        "question",
        Map<String, dynamic>.from(
          {"qid": questionId, "type": type},
        ),questionData);
    final ShortDynamicLink shortenedLink =
    await DynamicLinkParameters.shortenUrl(Uri.parse(link.toString()));

    final Uri shortUrl = shortenedLink.shortUrl;

    await Share.share(shortUrl.toString());
    questionData.userShare =
    questionData.userShare == null ? false : questionData.userShare;
    if (!questionData.userShare) {
      Response response =
      await FeedApiService().share(_userLogged.id, questionId);
      if (response.statusCode == 200) {
        setState(() {
          questionData.userShare = true;
          questionData.shares = questionData.shares + 1;
          _userLogged.questionsShared.add(question);
          Provider.of<UserProvider>(context, listen: false).updateProvider();
        });
      }
    }
  }

  _like(String answerId, {String questionId, String type, QuestionData questionData, int index}) async {
    Response response;
    if (question.answers[index].userLike) {
      response = await QuestionApiService().dislike(_userLogged.id, answerId);
    } else {
      response = await QuestionApiService().like(_userLogged.id, answerId);
    }
    if (response.statusCode == 200) {
      if (question.answers[index].id == answerId) {
        setState(() {
          if (!question.answers[index].userLike) {
            question.answers[index].likes = question.answers[index].likes + 1;
            question.answers[index].userLike = true;
          } else {
            question.answers[index].likes = question.answers[index].likes - 1;
            question.answers[index].userLike = false;
          }
        });
      }
    }
  }

  _comments(
      String answerId, {
        String questionId,
        String type,
        QuestionData questionData,
        int index,
      }) async {
    var result = Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
          return CommentsWidget(
            answerId: answerId,
          );
        }));
  }

  _getFollowInformation(String interestId) {
    bool found = false;
    _userLogged.following.forEach((element) {
      if (element.id == interestId) {
        found = true;
      }
    });
    return found;
  }

  Future<bool> _getQuestionFromDatabase() async {
    Future<bool> res;
    if (!dataLoaded) {
      question = new QuestionData();
      Response response = await QuestionApiService().getQuestionById(widget.question.id, "f2bc244a-acd0-4d6a-9263-cf07309c4fd0");
      if (response.statusCode == 200) {
        setState(() {
          question = QuestionData.fromJson(response.data);
        });
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
      dataLoaded = true;
      res=Future.value(true);
    }
    return dataLoaded;
  }
}