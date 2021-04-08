import 'package:flutter/material.dart';
import 'package:video_app/inbox/models/ActivityData.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/profile/utils/ProfileHelpers.dart';
class CommentCard extends StatefulWidget {
  final ActivityData activityData;
  CommentCard({this.activityData});
  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  bool followState = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: GestureDetector(
          onTap: (){
            ProfileHelpers().navigationProfileHelper(context, widget.activityData.relatedUser.id);
          },
          child: CircleAvatar(
            backgroundImage: widget.activityData.relatedUser.avatarImageProvider(),
          ),
        ),
        title: RichText(
          text: TextSpan(
              text: widget.activityData.relatedUser != null? (widget.activityData.relatedUser.username != null ?
              widget.activityData.relatedUser.username : widget.activityData.relatedUser.getFullName()) : 'no-name',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: ' commented on your answer',
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