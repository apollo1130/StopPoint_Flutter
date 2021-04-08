import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:video_app/auth/api/AuthApiService.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/widgets/TermAndPolicy.dart';

import '../../router.dart';

class RegisterWidget extends StatefulWidget {
  @override
  _RegisterWidgetState createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: FormBuilder(
            key: _fbKey,
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
                Text('You are close to accessing an infinite world of knowledge', style: TextStyle(fontSize: 22, color: Colors.grey[600]), textAlign: TextAlign.center,),
                Container(height: 80,),
                Material(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))
                  ),
                  child: FormBuilderTextField( 
                    name: 'firstname',
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20),
                      alignLabelWithHint: true,
                      hintText: 'Name',
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
                  child: FormBuilderTextField(
                    name: 'lastname',
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20),
                      alignLabelWithHint: true,
                      hintText: 'Lastname',
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
                  child: FormBuilderTextField(
                    maxLines: 1,
                    name: 'email',
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
                  child: FormBuilderTextField(
                    maxLines: 1,
                    name: 'password',
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
                      _register();
                    },
                    child: Text('Register', style: TextStyle(color: Colors.white, fontSize: 18),),
                  ),
                ),
                Container(height: 40,),
                TermsAndPolicy()
              ],
            ),
          ),
        ),
      ),
    );
  }


  _register () async {
    LocalStorage _storage = LocalStorage('mainStorage');
    User userResponse;
    if(await _storage.ready) {
      if (_fbKey.currentState.saveAndValidate()) {
        var form = _fbKey.currentState.value;
        form['loginType'] = 0;
        Response response = await AuthApiService().register(form);
        if (response.statusCode == 422) {
          Fluttertoast.showToast(
              msg: response.data,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        } else {
          userResponse = User.fromJson(response.data);
          _storage.setItem('authToken', userResponse.authToken);
          FlowRouter.router.navigateTo(context, 'splash');
        }

      }
    }




  }
}
