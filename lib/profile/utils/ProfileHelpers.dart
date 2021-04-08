import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/ProfileWidget.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/widgets/AnotherUserProfileWidget.dart';
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:dio/dio.dart';
import 'package:video_app/profile/models/Interest.dart';

class ProfileHelpers {

  navigationProfileHelper(BuildContext context, userId) async {
    User _userLogged =
        Provider.of<UserProvider>(context, listen: false).userLogged;
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
          if (_userLogged.id == userId) {
            return ProfileWidget();
          } else {
            return AnotherUserProfileWidget(userId: userId);
          }
        }));
    return result;
  }

  bool isLoggedInAsker(askerId, loggedInId) {
    return askerId == loggedInId;
  }

  bool isFollowThisInterest(BuildContext context, String interestId) {
    User _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    bool found = false;

    _userLogged.interests.forEach((element) {
      if(element.id == interestId) {
        found =true;
      }
    });
    return found;
  }

  followInterest(BuildContext context, String interestId) async  {
    User _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    Response response = await  ProfileApiService().followInterest(_userLogged.id, interestId);
    if(response.statusCode == 200) {
      _userLogged.interests.add(Interest.fromJson(response.data));
    }
  }

  unFollowInterest(BuildContext context, String interestId) async {
    User _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    Response response = await  ProfileApiService().unFollowInterest(_userLogged.id, interestId);
    if(response.statusCode == 200) {
      int index =  _userLogged.interests.indexWhere((element) => element.id == interestId);
      _userLogged.interests.removeAt(index);
    }
  }
}