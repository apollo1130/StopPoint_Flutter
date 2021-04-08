import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:localstorage/localstorage.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:video_app/core/providers/CoreProvider.dart';
import 'package:video_app/core/providers/PushProvider.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/chat/providers/ChatSessionProvider.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/router.dart';
import 'auth/api/AuthApiService.dart';
import 'auth/models/User.dart';
import 'core/providers/permision_provider.dart';
import 'core/utils/JwtHelper.dart';
import 'feed/widgets/QuestionDetailsWidget.dart';
import 'feed/widgets/QuestionInterestDetails.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xffFAFAFA),
  ));
  FlowRouter.setupRouter();
  runApp(MyApp());
}

final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(Map<String, dynamic> message) {
  final dynamic data = message['data'] ?? message;
  final String itemId = data['id'];
  final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
    ..status = data['status'];
  return item;
}

class Item {
  Item({this.itemId});
  final String itemId;
/*
  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;
*/
  String _status;
  String get status => _status;
  set status(String value) {
    _status = value;
    //_controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '/detail/$itemId';
    return routes.putIfAbsent(
      routeName,
      () => MaterialPageRoute<void>(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserProvider _userProvider;
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
      // useCountryCode: false,
      // fallbackFile: 'en',
      // path: 'lib/assets/flutter_i18n',
      // forcedLocale: new Locale('es')
      );
  RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
/*
  //var add to notif
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


  //method add to notif
  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: context,
      builder: (_) => _buildDialog(context, _itemForMessage(message)),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }*/
  Widget _buildDialog(BuildContext context, Item item) {
    return AlertDialog(
      content: Text("Item ${item.itemId} has been updated"),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    /*_firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
    });*/
    //final pushProvider = PushProvider();
    //pushProvider.initNotifications();
  }

  // @override
  // void didChangeDependencies() {
  //   this.initDynamicLinks();
  //   super.didChangeDependencies();
  // }

  void initDynamicLinks() async {
//     final PendingDynamicLinkData data =
//     await FirebaseDynamicLinks.instance.getInitialLink();
//     final Uri deepLink = data?.link;
//     String questionId;
//     String type;
// //    print(deepLink);
// //    print(deepLink?.queryParameters ?? "");
// //    print(deepLink?.queryParametersAll);
//     if (deepLink != null &&
//         deepLink.path != null &&
//         deepLink.path == "/question") {
//       questionId = deepLink.queryParameters["qid"];
//       type = deepLink.queryParameters["type"];
//       LocalStorage _storage = LocalStorage('mainStorage');
//       if (await _storage.ready) {
//         String authToken = _storage.getItem('authToken');
//         if (authToken != null && authToken.length > 0) {
//           String id = JWTHelper().getIdFromToken(authToken);
//           Response response = await AuthApiService(token: authToken).getProfile(id);
//           _userProvider = Provider.of<UserProvider>(context, listen: false);
//           _userProvider.userLogged = User.fromJson(response.data);
//         }
//         // dataLoaded = true;
//       }
//     }
//     if (deepLink != null) {
//       SchedulerBinding.instance.addPostFrameCallback((_) {
//         routeObserver.navigator.push(MaterialPageRoute(builder: (BuildContext context) {
//           if (type == "follow") {
//             return QuestionDetailsWidget(
//               question: QuestionData(id: questionId),
//               needFetch: true,
//             );
//           } else {
//             return QuestionInterestDetailsWidget(
//               question: QuestionData(id: questionId),
//               needFetch: true,
//             );
//           }
//         }));
//       });
//     }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      print(deepLink);
      String questionId;
      String type;
      if (deepLink != null &&
          deepLink.path != null &&
          deepLink.path == "/question") {
        questionId = deepLink.queryParameters["qid"];
        type = deepLink.queryParameters["type"];
      }
      if (deepLink != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          routeObserver.navigator
              .push(MaterialPageRoute(builder: (BuildContext context) {
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
        });
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CoreProvider()),
          ChangeNotifierProvider(create: (_) => ChatSessionProvider()),
          ChangeNotifierProvider(create: (_) => PermisionProvider())
        ],
        child: MaterialApp(
          localizationsDelegates: [
            flutterI18nDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          navigatorObservers: [routeObserver],
          //HERE
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Color(0xFFF9F9F7),
            hintColor: Color(0xFF858585),
            fontFamily: 'Noto Sans',
            primarySwatch: Theme.of(context).primaryColor,
            textTheme: TextTheme(headline6: TextStyle(color: Colors.black)),
//        buttonColor: Colors.white
          ),
          initialRoute: 'splash',
          onGenerateRoute: FlowRouter.router.generator,
        ),
      ),
    );
  }
}
