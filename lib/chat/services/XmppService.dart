import 'dart:async';
import 'dart:convert';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'dart:io';
import "package:console/console.dart";
import 'package:image/image.dart' as image;
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:video_app/chat/providers/ChatSessionProvider.dart';
import 'package:video_app/chat/models/Chat.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/auth/api/AuthApiService.dart';
import 'package:dio/dio.dart';
import 'package:video_app/chat/models/Message.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:provider/provider.dart';

String currentusername;

class XmppService {
  xmpp.Connection connection;
  ChatSessionProvider _chatSessionProvider;
  String username;
  String password;

  XmppService(this.username, this.password, this._chatSessionProvider);

  void sendMessage(String to, String txt) {
    xmpp.Jid receiverJid =
        xmpp.Jid.fromFullJid(to + "@" + ApiUrl.XMPP_SERVER_DOMAIN);
    xmpp.MessageHandler messageHandler =
        xmpp.MessageHandler.getInstance(this.connection);
    messageHandler.sendMessage(receiverJid, txt);
    this._chatSessionProvider.updateProvider();
    //this.connection.close();
  }

  void connect() {
    currentusername = username;
    xmpp.Jid jid =
        xmpp.Jid.fromFullJid(this.username + "@" + ApiUrl.XMPP_SERVER_DOMAIN);
    this.connection = xmpp.Connection(xmpp.XmppAccountSettings(jid.userAtDomain,
        jid.local, jid.domain, password, ApiUrl.XMPP_SERVER_PORT,
        host: ApiUrl.XMPP_SERVER_ADDRESS, resource: 'FlutterApp'));
    this.connection.connect();

    //Message listener
    xmpp.MessagesListener messagesListener =
        ExampleMessagesListener(_chatSessionProvider);
    ExampleConnectionStateChangedListener(connection, messagesListener);

    /*xmpp.PresenceManager presenceManager = xmpp.PresenceManager.getInstance(connection);
    presenceManager.subscriptionStream.listen((streamEvent) {
      if (streamEvent.type == xmpp.SubscriptionEventType.REQUEST) {
        print("*************************************** Accepting presence request ********************************************");
        presenceManager.acceptSubscription(streamEvent.jid);
      }
    });*/

    /*var receiver = "amoreau@localhost";
    xmpp.Jid receiverJid = xmpp.Jid.fromFullJid(receiver);
    xmpp.MessageHandler messageHandler = xmpp.MessageHandler.getInstance(connection);
    messageHandler.sendMessage(receiverJid, "Hola alejandro que tal?");*/

    /*getConsoleStream().asBroadcastStream().listen((String str) {
      messageHandler.sendMessage(receiverJid, str);
    });*/
  }
}

class ExampleConnectionStateChangedListener
    implements xmpp.ConnectionStateChangedListener {
  xmpp.Connection _connection;
  xmpp.MessagesListener _messagesListener;

  StreamSubscription<String> subscription;

  ExampleConnectionStateChangedListener(
      xmpp.Connection connection, xmpp.MessagesListener messagesListener) {
    _connection = connection;
    _messagesListener = messagesListener;
    _connection.connectionStateStream.listen(onConnectionStateChanged);
  }

  @override
  void onConnectionStateChanged(xmpp.XmppConnectionState state) {
    switch (state) {
      case xmpp.XmppConnectionState.Idle:
        print("IDLE!");
        break;
      case xmpp.XmppConnectionState.Closed:
        print(state);
        print("Connection is closed!");
        // _connection.connect();
        break;
      case xmpp.XmppConnectionState.SocketOpening:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.DoneParsingFeatures:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.StartTlsFailed:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.AuthenticationNotSupported:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.PlainAuthentication:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.Authenticating:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.Authenticated:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.AuthenticationFailure:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.Resumed:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.SessionInitialized:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.DoneParsingFeatures:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.Ready:
        xmpp.MessageHandler messageHandler =
            xmpp.MessageHandler.getInstance(_connection);
        messageHandler.messagesStream.listen(_messagesListener.onNewMessage);
        xmpp.PresenceManager presenceManager =
            xmpp.PresenceManager.getInstance(_connection);
        presenceManager.presenceStream.listen(onPresence);
        break;
      case xmpp.XmppConnectionState.ForcefullyClosed:
        // TODO: Handle this case.
        break;
      case xmpp.XmppConnectionState.Reconnecting:
        // TODO: Handle this case.
        break;
    }

    /*if (state == xmpp.XmppConnectionState.Ready) {
      print("Connected");

      var receiver = "amoreau@localhost";
      xmpp.Jid receiverJid = xmpp.Jid.fromFullJid(receiver);
      xmpp.MessageHandler messageHandler = xmpp.MessageHandler.getInstance(_connection);
      messageHandler.sendMessage(receiverJid, "Hola alejandro que tal?");

      xmpp.VCardManager vCardManager = xmpp.VCardManager(_connection);
      vCardManager.getSelfVCard().then((vCard) {
        if (vCard != null) {
          print("Your info" + vCard.buildXmlString());
        }
      });
      //xmpp.MessageHandler messageHandler = xmpp.MessageHandler.getInstance(_connection);
      xmpp.RosterManager rosterManager = xmpp.RosterManager.getInstance(_connection);
      messageHandler.messagesStream.listen(_messagesListener.onNewMessage);
      sleep(const Duration(seconds: 1));
      //print("Enter receiver jid: ");
      //var receiver = stdin.readLineSync(encoding: utf8);
      //var receiver = "admin@localhost";
      //xmpp.Jid receiverJid = xmpp.Jid.fromFullJid(receiver);
      rosterManager.addRosterItem(xmpp.Buddy(receiverJid)).then((result) {
        if (result.description != null) {
          print("add roster" + result.description);
        }
      });
      sleep(const Duration(seconds: 1));
      vCardManager.getVCardFor(receiverJid).then((vCard) {
        if (vCard != null) {
          print("Receiver info" + vCard.buildXmlString());
          if (vCard != null && vCard.image != null) {
            var file = File('test456789.jpg')..writeAsBytesSync(image.encodeJpg(vCard.image));
            print("IMAGE SAVED TO: ${file.path}");
          }
        }
      });
      xmpp.PresenceManager presenceManager = xmpp.PresenceManager.getInstance(_connection);
      presenceManager.presenceStream.listen(onPresence);
    }*/
  }

  void onPresence(xmpp.PresenceData event) {
    print("presence Event from " +
        event.jid.fullJid +
        " PRESENCE: " +
        event.showElement.toString());
  }
}

Stream<String> getConsoleStream() {
  return Console.adapter.byteStream().map((bytes) {
    var str = ascii.decode(bytes);
    str = str.substring(0, str.length - 1);
    return str;
  });
}

class ExampleMessagesListener implements xmpp.MessagesListener {
  ChatSessionProvider _chatSessionProvider;
  ExampleMessagesListener(this._chatSessionProvider);
  LocalStorage _storage = LocalStorage('mainStorage');

  @override
  onNewMessage(xmpp.MessageStanza message) async {
    if (message.body != null) {
      var chatIndex = this
          ._chatSessionProvider
          .userChatSession
          .chatSessions
          .indexWhere(
              (element) => element.chatWith.id == message.fromJid.local);
      User fromUser = this
          ._chatSessionProvider
          .userChatSession
          .getUserFromChatSessions(message.fromJid.local);

      if (fromUser == null) {
        if (await _storage.ready) {
          String authToken = _storage.getItem('authToken');
          Response contactUser = await AuthApiService(token: authToken)
              .getProfile(message.fromJid.local);
          if (contactUser.statusCode == 200) {
            fromUser = User.fromJson(contactUser.data);
            print("fromUser" + fromUser.toJson().toString());
          }
        } else {
          Fluttertoast.showToast(
              msg: 'ERROR: Cannot fetch user from incomming message',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          return;
        }
      }
      print("User" + fromUser.toJson().toString());

      if (message.children.indexWhere((element) => element.name == 'delay') !=
          -1) {
        if (chatIndex == -1) {
          this._chatSessionProvider.userChatSession.chatSessions.insert(
              0,
              Chat(
                  fromUser, [Message(fromUser, message.body, DateTime.now())]));
        }

        this
            ._chatSessionProvider
            .userChatSession
            .chatSessions[0]
            .unReadedMessages++;
      } else {
        if (chatIndex == -1) {
          LocalStorage _storage = LocalStorage('mainStorage');
          if (currentusername != message.fromJid.local) {
            this._chatSessionProvider.userChatSession.chatSessions.insert(
                0,
                Chat(fromUser,
                    [Message(fromUser, message.body, DateTime.now())]));
          }

          if (currentusername != message.fromJid.local) {
            this
                ._chatSessionProvider
                .userChatSession
                .chatSessions[0]
                .unReadedMessages++;
          }

          print("trytry" + currentusername + " hgf " + message.fromJid.local);
        } else {
          this
              ._chatSessionProvider
              .userChatSession
              .chatSessions[chatIndex]
              .addChatMessage(fromUser, message.body);
        }
      }
      this._chatSessionProvider.updateProvider();
    }
  }
}
