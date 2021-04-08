import 'package:flutter/cupertino.dart';
import 'package:video_app/chat/models/ChatSession.dart';
import 'package:video_app/chat/services/XmppService.dart';

class ChatSessionProvider extends ChangeNotifier {
  ChatSession _chatSession;
  XmppService _xmppService;

  // ignore: unnecessary_getters_setters
  ChatSession get userChatSession => _chatSession;

  // ignore: unnecessary_getters_setters
  set userChatSession(ChatSession session) {
    _chatSession = session;
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  XmppService get userXmppSession => _xmppService;

  // ignore: unnecessary_getters_setters
  set userXmppSession(XmppService session) {
    _xmppService = session;
    notifyListeners();
  }

  updateProvider() {
    notifyListeners();
  }
}
