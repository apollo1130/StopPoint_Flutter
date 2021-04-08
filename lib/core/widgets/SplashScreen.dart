import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:animated_background/animated_background.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:video_app/auth/LoginAndSignUpWidget.dart';
import 'package:video_app/auth/api/AuthApiService.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/CoreProvider.dart';
import 'package:video_app/core/utils/JwtHelper.dart';
import 'package:video_app/core/widgets/SelectInterest.dart';
import 'package:video_app/feed/widgets/QuestionDetailsWidget.dart';
import 'package:video_app/feed/widgets/QuestionInterestDetails.dart';
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/router.dart';

import 'package:video_app/chat/models/ChatSession.dart';
import 'package:video_app/chat/providers/ChatSessionProvider.dart';
import 'package:video_app/chat/services/XmppService.dart';
import 'package:video_app/chat/api/ChatApiService.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool dataLoaded = false;
  UserProvider _userProvider;
  CoreProvider _coreProvider;
  ChatSessionProvider _chatSessionProvider;
  String initialLink;
  final imageProvider = AssetImage('lib/assets/images/logo.png');

  @override
  void initState() {
    initUniLinks();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await precacheImage(imageProvider, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _coreProvider = Provider.of<CoreProvider>(context, listen: false);
    return StreamBuilder(
      stream: getLinksStream(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          // our app started by configured links
          var uri = Uri.parse(snapshot.data);
          var list = uri.queryParametersAll.entries
              .toList(); // we retrieve all query parameters , tzd://genius-team.com?product_id=1
          return Text(list.map((f) => f.toString()).join('-'));
          // we just print all //parameters but you can now do whatever you want, for example open //product details page.
        } else {
          // our app started normally
          return Material(
              child: Stack(
            children: <Widget>[
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              AnimatedBackground(
                behaviour: RandomParticleBehaviour(
                  options: ParticleOptions(
                      baseColor: Colors.blueGrey[900],
                      spawnMinSpeed: 3,
                      spawnMaxSpeed: 6.0,
                      particleCount: 20),
                ),
                vsync: this,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: imageProvider,
                            width: MediaQuery.of(context).size.width / 1.5,
                          ),
                          Container(
                            height: 15,
                          ),
                          Text(
                            'Share your story with the world.',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 18,
                                fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ));
        }
      },
    );
  }

  _initData() async {
    LocalStorage _storage = LocalStorage('mainStorage');
    await _loadInterest();
    if (await _storage.ready) {
      String authToken = _storage.getItem('authToken');
      if (authToken != null && authToken.length > 0) {
        String id = JWTHelper().getIdFromToken(authToken);
        Response response =
            await AuthApiService(token: authToken).getProfile(id);
        if (response.statusCode == 404) {
          _storage.deleteItem('authToken');
          FlowRouter.router.navigateTo(context, 'auth', replace: true);
        } else {
          _userProvider = Provider.of<UserProvider>(context, listen: false);
          _userProvider.userLogged = User.fromJson(response.data);
//          _storage.getItem('interestSelected') == null
          if (_userProvider.userLogged.interests != null &&
              _userProvider.userLogged.interests.length < 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return SelectInterest();
            }));
          } else {
            FlowRouter.router.navigateTo(context, 'feed', replace: true);
          }

          //Load last chat log
          _chatSessionProvider =
              Provider.of<ChatSessionProvider>(context, listen: false);
          //Get by userid, max 10 contacts, max 10 messages and type is chat
          response = await ChatApiService()
              .getChats(_userProvider.userLogged.id, 10, 100, "chat");
          if (response.statusCode == 200) {
            _chatSessionProvider.userChatSession =
                ChatSession.fromJson(response.data);
            _chatSessionProvider.userXmppSession = XmppService(
                _userProvider.userLogged.id,
                _userProvider.userLogged.xmppPassword,
                _chatSessionProvider);
            _chatSessionProvider.userXmppSession.connect();
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
        }
      } else {
        FlowRouter.router.navigateTo(context, 'auth', replace: true);
      }
      dataLoaded = true;
    }
  }

  _loadInterest() async {
    try {
      Response response = await ProfileApiService().getInterests();
      if (response.statusCode == 200) {
        _coreProvider.interests = (response.data as List)
            ?.map((e) =>
                e == null ? null : Interest.fromJson(e as Map<String, dynamic>))
            ?.toList();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> initUniLinks() async {
    if (Platform.isAndroid) {
      final PendingDynamicLinkData data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri deepLink = data?.link;
      String questionId;
      String type;
      if (deepLink != null &&
          deepLink.path != null &&
          deepLink.path == "/question") {
        questionId = deepLink.queryParameters["qid"];
        type = deepLink.queryParameters["type"];
        LocalStorage _storage = LocalStorage('mainStorage');
        if (await _storage.ready) {
          String authToken = _storage.getItem('authToken');
          if (authToken != null && authToken.length > 0) {
            String id = JWTHelper().getIdFromToken(authToken);
            Response response =
                await AuthApiService(token: authToken).getProfile(id);
            _userProvider = Provider.of<UserProvider>(context, listen: false);
            _userProvider.userLogged = User.fromJson(response.data);
          }
          // dataLoaded = true;
        }
      }
      if (deepLink != null) {
        var action = await Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          if (type == "follow") {
            return QuestionDetailsWidget(
              question: QuestionData(id: questionId),
              needFetch: true,
            );
          } else {
            return QuestionInterestDetailsWidget(
              question: QuestionData(id: questionId),
              needFetch: true,
            );
          }
        }));
        if (action != null) {
          _initData();
        }
      } else {
        _initData();
      }
    } else {
      await Future.delayed(Duration(milliseconds: 500), () async {
        final PendingDynamicLinkData data =
            await FirebaseDynamicLinks.instance.getInitialLink();
        final Uri deepLink = data?.link;
        String questionId;
        String type;
        if (deepLink != null &&
            deepLink.path != null &&
            deepLink.path == "/question") {
          questionId = deepLink.queryParameters["qid"];
          type = deepLink.queryParameters["type"];
          LocalStorage _storage = LocalStorage('mainStorage');
          if (await _storage.ready) {
            String authToken = _storage.getItem('authToken');
            if (authToken != null && authToken.length > 0) {
              String id = JWTHelper().getIdFromToken(authToken);
              Response response =
                  await AuthApiService(token: authToken).getProfile(id);
              _userProvider = Provider.of<UserProvider>(context, listen: false);
              _userProvider.userLogged = User.fromJson(response.data);
            }
            // dataLoaded = true;
          }
        }
        if (deepLink != null) {
          var action = await Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            if (type == "follow") {
              return QuestionDetailsWidget(
                question: QuestionData(id: questionId),
                needFetch: true,
              );
            } else {
              return QuestionInterestDetailsWidget(
                question: QuestionData(id: questionId),
                needFetch: true,
              );
            }
          }));
          if (action != null) {
            _initData();
          }
        } else {
          _initData();
        }
      });
    }
  }
}
