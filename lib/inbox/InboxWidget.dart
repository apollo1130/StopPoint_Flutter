import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gzx_dropdown_menu/gzx_dropdown_menu.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/chat/models/Chat.dart';
import 'package:video_app/chat/providers/ChatSessionProvider.dart';
import 'package:video_app/core/widgets/BottomNavigationMenu.dart';
import 'package:video_app/inbox/api/InboxApiService.dart';
import 'package:video_app/inbox/models/ActivityData.dart';
import 'package:video_app/inbox/widgets/activityCards/AnswerCard.dart';
import 'package:video_app/inbox/widgets/activityCards/BlankCard.dart';
import 'package:video_app/inbox/widgets/activityCards/CommentCard.dart';
import 'package:video_app/inbox/widgets/activityCards/FollowRequestCard.dart';
import 'package:video_app/inbox/widgets/activityCards/InterestAsk.dart';
import 'package:video_app/inbox/widgets/activityCards/LikeCard.dart';
import 'package:video_app/inbox/widgets/activityCards/mentionCard.dart';
import 'package:video_app/inbox/widgets/directMessages/DirectMessages.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class InboxWidget extends StatefulWidget {
  @override
  _InboxWidgetState createState() => _InboxWidgetState();
}

class _InboxWidgetState extends State<InboxWidget> {
  bool dataLoaded = false;
  GZXDropdownMenuController _dropdownMenuController =
      GZXDropdownMenuController();
  GlobalKey _stackKey = GlobalKey();
  int selectedActivity = 0;
  String selectedActivityTitle = 'All activity';
  List<ActivityData> allActivity;
  List<ActivityData> commentsActivity = List<ActivityData>();
  List<ActivityData> answerActivity = List<ActivityData>();
  List<ActivityData> followActivity = List<ActivityData>();
  List<ActivityData> questionForYouActivity = List<ActivityData>();
  List<ActivityData> mentionActivity = List<ActivityData>();
  List<ActivityData> likeActivity = List<ActivityData>();
  bool routePushed = false;
  User _userLogged;
  List ListMap ;
  List chatSessions = List();
  var chatSessionsUnread = 0;
  List chats = [];


  _loadChatFromProvider() {
    if (Provider.of<ChatSessionProvider>(context).userChatSession != null) {
      chatSessions = Provider.of<ChatSessionProvider>(context)
          .userChatSession
          .chatSessions;
      chatSessions.sort((a, b) => b
          .dashMessages[b.dashMessages.length - 1].createdAt
          .compareTo(a.dashMessages[a.dashMessages.length - 1].createdAt));
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    //loadUnread();
    super.initState();
  }


  /*loadUnread() async {
    final prefs = await SharedPreferences.getInstance();
    JsonCodec codec = new JsonCodec();
    for(int i=0 ; i< chatSessions.length ; i++){
      print("unread value"+ chatSessions[i].unReadedMessages.toString());
      if( chatSessions[i].unReadedMessages >0){
        print("unread value after test"+ chatSessions[i].unReadedMessages.toString());
        Map<String, dynamic>  ChatToJson = {
          'chatWith': chatSessions[i].chatWith,
          'messages': chatSessions[i].messages,
          'id':chatSessions[i].id,
          'unReadedMessages': chatSessions[i].unReadedMessages,
        };
        chats.add(ChatToJson);
      }
      chatSessionsUnread = chatSessionsUnread + 1;
      setState(() {
        chatSessionsUnread = chatSessionsUnread + 1;
      });
    }

    print("unread length list"+ chats.length.toString());
    String rawJson = codec.encode(chats);
    prefs.setString('my_string_key', rawJson);
  }*/

  @override
  Widget build(BuildContext context) {
    //_loadChatFromProvider();
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    final double barHeight = kToolbarHeight;
    _loadDataFromUserProvider();
    return Stack(
      key: _stackKey,
      children: <Widget>[
        Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 60,
                      height: 55,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 50, top: 10),
                        child: GZXDropDownHeader(
                          height: kToolbarHeight,
                          borderWidth: 0,
                          color: Color(0xffFAFAFA),
                          borderColor: Colors.transparent,
                          iconSize: 30,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                          dropDownStyle: TextStyle(color: Colors.black),
                          iconColor: Colors.black,
                          iconDropDownColor: Colors.black,
                          stackKey: _stackKey,
                          controller: _dropdownMenuController,
                          items: [
                            GZXDropDownHeaderItem(selectedActivityTitle),
                          ],
                          onItemTap: (index) {
                            print(index);
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          routePushed = true;
                        });
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return DirectMessages();
                        }));
                        setState(() {
                          routePushed = false;
                        });
                      },
                      child: Container(
                        width: 52,
                        padding: EdgeInsets.only(right: 0, left: 0, bottom: 0),
                        child: Stack(children: <Widget>[
                          Align(
                              alignment: Alignment.center,
                              child: Icon(FlutterIcons.send_fea,
                                  color: Colors.black)),
                          _userLogged.directMessagesNotification
                              ? Padding(
                                  padding: EdgeInsets.only(left: 27, top: 0),
                                  child: numberMsgUnread(context),
                                )
                              : SizedBox.shrink()
                        ]),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1.0,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[300],
                ),
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: Container(child: _notificationListFiltered()),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationMenu(
            iconColor: Color(0xff252525),
            backgroundColor: Color(0xffFAFAFA),
            selectedIconColor: Color(0xFF3982f3),
            currentIndex: 3,
          ),
        ),
        GZXDropDownMenu(
          controller: _dropdownMenuController,
          animationMilliseconds: 200,
          menus: [
            GZXDropdownMenuBuilder(
                dropDownHeight: 60 * 7.0, dropDownWidget: _dropDownActivity())
          ],
        )
      ],
    );
  }

  Widget numberMsgUnread(BuildContext context) {
    if (chatSessionsUnread != 0) {
      return Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
        height: 18,
        width: 18,
        child: Center(
          child: Text(
            chatSessionsUnread.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
        height: 18,
        width: 18,
      );
    }
  }

  _dropDownActivity() {
    return Material(
      child: ListView(
        padding: EdgeInsets.only(top: 0),
        children: <Widget>[
          _listItem('All activity', FontAwesomeIcons.commentAlt, 0),
          _listItem('Follow requests', FontAwesomeIcons.userFriends, 1),
          _listItem('Like', FontAwesomeIcons.chevronUp, 2),
          _listItem('Interest Questions', FontAwesomeIcons.question, 3),
          _listItem('Questions for you', FontAwesomeIcons.question, 4),
          _listItem('Comments', FontAwesomeIcons.solidComments, 5),
          _listItem('Answers', FlutterIcons.video_fea, 6),

          // _listItem('From us', FontAwesomeIcons.smile, 6),
          // _listItem('Mentions', FontAwesomeIcons.at, 7),
        ],
      ),
    );
  }

  _listItem(String title, IconData icon, int index) {
    return ListTile(
        onTap: () {
          setState(() {
            selectedActivity = index;
            _dropdownMenuController.hide();
            selectedActivityTitle = title;
          });
        },
        leading: Icon(
          icon,
          color: selectedActivity == index ? Colors.black : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
              color: selectedActivity == index ? Colors.black : Colors.grey),
        ),
        trailing: SizedBox(
          width: 24,
          child: selectedActivity == index
              ? Icon(FontAwesomeIcons.check, color: Colors.blueAccent)
              : Container(),
        ));
  }

  _loadDataFromUserProvider() {
    _userLogged = Provider.of<UserProvider>(context).userLogged;
    allActivity = Provider.of<UserProvider>(context).userLogged.notifications;
    mentionActivity = List<ActivityData>();
    _loadChatFromProvider();
    allActivity.forEach((element) {
      switch (element.type) {
        case 'follow':
          followActivity = new List<ActivityData>();
          followActivity.add(element);
          break;
        case 'like':
          likeActivity = new List<ActivityData>();
          likeActivity.add(element);
          break;
        case 'directQuestion':
          mentionActivity = new List<ActivityData>();
          mentionActivity.add(element);
          break;
        case 'comment':
          commentsActivity = new List<ActivityData>();
          commentsActivity.add(element);
          break;
        case 'app':
          break;
        case 'answer':
          answerActivity = new List<ActivityData>();
          answerActivity.add(element);
          break;
        case 'interestAsk':
          questionForYouActivity = new List<ActivityData>();
          questionForYouActivity.add(element);
          break;
      }
    });
  }

  _loadQuestionActivity() {
    List<QuestionData> questions =
        Provider.of<UserProvider>(context).userLogged.questionsReceived;

    questions.forEach((question) {
      ActivityData activityData = _transformQuestionToActivity(question);
      if (allActivity.indexWhere((element) => element.id == activityData.id) ==
          -1) {
        allActivity.insert(0, activityData);
      }
      if (mentionActivity
              .indexWhere((element) => element.id == activityData.id) ==
          -1) {
        mentionActivity.insert(0, activityData);
      }
    });
  }

  _transformQuestionToActivity(QuestionData question) {
    ActivityData newActivity = ActivityData();
    newActivity.id = question.id;
    newActivity.createdAt = question.createdAt;
    newActivity.question = question;
    newActivity.read = false;
    newActivity.relatedUser = question.userAsked;
    newActivity.type = "mention";
    return newActivity;
  }

  _notificationList(List<ActivityData> notifications) {
    return RefreshIndicator(
        onRefresh: _onRefreshInboxPage,
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              switch (notifications[index].type) {
                case 'follow':
                  return FollowRequestCard(activityData: notifications[index]);
                  break;
                case 'like':
                  return LikeCard(activityData: notifications[index]);
                  break;
                case 'comment':
                  return CommentCard(activityData: notifications[index]);
                  break;
                case 'app':
                  return BlankCard(activityData: notifications[index]);
                  break;
                case 'directQuestion':
                  return MentionCard(activityData: notifications[index]);
                  break;
                case 'answer':
                  return AnswerCard(activityData: notifications[index]);
                  break;
                case 'interestAsk':
                  return InterestAskCard(activityData: notifications[index]);
                  break;
                default:
                  return BlankCard(activityData: notifications[index]);
                  break;
              }
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemCount: notifications.length));
  }

  _notificationListFiltered() {
    switch (selectedActivity) {
      case 0:
        return _notificationList(allActivity);
        break;
      case 1:
        return _notificationList(followActivity);
        break;
      case 2:
        return _notificationList(likeActivity);
        break;
      case 3:
        return _notificationList(questionForYouActivity);
        break;
      case 4:
        return _notificationList(mentionActivity);
        break;
      case 5:
        return _notificationList(commentsActivity);
        break;
      case 6:
        return _notificationList(answerActivity);
        break;
      case 7:
        return Container();
        break;
      case 8:
        return Container();
        break;
    }
  }

  example() {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
            'https://cdn.vuetifyjs.com/images/lists/1.jpg'),
      ),
      title: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text('Question for you · Mar 11',
              style: TextStyle(color: Colors.grey[700], fontSize: 15))),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Can i walk into an Apple Store and buy and MacBook Pro?',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Container(
              height: 5,
            ),
            Text('Ali Connor is looking for an answer',
                style: TextStyle(color: Colors.black, fontSize: 14)),
            OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              borderSide: BorderSide(
                color: Colors.blueAccent,
              ),
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.edit,
                    color: Colors.blueAccent,
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Answer',
                        style: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
      trailing: SizedBox(
        width: 30,
        child: Icon(
          FontAwesomeIcons.ellipsisH,
          size: 30,
        ),
      ),
    );
  }

  Future<void> _onRefreshInboxPage() async {
    Response response = await InboxApiService().getUserNotifications(
        Provider.of<UserProvider>(context, listen: false).userLogged.id);

    if (response.statusCode == 200) {
      List<ActivityData> _newActivities = List<ActivityData>();
      response.data.forEach((x) {
        _newActivities.add(ActivityData.fromJson(x));
      });
      Provider.of<UserProvider>(context, listen: false)
          .userLogged
          .notifications = _newActivities;
      Provider.of<UserProvider>(context, listen: false).updateProvider();
    }
  }

}


