import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_app/chat/models/Chat.dart';
import 'package:video_app/chat/providers/ChatSessionProvider.dart';
import 'package:video_app/chat/services/XmppService.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/widgets/utils/AppbarBackButton.dart';
import 'package:video_app/inbox/InboxWidget.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/chat/api/ChatApiService.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Conversation extends StatefulWidget {
  final String chatId;

  Conversation(this.chatId);

  @override
  _ConversationState createState() => _ConversationState(this.chatId);
}

class _ConversationState extends State<Conversation> {
  final String chatId;
  Chat chatSession;
  bool _isLoadingMore;
  int _offSet;
  ChatSessionProvider chatSessionsProvider;
  List chats = [];
  //ScrollController _scrollController = new ScrollController();

  _ConversationState(this.chatId);
  loadUnread() async {
    JsonCodec codec = new JsonCodec();

    print("loadUnread");
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString('my_string_key') ?? '';
    try {
      chats = codec.decode(rawJson);
      Map<String, dynamic> list = chats[0];
      print("Decoded 2:" + list["unReadedMessages"].toString());
      prefs.remove("my_string_key");
    } catch (e) {
      print("Error: $e");
    }
    print("loadUnread");
  }

  @override
  void initState() {
    _offSet = 0;
    _isLoadingMore = false;
    loadUnread();

    /*_scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.position.pixels == 0) {
        if (!_isLoadingMore) {
          //loadMore();
        }
      }
    });*/
    super.initState();
  }

  void loadMore() async {

    _isLoadingMore = true;
    _offSet = chatSession.dashMessages.length;
    User _userLogged =
        Provider.of<UserProvider>(context, listen: false).userLogged;
    var response = await ChatApiService().getChatByContact(
        _userLogged.id,
        chatSession.chatWith.id + "@" + ApiUrl.XMPP_SERVER_DOMAIN,
        10,
        _offSet,
        "chat");

    if (response.statusCode == 200) {
     Chat tmpChat = Chat.fromJson(response.data);
      if (tmpChat.dashMessages.length > 0) {
        //chatSession.dashMessages.addAll(tmpChat.dashMessages);
        chatSession.dashMessages.insertAll(0, tmpChat.dashMessages);
        _offSet = chatSession.dashMessages.length;
        chatSessionsProvider.updateProvider();
      }
    } else {
      Fluttertoast.showToast(
          msg: 'ERROR: Cannot fetch chat history',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    _isLoadingMore = false;
  }

  @override
  Widget build(BuildContext context) {

    chatSessionsProvider = Provider.of<ChatSessionProvider>(context);
    User _userLogged = Provider.of<UserProvider>(context).userLogged;
    var chatIndex = Provider.of<ChatSessionProvider>(context)
        .userChatSession
        .chatSessions
        .indexWhere((element) => element.id == chatId);


    if (chatIndex == -1) {
      chatSession = Chat(
          _userLogged.following.singleWhere((element) => element.id == chatId),
          []);
      chatSessionsProvider.userChatSession.chatSessions.add(chatSession);
    } else {
      chatSession =
      chatSessionsProvider.userChatSession.chatSessions[chatIndex];
    }
    XmppService xmppService =
        Provider.of<ChatSessionProvider>(context).userXmppSession;

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackButton(),
        elevation: 1,
        title: Text(chatSession.chatWith.getFullName()),
        centerTitle: true,
      ),
      body: Container(
        child: SafeArea(
          child: DashChat(
            inputContainerStyle: BoxDecoration(
              color: Colors.grey[200],
            ),
            inputDecoration:
            InputDecoration.collapsed(hintText: "Message here..."),
            onLoadEarlier: () => {if (!_isLoadingMore) loadMore()},
            avatarBuilder: (user) {
              return CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.avatar),
              );
            },
            showUserAvatar: true,
            user: ChatUser(uid: _userLogged.id, avatar: _userLogged.avatar),
            timeFormat: DateFormat('hh:mm a'),
            messages: chatSession.dashMessages,
            onSend: (message) {
              xmppService.sendMessage(chatSession.chatWith.id, message.text);
              chatSession.dashMessages.add(message);
            },
          ),
        ),
      ),
    );
  }
}
