import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_app/core/providers/permision_provider.dart';
import 'package:video_app/feed/widgets/QuestionInterestDetails.dart';
import 'package:video_app/inbox/models/ActivityData.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:video_app/questions/Widgets/CameraWidget.dart';
class MentionCard extends StatefulWidget {
  final ActivityData activityData;
  MentionCard({this.activityData});
  @override
  _MentionCardState createState() => _MentionCardState();
}

class _MentionCardState extends State<MentionCard> {

  bool followState = false;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<PermisionProvider>(context);
    return ListTile(
      onTap: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return QuestionInterestDetailsWidget(
                  question: widget.activityData.question);
            }));
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question for You · ' +timeago.format(DateTime.fromMillisecondsSinceEpoch(widget.activityData.createdAt)), style: TextStyle(color: Colors.grey, fontSize: 12),),
          Container(height: 10,),
          Text(StringUtils.capitalize(widget.activityData.question.text) + '?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
          Text(
            (widget.activityData.relatedUser.username != null ?
            "An anonymous user" : widget.activityData.relatedUser.getFullName())
                + ' is looking for an answer.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Container(height: 10,),
          OutlineButton(
            onPressed: (){
              bloc.getCameraPermission(context, widget.activityData.question);
            },
            borderSide: BorderSide(
                color: Color(0xFF2E6AFF)
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FlutterIcons.video_fea,
                  color: Color(0xFF2E6AFF),
                  size: 14.0,
                ),
                Container(
                  width: 10,
                ),
                Text(
                  'Answer',
                  style: TextStyle(
                      color: Color(0xFF2E6AFF),
                      fontSize: 14
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      leading: GestureDetector(
        onTap: (){
          if (widget.activityData.relatedUser.username == null){
            ProfileHelpers().navigationProfileHelper(
                context, widget.activityData.relatedUser.id);
          }
        },
        child: CircleAvatar(
          backgroundImage: widget.activityData.relatedUser.username != null
              ? AssetImage('lib/assets/images/defaultUser.png')
              : widget.activityData.relatedUser.avatarImageProvider(),
        ),
      ),
    );
  }


}