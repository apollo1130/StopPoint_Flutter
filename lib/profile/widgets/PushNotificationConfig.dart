import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/api/AuthApiService.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/providers/UserProvider.dart';

class PushNotificationConfig extends StatefulWidget {
  @override
  _PushNotificationConfigState createState() => _PushNotificationConfigState();
}

class _PushNotificationConfigState extends State<PushNotificationConfig> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  User _user;

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<UserProvider>(context, listen:false).userLogged;
    return Scaffold(
      appBar: AppBar(
        title: Text('Push Notifications'),
        actions: [
          FlatButton(
            onPressed: () {
              _saveConfig();
            },
            child: Text('Save'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _fbKey,
          initialValue: {
            'followNotification': _user.followNotification,
            'questionForYouNotification': _user.questionForYouNotification,
            'directMessagesNotification': _user.directMessagesNotification,
            'likeNotification': _user.likeNotification,
            'commentNotification': _user.commentNotification,
            'answerNotification': _user.answerNotification,
            'interestQuestionNotification': _user.interestQuestionNotification,
          },
          child: Container(
            child:Column(
              children: [
                _titleRow('Related with you'),
                Container(height: 2, color: Colors.grey[200],),
                FormBuilderSwitch(
                  name: 'followNotification',
                  decoration: InputDecoration(border: InputBorder.none),
                  onChanged: (value){
                    print(value);
                  },
                  title: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          'Follow requests',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                Container(height: 1, color: Colors.grey[200],),
                FormBuilderSwitch(
                  name: 'questionForYouNotification',
                  decoration: InputDecoration(border: InputBorder.none),
                  onChanged: (value){
                    print(value);
                  },
                  title: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          'Question for you',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                Container(height: 1, color: Colors.grey[200],),
                FormBuilderSwitch(
                  name: 'directMessagesNotification',
                  decoration: InputDecoration(border: InputBorder.none),
                  onChanged: (value){
                    print(value);
                  },
                  title: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          'Direct messages',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                Container(height: 2, color: Colors.grey[200],),
                _titleRow('Related with you questions'),
                Container(height: 2, color: Colors.grey[200],),
                FormBuilderSwitch(
                  name: 'likeNotification',
                  decoration: InputDecoration(border: InputBorder.none),
                  onChanged: (value){
                    print(value);
                  },
                  title: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          'Like',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                Container(height: 1, color: Colors.grey[200],),
                FormBuilderSwitch(
                  name: 'commentNotification',
                  decoration: InputDecoration(border: InputBorder.none),
                  onChanged: (value){
                    print(value);
                  },
                  title: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          'Comment',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                Container(height: 1, color: Colors.grey[200],),
                FormBuilderSwitch(
                  name: 'answerNotification',
                  decoration: InputDecoration(border: InputBorder.none),
                  onChanged: (value){
                    print(value);
                  },
                  title: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          'Answer',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                Container(height: 2, color: Colors.grey[200],),
                _titleRow('Topics'),
                Container(height: 2, color: Colors.grey[200],),
                FormBuilderSwitch(
                  name: 'interestQuestionNotification',
                  decoration: InputDecoration(border: InputBorder.none),
                  onChanged: (value){
                    print(value);
                  },
                  title: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          'Interest questions',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                Container(height: 1, color: Colors.grey[200],),

              ],
            ),
          ),
        ),
      ),
    );
  }

  _titleRow(String text) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Color(0xffF4F8FB),
      child: Text(
        text,
        style: TextStyle(
            color: Color(0xff5F6C7C), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  _saveConfig () async  {

    if (_fbKey.currentState.saveAndValidate()) {
      var values = _fbKey.currentState.value;
      values.removeWhere((key, value) {
        if (value is bool || value.length > 1) {
          return false;
        } else {
          return true;
        }
      });

      Response response = await AuthApiService().updateUser(values, _user.id);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: 'Push configuration saved',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        Provider.of<UserProvider>(context, listen: false)
            .userLogged
            .updateUser(User.fromJson(response.data));
        await Future.delayed(Duration(milliseconds: 1000));
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: 'Error on save',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }
}
