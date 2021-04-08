import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/inbox/models/ActivityData.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';
class StartedFollowCard extends StatefulWidget {
  final ActivityData activityData;
  StartedFollowCard({this.activityData});
  @override
  _StartedFollowCardState createState() => _StartedFollowCardState();
}

class _StartedFollowCardState extends State<StartedFollowCard> {

  bool followState = false;

  @override
  Widget build(BuildContext context) {
    _loadFollowState();
    return ListTile(
        onTap: () async {
          ProfileHelpers().navigationProfileHelper(context, widget.activityData.relatedUser.id);
        },
        leading: CircleAvatar(
          backgroundImage: widget.activityData.relatedUser.avatarImageProvider(),
        ),
        title: RichText(
          text: TextSpan(
              text: (widget.activityData.relatedUser.username != null ?
              widget.activityData.relatedUser.username : widget.activityData.relatedUser.getFullName()),
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: ' started following you.',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                )
              ]
          ),
        ),
        subtitle: Text(
          timeago.format(DateTime.fromMillisecondsSinceEpoch(widget.activityData.createdAt)),
          style: TextStyle(color: Colors.grey),
        ),
        trailing: !followState ? RaisedButton(
          onPressed: (){
            _follow();
          },
          color: Colors.blue,
          child: Text('Follow',  style: TextStyle(color: Colors.white),),
        ):RaisedButton(
          onPressed: null,
          color: Colors.blue,
          child: Text('Follow sent',  style: TextStyle(color: Colors.white),),
        )
    );
  }

  _follow() async {
    Response response  =  await ProfileApiService().follow(widget.activityData.user.id,  widget.activityData.relatedUser.id);

    if(response.statusCode == 200 ) {
      setState(() {
        followState = true;
      });
    }else {
      Fluttertoast.showToast(
          msg: 'Error following the user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  _loadFollowState(){
    User  user = Provider.of<UserProvider>(context).userLogged;

    user.following.forEach((element) {
      if(element.id == widget.activityData.relatedUser.id){
        followState = true;
      }
    });

  }
}