import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/DynamicLinkProvider.dart';
import 'package:video_app/core/providers/CoreProvider.dart';
import 'package:video_app/core/providers/permision_provider.dart';
import 'package:video_app/core/widgets/BottomNavigationMenu.dart';
import 'package:video_app/core/widgets/VideoWidget.dart';
import 'package:video_app/explore/widgets/InterestDetailsWidget.dart';
import 'package:video_app/feed/api/FeedApiService.dart';
import 'package:video_app/feed/widgets/CommentsWidget.dart';
import 'package:video_app/feed/widgets/QuestionDetailsWidget.dart';
import 'package:video_app/feed/widgets/QuestionInterestDetails.dart';
import 'package:video_app/feed/widgets/SuggestUserCard.dart';
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share/share.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:video_app/profile/utils/StringHelper.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeedWidget extends StatefulWidget {
  @override
  _FeedWidgetState createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  User _userLogged;
  List<QuestionData> _feedItems = List<QuestionData>();
  Future<List<QuestionData>> myFuture;
  bool loadingData = false;
  bool endOfData = false;
  List<User> _suggestedUsers = List<User>();
  bool initDataLoaded = false;
  bool refreshing = false;
  bool routePushed = false;
  bool clickedCentreFAB = false;
  int selectedIndex = 0;
  AnimationController _controller;
  int _bottomNavIndex = 0;

  List<IconData> icons = [
    Icons.person,
    Icons.person,
    Icons.person,
    Icons.person
  ];
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).accentColor;

    final _providerPermission = Provider.of<PermisionProvider>(context);
    initData();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffFAFAFA),
        elevation: 1.0,
        actions: [
          GestureDetector(
              onTap: () async {
                requestPermission(_providerPermission, context);
                //Share.share('https://stoppoint.page.link/
              },
              child: SvgPicture.asset(
                'lib/assets/images/invitefriend.svg',
                height: 40,
                width: 40,
              )),
          SizedBox(
            width: 10,
          ),
        ],
        title: Container(
          height: kToolbarHeight - 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.centerLeft,
              image: AssetImage(
                'lib/assets/images/logo_name.png',
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefreshFeedPage,
        child: Container(
          margin: EdgeInsets.only(top: 0),
          child: Stack(
            children: <Widget>[
              FutureBuilder(
                future: myFuture,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (_feedItems.length > 0) {
                      return _feedBody();
                    } else {
                      return _followSuggestion();
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationMenu(
        iconColor: Color(0xff252525),
        backgroundColor: Color(0xffFAFAFA),
        selectedIconColor: Color(0xFF3982f3),
        currentIndex: 0,
        routedPushed: (bool) {
          setState(() {
            routePushed = bool;
          });
        },
      ),
    );
  }

  _getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: IconThemeData(size: 15, color: Colors.white),
      backgroundColor: Colors.blueAccent,
      onPress: () {
        showBottomSheet(
            context: context,
            builder: (context) => Container(
                  color: Colors.red,
                ));
      },
      children: [
        /*SpeedDialChild(

            child: Icon(
              Icons.edit_outlined,
              color: Colors.white,
            ),
            backgroundColor: Colors.blueAccent,
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return AskQuestionFast();
              }));
              },
            label: 'Ask a Question',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.blueAccent),
        SpeedDialChild(
            child: Icon(Icons.video_call, color: Colors.white),
            backgroundColor: Colors.blueAccent,
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return AddVideoPage();
                  }));
              setState(() {});
            },
            label: 'Record a Video',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.blueAccent)*/
      ],
    );
  }

  refresh() {
    return RefreshIndicator(
      onRefresh: _onRefreshFeedPage,
      child: Container(
        margin: EdgeInsets.only(top: 0),
        child: Stack(
          children: <Widget>[
            FutureBuilder(
              future: myFuture,
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (_feedItems.length > 0) {
                    return _feedBody();
                  } else {
                    return refresh();
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  _feedBody() {
    return InViewNotifierList(
      isInViewPortCondition:
          (double deltaTop, double deltaBottom, double viewPortDimension) {
        return deltaTop < (0.5 * viewPortDimension) &&
            deltaBottom > (0.5 * viewPortDimension);
      },
      itemCount: !endOfData ? _feedItems.length + 1 : _feedItems.length,
      builder: (BuildContext context, int index) {
        if (index < _feedItems.length) {
          return _questionItem(_feedItems[index], index);
        } else {
          _feedItems = [];
          _loadMoreFeedItems();
          return Container(
            padding: EdgeInsets.all(10),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  _questionItem(QuestionData question, int index) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.grey[300], width: 8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10, right: 0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 5.0,
                ),
                _answeredUser(question, index),
                Container(
                  height: 0,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
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
                                needFetch: false,
                              );
                            }
                          }));
                          setState(() {
                            routePushed = false;
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            width: MediaQuery.of(context).size.width,
                            child: RichText(
                              text: TextSpan(
                                text: question.text + '? ',
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
                                      children: <TextSpan>[
                                        TextSpan(
                                          text:
                                              " • Last answered ${_timeAgoText(question)}",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black26),
                                        ),
                                      ]),
                                ],
                              ),
                            )
                            // Text(
                            //   StringUtils.capitalize(question.text) + '?'+,
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            ),
                      ),
                    ),
                    // GestureDetector(
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(right:10.0),
                    //     child: Row(
                    //       crossAxisAlignment: CrossAxisAlignment.end,
                    //       children: [
                    //         Text(
                    //           "${question.answers.length } ${StringHelper.puralize("Answer", question.answers.length)}",
                    //           style: TextStyle(
                    //             //color: Color(0xFF636466),
                    //           ),
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    //   onTap: () async{
                    //     setState(() {
                    //       routePushed = true;
                    //     });
                    //     await Navigator.push(context, MaterialPageRoute(
                    //         builder: (BuildContext context) {
                    //           if (question.interest != null) {
                    //             return QuestionInterestDetailsWidget(
                    //               question: question,
                    //             );
                    //           } else {
                    //             return QuestionDetailsWidget(
                    //               question: question,
                    //               needFetch: false,
                    //             );
                    //           }
                    //         }));
                    //     setState(() {
                    //       routePushed = false;
                    //     });
                    //   },
                    // )
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
              ],
            ),
          ),
          ..._answerDepends(question, index),
          SizedBox(height: 0.0),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
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

  _answeredUser(QuestionData question, [int index]) {
    bool iFollow = _getFollowInformation(question.answers[0].userAnswered.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              question.interest != null
                  ? GestureDetector(
                      onTap: () async {
                        setState(() {
                          routePushed = true;
                        });
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return InterestDetailsWidget(
                              interest: question.interest);
                        }));
                        setState(() {
                          routePushed = false;
                        });
                      },
                      child: Text(
                        'Answer • ' +
                            question.interest.label +
                            ''' • Topic you like''',
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        style:
                            TextStyle(color: Color(0xFF939598), fontSize: 12),
                      ),
                    )
                  : Text(
                      "Answer • Based on people you follow",
                      style: TextStyle(color: Color(0xFF939598), fontSize: 12),
                    ),
              Container(
                width: 20,
                height: 20,
                child: IconButton(
                    iconSize: 20,
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
                                                    _showReportSendSucessfullyDialog();
                                                  },
                                                  splashColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  child: Center(
                                                      child: Text('Harassment',
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
                                                        'Does not Answer the question',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
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
                                                      child: Text('Plagiarism',
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
                                                      child: Text('Joke Answer',
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
                                                      child: Text('Poor Video',
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
                                                  splashColor:
                                                      Colors.transparent,
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
              )
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                onTap: () async {
                  setState(() {
                    routePushed = true;
                  });
                  var result = await ProfileHelpers().navigationProfileHelper(
                      context, question.answers[0].userAnswered.id);
                  setState(() {
                    routePushed = false;
                  });
                },
                contentPadding: EdgeInsets.all(0),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      question.answers[0].userAnswered.avatarImageProvider(),
                ),
                title: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            "${question.answers[0].userAnswered.getFullName()}",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                          color: Color(0xFF282829),
                        ),
                      ), /*
                      TextSpan(
                        text: " • ${_timeAgoText(question)}",
                      )*/
                    ],
                  ),
                ),
                subtitle: Text(
                  _educationText(question),
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            question.answers[0].userAnswered.id != _userLogged.id
                ? IconButton(
                    onPressed: () {
                      iFollow
                          ? _unFollow(question.answers[0].userAnswered)
                          : _follow(question.answers[0].userAnswered);
                    },
                    icon: Icon(
                      Icons.group_add,
                      size: 25.0,
                      color: iFollow ? Colors.blue : Colors.grey[900],
                    ),
                  )
                : SizedBox.shrink()
          ],
        ),
      ],
    );
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
          msg: 'Account is private. Request Sent! ',
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
          msg: 'Error following the user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  _userAnswerInfo(QuestionData question) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ListTile(
            onTap: () async {
              setState(() {
                routePushed = true;
              });
              var result = await ProfileHelpers().navigationProfileHelper(
                  context, question.answers[0].userAnswered.id);
              setState(() {
                routePushed = false;
              });
            },
            contentPadding: EdgeInsets.all(0),
            leading: CircleAvatar(
                radius: 16,
                backgroundImage:
                    question.answers[0].userAnswered.avatarImageProvider()),
            title: Text(
              'Answered by ' + question.answers[0].userAnswered.getFullName(),
              style: TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              _educationText(question),
              style: TextStyle(fontSize: 12),
            ),
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

  _answerDepends(QuestionData question, int index) {
    return [
      Container(
        height: MediaQuery.of(context).size.height / 1.6,
        child: Stack(children: [
          InViewNotifierWidget(
            id: '$index',
            builder: (BuildContext context, bool isInView, Widget child) {
              return VideoWidget(
                // key: UniqueKey(),
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
    ];
  }

  _actionsOnItem(QuestionData question, String likeCount, String commentCount,
      String shareCount) {
    return Container(
      //padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _individualItem(FlutterIcons.thumbs_up_fea, "${likeCount} Like",
              answerId: question.answers[0].id,
              questionData: question,
              f: _like,
              userAffected: question.answers[0].userLike),
//                VerticalDivider(
//                  width: 20,
//                ),
          _individualItem(
            FontAwesomeIcons.comment,
            '${commentCount} Comment',
            answerId: question.answers[0].id,
            f: _comments,
          ),
//                VerticalDivider(
//                  width: 0,
//                ),
          _individualItem(FlutterIcons.send_fea, '${shareCount} Share',
              questionId: question.id,
              answerId: question.answers[0].id,
              type: question.interest != null ? "interest" : "follow",
              f: _share,
              questionData: question),
        ],
      ),
    );
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
    if (icon == FlutterIcons.thumbs_up_fea &&
        questionData.answers[0].userLike) {
      iconColor = Colors.blue;
    }
    return GestureDetector(
      onTap: () {
        f(answerId,
            questionId: questionId, type: type, questionData: questionData);
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
                      questionData.answers[0].userLike
                  ? Colors.blue
                  : Colors.grey[700],
            ),
          )
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
    _feedItems.forEach((question) async {
      if (question.id == questionId) {
        if (!question.userShare) {
          Response response =
              await FeedApiService().share(_userLogged.id, questionId);
          if (response.statusCode == 200) {
            /*
            SocialShare.shareTwitter(
                question.text +"\n"+ question.answer.video,
                hashtags: [question.interest.label.toString()],
                url: shortUrl.toString(),
                trailingText: "hello")
                .then((data) {
              print(data);});*/
            setState(() {
              question.userShare = true;
              question.shares = question.shares + 1;
              _userLogged.questionsShared.add(question);
              Provider.of<UserProvider>(context, listen: false)
                  .updateProvider();
            });
          }
        }
      }
    });
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
      _feedItems.forEach((question) {
        if (question.answers[0].id == answerId) {
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
      });
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

  _educationText(QuestionData question, {bool isAsker = false}) {
    String education;
    if (isAsker) {
      education = StringUtils.defaultString(question.userAsked.job);
    } else {
      education =
          StringUtils.defaultString(question.answers[0].userAnswered.job);
    }
    return education ?? "";
  }

  String _timeAgoText(QuestionData question, {bool isAsker = false}) {
    String time = '';
    time = timeago
        .format(DateTime.fromMillisecondsSinceEpoch(question.lastAnswer));

    return time ?? "";
  }

  Future<List<QuestionData>> _loadFeedItems() async {
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    if (!loadingData && _feedItems.length < 1) {
      loadingData = true;
      Response response = await FeedApiService().getFeed(_userLogged.id, 0, 10);
      if (response.statusCode == 200) {
        _feedItems.clear();
        if (response.data.length < 1) {
          Response suggestResponse =
              await FeedApiService().getSuggestedListForFollow(_userLogged.id);
          if (suggestResponse.statusCode == 200) {
            _suggestedUsers.clear();
            suggestResponse.data.forEach((x) {
              _suggestedUsers.add(User.fromJson(x));
            });
          }
        }
        endOfData = response.data.length > 0 ? false : true;
        bool loadMore = _feedItems.length > 0;
        await response.data.forEach((x) {
          _feedItems.add(QuestionData.fromJson(x));
        });
        Provider.of<CoreProvider>(context, listen: false).feedQuestions =
            _feedItems;
        loadingData = false;
      }
    }
    if (refreshing) {
      setState(() {
        refreshing = false;
      });
    }

    return _feedItems;
  }

  _loadMoreFeedItems() async {
    if (!loadingData) {
      loadingData = true;
      Response response =
          await FeedApiService().getFeed(_userLogged.id, _feedItems.length, 10);

      if (response.statusCode == 200) {
        endOfData = response.data.length > 0 ? false : true;
        bool loadMore = _feedItems.length > 0;
        //_feedItems = [];
        response.data.forEach((x) {
          _feedItems.add(QuestionData.fromJson(x));
        });
        loadingData = false;
        setState(() {});
      }
    }
  }

  _moreQuestionsMessage() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(FontAwesomeIcons.arrowUp, color: Colors.white),
              Container(
                width: 10,
                height: 0,
              ),
              Text(
                'More Questions',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(50))),
        ),
      ),
    );
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

  _followSuggestion() {
    return SingleChildScrollView(
        child: Container(
      height: MediaQuery.of(context).size.height -
          kToolbarHeight -
          kBottomNavigationBarHeight,
      padding: EdgeInsets.only(top: 20),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                'Welcome to StopPoint',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Divider(
                color: Colors.transparent,
              ),
              Text(
                'Share your stories with the world',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return SuggestUserCard(user: _suggestedUsers[index]);
                },
                itemCount: _suggestedUsers.length,
                pagination: null,
                control: null,
                viewportFraction: 0.7,
                scale: 0.9,
                loop: false,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  initData() {
    if (!initDataLoaded) {
      _feedItems =
          Provider.of<CoreProvider>(context, listen: false).feedQuestions;
      myFuture = _loadFeedItems();
      initDataLoaded = true;
    }
  }

  Future<void> _onRefreshFeedPage() {
    refreshing = true;
    Provider.of<CoreProvider>(context, listen: false).feedQuestions.clear();
    myFuture = _loadFeedItems();
    initDataLoaded = true;
    return _loadFeedItems();
  }

//  Check contacts permission
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      await Permission.contacts.request();
      return permission;
    } else {
      return permission;
    }
  }

  void requestPermission(PermisionProvider permisionProvider, context) async {
    permisionProvider.getContactPermission(context);
  }
}

class SheetButton extends StatefulWidget {
  _SheetButtonState createState() => _SheetButtonState();
}

class _SheetButtonState extends State<SheetButton> {
  bool checkingFlight = false;
  bool success = false;
  @override
  Widget build(BuildContext context) {
    return !checkingFlight
        ? MaterialButton(
            color: Colors.grey[800],
            onPressed: () {},
            child: Text(
              'Check Flight',
              style: TextStyle(color: Colors.white),
            ),
          )
        : !success
            ? CircularProgressIndicator()
            : Icon(
                Icons.check,
                color: Colors.green,
              );
  }
}
