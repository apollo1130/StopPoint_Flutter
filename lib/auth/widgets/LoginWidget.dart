import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
//import 'package:overlay_support/overlay_support.dart';
import 'package:video_app/auth/api/AuthApiService.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/widgets/TermAndPolicy.dart';
import 'package:video_app/router.dart';


class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  LocalStorage _storage = LocalStorage('mainStorage');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            FlowRouter.router.pop(context);
          },
          child: Container(
            child: Icon(FontAwesomeIcons.chevronLeft),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _storage.ready,
        builder:  (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.data == true) {
            return  SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[

                    Container(height: 20,),
                    RichText(
                      text: TextSpan(
                          style: TextStyle(fontSize: 70, fontFamily: 'Mermaid', color: Colors.blue[400]),
                          text: 'V',
                          children: [
                            TextSpan(
                                text: 'app',
                                style: TextStyle(fontSize: 50, fontFamily: 'Helvetica Neue', color: Colors.black)
                            )
                          ]
                      ),
                    ),
                    Container(height: 20,),
                    Text('Sign In for access to a world of knowledge in a fun way', style: TextStyle(fontSize: 22, color: Colors.grey[600]), textAlign: TextAlign.center,),
                    Container(height: 80,),
                    Material(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50))
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 20),
                          alignLabelWithHint: true,
                          hintText: 'Email',
                          filled: true,
                          fillColor: Colors.white,
                          border:OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(color: Colors.transparent)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(color: Colors.transparent)
                          ),

                        ),
                      ),
                    ),
                    Container(height: 10,),
                    Material(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50))
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 20),
                          alignLabelWithHint: true,
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          border:OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(color: Colors.transparent)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(color: Colors.transparent)
                          ),

                        ),
                      ),
                    ),
                    Container(height: 40,),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50))
                        ),
                        color: Colors.blue,
                        onPressed: (){
                          _login();
                        },
                        child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 18),),
                      ),
                    ),
                    Container(height: 40,),
                    TermsAndPolicy()
                  ],
                ),
              ),
            );
          }else {
            return Container(color: Colors.white);
          }
        },
      ),
    );
  }

  _login() async {

    var body = {
      'email': _emailController.text,
      'password': _passwordController.text,
      'loginType':  0,
    };

    Response response =  await AuthApiService().login(body);
    if (response.statusCode == 422) {
      Fluttertoast.showToast(
          msg: 'The email or password is invalid',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else {
      User user = User.fromJson(response.data);
      _storage.setItem('authToken', user.authToken);
      FlowRouter.router.navigateTo(context, 'splash');
    }
  }
}
