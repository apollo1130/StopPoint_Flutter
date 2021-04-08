import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:localstorage/localstorage.dart';

class PushProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  initNotifications() async {
    LocalStorage storage = LocalStorage('mainStorage');
    bool storageReady = await storage.ready;
    if (storageReady) {
      if (storage.getItem('pushToken') == null) {
        String pushToken = await _firebaseMessaging.getToken();
        storage.setItem('pushToken', pushToken);
      }
      print("Your push token is ${storage.getItem('pushToken')}");
      // _firebaseMessaging.configure(
      //   onMessage: (Map<String, dynamic> message) async {
      //     print("onMessage: $message");
      //   },
      //   onLaunch: (Map<String, dynamic> message) async {
      //     print("onLaunch: $message");
      //   },
      //   onResume: (Map<String, dynamic> message) async {
      //     print("onResume: $message");
      //   },
      // );
      _firebaseMessaging. requestPermission(
          // const IosNotificationSettings(sound: true, badge: true, alert: true)
          );
      // _firebaseMessaging.onIosSettingsRegistered
      //     .listen((IosNotificationSettings settings) {
      //   print("Settings registered: $settings");
      // });
    }
  }
}
