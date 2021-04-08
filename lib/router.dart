import 'package:flutter/material.dart' hide Router;
import 'package:fluro/fluro.dart';
import 'package:video_app/TestWidget.dart';
import 'package:video_app/auth/LoginAndSignUpWidget.dart';
import 'package:video_app/core/widgets/SplashScreen.dart';
import 'package:video_app/explore/ExploreWidget.dart';
import 'package:video_app/feed/FeedWidget.dart';
import 'package:video_app/feed/widgets/PagesWidgetList.dart';
import 'package:video_app/home/HomeWidget.dart';
import 'package:video_app/home/Widgets/SendListWidget.dart';
import 'package:video_app/inbox/InboxWidget.dart';
import 'package:video_app/inbox/widgets/directMessages/DirectMessages.dart';
import 'package:video_app/inbox/widgets/directMessages/NewChat.dart';
import 'package:video_app/pages/PagesWidget.dart';
import 'package:video_app/profile/ProfileWidget.dart';
import 'package:video_app/questions/QuestionsWidget.dart';
import 'package:video_app/questions/Widgets/CameraWidget.dart';
import 'package:video_app/questions/Widgets/UserAskedWidget.dart';
import 'package:video_app/videoQuestion/AddVideo.dart';

class FlowRouter {
  static final router = FluroRouter();
  static Handler _homeHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          HomeWidget());
  static Handler _sendListHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          SendListWidget());
  static Handler _feedHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          FeedWidget());
  static Handler _questionHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuestionsWidget());
  static Handler _cameraHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CameraWidget());
  static Handler _userAskedHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          UserAskedWidget());
  static Handler _testPage = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          TestWidget());
  static Handler _inboxHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          InboxWidget());
  static Handler _exploreHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ExploreWidget());
  static Handler _pagesHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          PagesWidget());
  static Handler _directMessagesHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DirectMessages());
  static Handler _newChatHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          NewChat());
  static Handler _profileHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ProfileWidget());
  static Handler _loginHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginAndSignUpWidget());
  static Handler _splashHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          SplashScreen());
  static Handler _recordHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Addvideo());
  static void setupRouter() {
    router.define('home', handler: _homeHandler);
    router.define('home/sendList', handler: _sendListHandler);
    router.define('feed', handler: _feedHandler);
    router.define('questions', handler: _questionHandler);
    router.define('questions/camera', handler: _cameraHandler);
    router.define('questions/userAsked', handler: _userAskedHandler);
    router.define('inbox', handler: _inboxHandler);
    router.define('directMessages', handler: _directMessagesHandler);
    router.define('directMessages/newChat', handler: _newChatHandler);
    router.define('pages', handler: _pagesHandler);
    router.define('profile', handler: _profileHandler);
    router.define('explore', handler: _exploreHandler);
    router.define('auth', handler: _loginHandler);
    router.define('splash', handler: _splashHandler);
    router.define('test', handler: _testPage);
    router.define('record', handler: _recordHandler);

  }
}
