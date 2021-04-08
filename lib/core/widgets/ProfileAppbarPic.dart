import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/router.dart';

class ProfileAppbarPic extends StatefulWidget {
  final VoidCallback onTap;
  ProfileAppbarPic({this.onTap});
  @override
  _ProfileAppbarPicState createState() => _ProfileAppbarPicState();
}

class _ProfileAppbarPicState extends State<ProfileAppbarPic> {
    User _userLogged;

  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context).userLogged;
    return GestureDetector(
      onTap: (){
        if(widget.onTap  != null) {
          widget.onTap();
        }else {
          FlowRouter.router.navigateTo(context, 'profile', replace: true, transition: TransitionType.none);
        }
      },
      child: Container(
          padding: EdgeInsets.all(8),
          child:CircleAvatar(
            backgroundImage: _userLogged.avatarImageProvider(),
          )
      ),
    );
  }
}

