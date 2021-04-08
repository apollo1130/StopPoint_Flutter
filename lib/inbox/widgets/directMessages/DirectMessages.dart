import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_app/chat/models/ChatSession.dart';
import 'package:video_app/core/widgets/utils/AppbarBackButton.dart';
import 'package:video_app/inbox/InboxWidget.dart';
import 'package:video_app/inbox/widgets/directMessages/Conversation.dart';
import 'package:video_app/router.dart';

import 'package:video_app/chat/providers/ChatSessionProvider.dart';
import 'package:video_app/chat/models/Chat.dart';
import 'package:provider/provider.dart';

import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:intl/intl.dart';
import 'package:video_app/chat/api/ChatApiService.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'dart:convert';

class DirectMessages extends StatefulWidget {
  @override
  _DirectMessagesState createState() => _DirectMessagesState();
}

class _DirectMessagesState extends State<DirectMessages> {
  List<Chat> chatSessions = List<Chat>();
  var chatSessionsUnread ;
  List chats = [];
  @override
  void initState() {
    chatSessionsUnread =0;
    // TODO: implement initState
    loadUnread();
    for(var i = 0 ; i< chatSessions.length; i++){
      print("Chatsessions");
      print(chatSessions[i].unReadedMessages);
    }
    super.initState();
  }

  loadUnread() async {
    JsonCodec codec = new JsonCodec();

    print("loadUnread");
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString('my_string_key') ?? '';
    try {
      chats = codec.decode(rawJson);
      Map<String, dynamic> list = chats[0];
      print("Decoded 2:" + list["unReadedMessages"].toString());

    } catch (e) {
      print("Error: $e");
    }
      print("loadUnread");
  }

  @override
  Widget build(BuildContext context) {
    for(var i = 0 ; i< chatSessions.length; i++){
      print("Chatsessions");
      print(chatSessions[i].unReadedMessages);
    }
    User userLogged = Provider.of<UserProvider>(context).userLogged;
    _loadChatFromProvider();
    var scaffold = Scaffold(
      appBar: AppBar(
        leading: AppbarBackButton(),
        elevation: 1,
        title: Text('Direct messagess'),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              FlowRouter.router.navigateTo(context, 'directMessages/newChat',
                  transition: TransitionType.inFromBottom);
            },
            child: Container(
              padding: EdgeInsets.only(right: 10),
              child: Icon(FontAwesomeIcons.plus),
            ),
          )
        ],
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
          itemCount: chatSessions.length,
          itemBuilder: (context, index) {
            return _messageListItem(userLogged, chatSessions[index].id,index);
          },
          /*children: <Widget>[
            _messageListItem(),
          ],*/
        ),
      ),
    );
    return scaffold;
  }

  void deletChat(var id,var index) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: new Container(
            color: Colors.grey[300],
            width: 70.0,
            height: 70.0,
            child: new Padding(padding: const EdgeInsets.all(5.0),child: new Center(child: new CircularProgressIndicator())),
          )
        );
      },
    );
    var response = await ChatApiService().deleteChatByContact(
        id + "@" + ApiUrl.XMPP_SERVER_DOMAIN,
        "chat");

    if (response.statusCode == 200) {

      if (response.data["status"]) {
        Provider.of<ChatSessionProvider>(context,listen: false)
            .userChatSession
            .chatSessions
            .removeAt(index);
        ChatSessionProvider chatSessionsProvider = Provider.of<ChatSessionProvider>(context,listen: false);

        chatSessionsProvider.updateProvider();
        Fluttertoast.showToast(
            msg: response.data["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'ERROR: Cannot Delete Chat',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    Navigator.pop(context); //pop dialog

  }

  _showReportSendSucessfullyDialog(var id,var index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure?"),
            content: Text("This will delete whole conversation."),
            actions: <Widget>[
              FlatButton(
                child: Text("YES"),
                onPressed: () {
                  Navigator.of(context).pop();

                  deletChat(id,index);
                },
              ),
              FlatButton(
                child: Text("CANCEL"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _messageListItem(User userLogged, String chatId,int index) {
    Chat chatSession = Provider.of<ChatSessionProvider>(context)
        .userChatSession
        .chatSessions
        .singleWhere((element) => element.id == chatId);
    chatSessionsUnread = 0;
    for(int i= 0 ; i<chats.length ; i++){
      if(chats[i]["id"].toString() != chatId.toString()){
        print("id msg : "+chats[i]["id"].toString());
        print("id msg : "+chatId.toString());
        chatSessionsUnread = chatSessionsUnread + chats[i]["unReadedMessages"];
        /*setState(() {

        });*/
      }
    }
    //chatSessionsUnread = chatSessionsUnread + chats[0]["unReadedMessages"];
    return ListTile(
      onLongPress: (){
        _showReportSendSucessfullyDialog(chatSession.chatWith.id,index);
      },
      onTap: () {
        setState(() {
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Conversation(chatId)),
        );

      },
      contentPadding: EdgeInsets.all(10),
      leading: CircleAvatar(
        radius: 16,
        backgroundImage: chatSession.chatWith.avatarImageProvider(),
      ),
      title: Text(chatSession.chatWith.getFullName(),
          style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
          chatSession.dashMessages[chatSession.dashMessages.length - 1].text,
          overflow: TextOverflow.ellipsis,
          style: chatSessionsUnread > 0
              ? TextStyle(
            fontWeight: FontWeight.bold,
          )
              : TextStyle()),
      trailing: Container(
        height: double.infinity,
        padding: EdgeInsets.only(top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _setMessageDateText(chatSession),
            if (chatSessionsUnread > 0) ...[
              Container(
                  margin: EdgeInsets.all(0),
                  width: 30,
                  height: 30,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    child: Container(
                        color: Colors.blue[400],
                        child: Center(
                            child: FittedBox(
                                child: Text(
                                    chatSessionsUnread.toString(),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ))))),
                  ))
            ]
          ],
        ),
      ),
    );
  }

  Widget _setMessageDateText(dynamic chatSession) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final dateToCheck =
        chatSession.dashMessages[chatSession.dashMessages.length - 1].createdAt;
    final aDate =
    DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    if (aDate == today) {
      return Text(
        DateFormat("hh:mm a").format(chatSession
            .dashMessages[chatSession.dashMessages.length - 1].createdAt),
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
    } else if (aDate == yesterday) {
      return Text('Yesterday');
    } else {
      return Text(
        DateFormat("MM/dd/yyyy").format(chatSession
            .dashMessages[chatSession.dashMessages.length - 1].createdAt),
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
    }
  }

  _loadChatFromProvider() {
    if (Provider.of<ChatSessionProvider>(context).userChatSession != null) {
      chatSessions = Provider.of<ChatSessionProvider>(context)
          .userChatSession
          .chatSessions;
      chatSessions.sort((a,b) => b.dashMessages[b.dashMessages.length - 1].createdAt.compareTo(a.dashMessages[a.dashMessages.length - 1].createdAt));
    }
  }
}
