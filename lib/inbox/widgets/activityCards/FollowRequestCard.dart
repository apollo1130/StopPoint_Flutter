import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:video_app/inbox/models/ActivityData.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
class FollowRequestCard extends StatefulWidget {
  final ActivityData activityData;
  FollowRequestCard({this.activityData});
  @override
  _FollowRequestCardState createState() => _FollowRequestCardState();
}

class _FollowRequestCardState extends State<FollowRequestCard> {

  bool followAccepted = false;
  User _userLogged;

  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context, listen:false).userLogged;
    var img ;
    var name ;
    try{
      if (widget.activityData.relatedUser.avatar != null)
      {img= widget.activityData.relatedUser.avatarImageProvider(); }
      else{ img=AssetImage('lib/assets/images/defaultUser.png');}
    }catch(e){
      print("image null");
      img=AssetImage('lib/assets/images/defaultUser.png');
    }
    try{
      if (widget.activityData.relatedUser.username == null)
      {name= widget.activityData.relatedUser.username; }
      else{ name= widget.activityData.relatedUser.email;}
    }catch(e){
      print(widget.activityData.relatedUser.toString());
    }
    return ListTile(
        onTap: () async {
          ProfileHelpers().navigationProfileHelper(context, widget.activityData.relatedUser.id);
        },
        leading: CircleAvatar(
          backgroundImage: img,
        ),
        title: RichText(
          text: TextSpan(
              text: name,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: _followText(),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                )
              ]
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeago.format(DateTime.fromMillisecondsSinceEpoch(widget.activityData.createdAt)),
              style: TextStyle(color: Colors.grey),
            ),
            Container(
              height: 0,
            ),
            _followAcceptDeclineButtons()
          ],
        )
        // trailing: _followAcceptDeclineButtons()
    );
  }


  _followText(){
    switch(widget.activityData.followStatus) {
      case 'pending':
        return ' asked to follow you.'
        ;break;
      case 'accepted':
        return ' started following you.'
        ;break;
      case 'declined':
        return ' follow request declined.'
        ;break;
    }
  }

  _followAcceptDeclineButtons() {
    switch(widget.activityData.followStatus) {
      case 'pending':
       return  Row(
          children: [
            RaisedButton(
              onPressed: (){
                _declineFollow();
              },
              child: Text('Decline',),
            ),
            Container(width: 10,),
            RaisedButton(
              onPressed: (){
                _acceptFollow();
              },
              color: Colors.blue,
              child: Text('Accept',  style: TextStyle(color: Colors.white),),
            )
          ],
        )
        ;break;
      case 'accepted':
        return RaisedButton(
          onPressed: null,
          child: Text('Accepted',),
        )
        ;break;
      case 'declined':
        return RaisedButton(
        onPressed: null,
        child: Text('Declined',),
        )
        ;break;
    }
  }

  _acceptFollow() async {
    Response response =  await ProfileApiService().acceptFollow(widget.activityData.user.id, widget.activityData.relatedUser.id);
    if(response.statusCode == 200) {
      setState(() {
        widget.activityData.followStatus = 'accepted';
        _userLogged.followers.add(widget.activityData.relatedUser);
      });
    }

  }

  _declineFollow() async {
    Response response =  await ProfileApiService().declineFollow(widget.activityData.user.id, widget.activityData.relatedUser.id);
    if(response.statusCode == 200) {
      setState(() {
        widget.activityData.followStatus = 'declined';
      });
    }
  }
}
