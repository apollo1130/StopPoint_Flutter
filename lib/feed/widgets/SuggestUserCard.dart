import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
class SuggestUserCard extends StatefulWidget {
  final User user;
  SuggestUserCard({this.user});
  @override
  _SuggestUserCardState createState() => _SuggestUserCardState();
}

class _SuggestUserCardState extends State<SuggestUserCard> {
  User _user;
  bool follow = false;
  User _userLogged;
  @override
  Widget build(BuildContext context) {
    _userLogged  = Provider.of<UserProvider>(context, listen:false ).userLogged;
    _user = widget.user;
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: _user.avatarImageProvider(),
                  ),
                  Divider(color: Colors.transparent,),
                  Text(_user.getFullName(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  Divider(color: Colors.transparent,),
                  Divider(color: Colors.transparent,),
                  _followUnFollow(_user),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _followUnFollow(User user) {
    follow = _checkIfIFollow(user.id);
    if(follow) {
      return RaisedButton(
        onPressed: (){
          _unfollow();
        },
        child: Text('Following'),
      );
    }else {
      return RaisedButton(
        onPressed: (){
          _follow();
        },
        color: Colors.blue,
        child: Text('Follow', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      );
    }
  }

  _follow() async {
    Response response  =  await ProfileApiService().follow(_userLogged.id,  _user.id);

    if(response.statusCode == 200 ) {
      setState(() {
        _userLogged.following.add(User.fromJson(response.data));
      });
    }else {
      Fluttertoast.showToast(
          msg: 'Account is private. Request Sent!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 14.0
      );
    }
  }

  _unfollow() async {
    Response response  =  await ProfileApiService().unfollow(_userLogged.id,  _user.id);
    if(response.statusCode == 200 ) {
      setState(() {
        int index =  _userLogged.following.indexWhere((element) => element.id ==  _user.id);
        _userLogged.following.removeAt(index);
      });
    }else {
      Fluttertoast.showToast(
          msg: 'Error stopping following the user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  _checkIfIFollow(String userId){
    bool found =false;
    _userLogged.following.forEach((element) {
      if(element.id == userId){
        found =true;
      }
    });
    return found;
  }
}
