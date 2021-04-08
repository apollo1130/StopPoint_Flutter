import 'package:flutter/material.dart';
import 'package:video_app/inbox/models/ActivityData.dart';

class  BlankCard extends StatelessWidget {

  final ActivityData activityData;
  BlankCard({this.activityData});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(activityData.type + ' No created', style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),),
    );
  }
}
