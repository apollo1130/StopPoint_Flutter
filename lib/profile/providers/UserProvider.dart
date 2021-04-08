import 'package:flutter/cupertino.dart';
import 'package:video_app/auth/models/User.dart';

class UserProvider extends ChangeNotifier {
  User _userLogged;
  // ignore: unnecessary_getters_setters

  User get userLogged => _userLogged;

  // ignore: unnecessary_getters_setters
  set userLogged(User user) {
    _userLogged = user;
    notifyListeners();
  }

  updateProvider() {
    notifyListeners();
  }
}
