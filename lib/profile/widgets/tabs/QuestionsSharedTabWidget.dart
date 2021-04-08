import 'package:basic_utils/basic_utils.dart';
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
import 'package:video_app/feed/widgets/QuestionDetailsWidget.dart';
import 'package:video_app/feed/widgets/QuestionInterestDetails.dart';
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:video_app/profile/utils/StringHelper.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class QuestionsSharedTabWidget extends StatefulWidget {
  final List<QuestionData> questions;

  QuestionsSharedTabWidget({this.questions});

  @override
  _QuestionsSharedTabWidgetState createState() =>
      _QuestionsSharedTabWidgetState();
}

class _QuestionsSharedTabWidgetState extends State<QuestionsSharedTabWidget> {
  List<Widget> listOfQuestionsWidgets = List<Widget>();
  bool loadedVideos = false;
  User _userLogged;
  bool routePushed = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context).userLogged;
    return InViewNotifierList(
      padding: EdgeInsets.all(0),
      isInViewPortCondition:
          (double deltaTop, double deltaBottom, double viewPortDimension) {
        print(deltaTop);
        print(deltaBottom);
        print(0.5 * viewPortDimension);
        return deltaTop < (0.5 * viewPortDimension + 150) &&
            deltaBottom > (0.5 * viewPortDimension + 150);
      },
      itemCount: widget.questions.length,
      builder: (BuildContext context, int index) {
        return _questionItem(widget.questions[index], index);
      },
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
                await ProfileHelpers()
                    .navigationProfileHelper(context, question.userAsked.id);
              },
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                  radius: 16,
                  backgroundImage: question.userAsked.avatarImageProvider()),
              title: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  children: <TextSpan>[
                    TextSpan(
                      text: "${question.userAsked.getFullName()}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
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
                  style: TextStyle(fontSize: 20),
                ),
              ),
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
          IconButton(
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

  _questionItem(QuestionData question, int index) {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.grey[300], width: 8))),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: <Widget>[
                _askerInfo(question),
                Container(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            if (question.interest != null) {
                              return QuestionInterestDetailsWidget(
                                question: question,
                              );
                            } else {
                              return QuestionDetailsWidget(
                                question: question,
                                needFetch: false,
                              );
                            }
                          }));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          width: double.infinity,
                          child: Text(
                            question.text + '?',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                    margin: EdgeInsets.only(top: 12),
                    color: Colors.transparent,
                    width: double.infinity,
                    height: 2),
                // _receiverInfo(question),
                Container(
                  height: 5,
                ),
              ],
            ),
          ),
          ..._answerDepends(question, index),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  "${question.answer.upVotes} ${StringHelper.puralize("Upvote", question.answer.upVotes)}",
                  style: TextStyle(
                    color: Color(0xFF636466),
                  ),
                ),
                Spacer(),
                Text(
                  "${question.answer.comments != null ? question.answer.comments.length : 0} ${StringHelper.puralize("Comment", question.answer.comments != null ? question.answer.comments.length : 0)}",
                  style: TextStyle(
                    color: Color(0xFF636466),
                  ),
                ),
                SizedBox(
                  width: 7.5,
                ),
                Text("•"),
                SizedBox(
                  width: 7.5,
                ),
                Text(
                  "${question.shares} ${StringHelper.puralize("Share", question.shares)}",
                  style: TextStyle(
                    color: Color(0xFF636466),
                  ),
                ),
                SizedBox(
                  width: 7.5,
                ),
                Text("•"),
                SizedBox(
                  width: 7.5,
                ),
                Text(
                  "${question.answer.views} ${StringHelper.puralize("View", question.answer.views)}",
                  style: TextStyle(
                    color: Color(0xFF636466),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 0),
            child: Divider(),
          ),
          _actionsOnItem(question),
        ],
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

  _jobText(QuestionData question, {bool isAsker = false}) {
    String job;
    if (isAsker) {
      job = StringUtils.defaultString(question.userAsked.job);
    } else {
      job = StringUtils.defaultString(question.answer.userAnswered.job);
    }

    return job ?? "";
  }

  _getFollowInformation(String userId) {
    bool result = false;
    _userLogged.following.forEach((element) {
      if (element.id == userId) {
        result = true;
      }
    });
    return result;
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
    // print(_userLogged);
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

  _answerDepends(QuestionData question, int index) {
    if (question.answer != null) {
      User user = question.answer.userAnswered;
      return [
        Container(
            height: MediaQuery.of(context).size.height / 1.6,
            child: InViewNotifierWidget(
              id: '$index',
              builder: (BuildContext context, bool isInView, Widget child) {
                return VideoWidget(
                  play: isInView,
                  url: question.answer.video,
                  question: question,
                );
              },
            )),
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
    if (questionData != null && questionData.answer != null) {
      if (icon == FlutterIcons.thumbs_up_fea &&
          questionData.answer.userUpVote != null &&
          questionData.answer.userUpVote) {
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
                width: 10,
              ),
              Text(
                number,
                style: TextStyle(
                  color: icon == FlutterIcons.thumbs_up_fea &&
                          questionData.answer.userUpVote != null &&
                          questionData.answer.userUpVote
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

  _actionsOnItem(QuestionData question) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _individualItem(FlutterIcons.thumbs_up_fea, "Upvote",
                    answerId: question.answer.id,
                    f: _upVote,
                    questionData: question,
                    userAffected: question.answer.userUpVote),
                VerticalDivider(
                  width: 20,
                ),
                _individualItem(
                  FontAwesomeIcons.comment,
                  "Comment",
                  questionData: question,
                  answerId: question.answer.id,
                  f: _comments,
                ),
                VerticalDivider(
                  width: 20,
                ),
                _individualItem(
                  FlutterIcons.send_fea,
                  "Share",
                  questionData: question,
                  questionId: question.id,
                  answerId: question.answer.id,
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

  _upVote(String answerId,
      {String questionId, String type, QuestionData questionData}) async {
    Response response;
    if (questionData.answer.userUpVote) {
      response = await FeedApiService().downVote(_userLogged.id, answerId);
    } else {
      response = await FeedApiService().upVote(_userLogged.id, answerId);
    }
    if (response.statusCode == 200) {
      setState(() {
        if (!questionData.answer.userUpVote) {
          questionData.answer.upVotes = questionData.answer.upVotes + 1;
          questionData.answer.userUpVote = true;
        } else {
          questionData.answer.upVotes = questionData.answer.upVotes - 1;
          questionData.answer.userUpVote = false;
        }
      });
    }
  }

  _comments(String answerId,
      {String questionId, String type, QuestionData questionData}) async {
    var result = Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return CommentsWidget(
        answerId: answerId,
      );
    }));
  }
}
