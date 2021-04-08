import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class AudienceSelect extends StatelessWidget {
  var defaultAudience;
  AudienceSelect({@required this.defaultAudience});

  @override
  Widget build(BuildContext context) {
    print(defaultAudience);
    var v = defaultAudience;
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        leading: GestureDetector(
          onTap: (){
           Navigator.pop(context, v);
          },
          child: Container(
            width: 20,
            child: Icon(FontAwesomeIcons.times, color:Colors.white),
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Text('Audience', style: TextStyle(color: Colors.white, fontSize: 24),),
            Divider(color: Colors.transparent,),
            _audienceOption(
                'Public', 'Others will see your identity alongside this question on your profile and in their feeds',
                AudienceType.Public,
                context,
                FontAwesomeIcons.userFriends
            ),
            Divider(color: Colors.grey[200],),
            _audienceOption(
                'Anonymous', 'Your identity will never be associated with this question',
                AudienceType.Anonymous,
                context,
                FontAwesomeIcons.userSlash
            ),
            Divider(color: Colors.grey[200],),
            // _audienceOption('Limited', 'Your Identity will be shown but this question will not appear in your follower\'s feed or your profile',
            //     AudienceType.Limited,
            //     context,
            //     FontAwesomeIcons.solidUser
            // ),
            // Divider(color: Colors.grey[200],),
          ],
        ),
      ),
    );
  }

  _audienceOption (String title, String description, AudienceType audienceType, BuildContext context, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title,  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
      subtitle: Text(description, style: TextStyle(color: Colors.grey),),
      onTap: (){
        print(audienceType);
        defaultAudience = audienceType;
        Navigator.pop(context,defaultAudience );
      },
    );
  }
}

enum AudienceType {
  Public,
  Anonymous,
  Limited
}

