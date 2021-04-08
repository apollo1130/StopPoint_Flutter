import 'package:flutter/material.dart';
import 'package:video_app/inbox/models/ActivityData.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/profile/utils/ProfileHelpers.dart';
class LikeCard extends StatefulWidget {
  final ActivityData activityData;
  LikeCard({this.activityData});
  @override
  _LikeCardState createState() => _LikeCardState();
}

class _LikeCardState extends State<LikeCard> {

  bool followState = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: GestureDetector(
          onTap: (){
            ProfileHelpers().navigationProfileHelper(context, widget.activityData.relatedUser.id);
          },
          child: CircleAvatar(
            backgroundImage:widget.activityData.relatedUser != null?  widget.activityData.relatedUser.avatarImageProvider(): null,
          ),
        ),
        title: RichText(
          text: TextSpan(
              text: widget.activityData.relatedUser != null? (widget.activityData.relatedUser.username != null ?
              widget.activityData.relatedUser.username : widget.activityData.relatedUser.getFullName()) : 'no-name',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: ' liked your answer.',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                )
              ]
          ),
        ),
        subtitle: Text(
          timeago.format(DateTime.fromMillisecondsSinceEpoch(widget.activityData.createdAt)),
          style: TextStyle(color: Colors.grey),
        )
    );
  }
}