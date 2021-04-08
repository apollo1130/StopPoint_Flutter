import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainTabPageWidget extends StatefulWidget {
  @override
  _MainTabPageWidgetState createState() => _MainTabPageWidgetState();
}

class _MainTabPageWidgetState extends State<MainTabPageWidget> {
  @override
  Widget build(BuildContext context) {
    return   SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text('Getting Started', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,),
            Container(height: 5,),
            Text('Congratulation on making your page. Here are some tips to set up for success', style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center,),
            Container(height: 20,),
            _mainActions(),
            Container(height: 10,),
            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _actionButton(FontAwesomeIcons.link, 'Link'),
                    _actionButton(FontAwesomeIcons.newspaper, 'Post'),
                    _actionButton(FontAwesomeIcons.question, 'Question'),
                  ],
                ),
              ),
            ),
            Container(height: 20,),
          ],
        ),
      ),
    );
  }

  _mainActions(){
    return Card(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
              child: Text('Improve your page', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
          ),
          Divider(),
          _improveItem(false, 'Add your first piece of content'),
          _improveItem(true, 'Invite your followers'),
          _improveItem(false, 'Add a custom icon'),
          _improveItem(false, 'Share your page to feed'),

        ],
      ),
    );
  }

  _improveItem(bool completed,  String title){
    return ListTile(
      leading: completed ?
        Icon(FontAwesomeIcons.checkCircle, color: Colors.blue,):
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all( color: Colors.grey[300]),
          ) ,
        ),
      title: Text(title, style: TextStyle(fontSize: 14),),
      trailing: Container(
        width: 24,
        height: 24,
        child: Icon(FontAwesomeIcons.chevronRight, color: Colors.grey[300],),
      ),
    );
  }

  _actionButton(IconData icon, String title){
    return RaisedButton(
      onPressed: (){},
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        side: BorderSide(color: Colors.blue)
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.blue, size: 20,),
          Container(width: 10, height: 0,),
          Text(title, style: TextStyle(color: Colors.blue),)
        ],
      ),
    );
  }
}
