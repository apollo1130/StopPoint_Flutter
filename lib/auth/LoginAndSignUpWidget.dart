import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:animated_background/animated_background.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:localstorage/localstorage.dart';
import 'package:video_app/auth/social/SocialService.dart';
import 'package:video_app/router.dart';
import '../core/widgets/TermAndPolicy.dart';
import '../router.dart';
import 'api/AuthApiService.dart';
import 'models/User.dart' as AppUser;
import 'package:url_launcher/url_launcher.dart';

class LoginAndSignUpWidget extends StatefulWidget {
  @override
  _LoginAndSignUpWidgetState createState() => _LoginAndSignUpWidgetState();
}

class _LoginAndSignUpWidgetState extends State<LoginAndSignUpWidget>
    with TickerProviderStateMixin {
  LocalStorage _storage = LocalStorage('mainStorage');
  bool _loading = false;
  SocialService _socialService = SocialService();
  // ignore: non_constant_identifier_names
  bool _appleLoginAvaiable = false;
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: Scaffold(
        body: FutureBuilder(
          future: _preloadFunctions(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == true) {
              return Stack(
                children: <Widget>[
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(color: Colors.blueGrey[900]),
                    ),
                  ),
                  AnimatedBackground(
                    behaviour: RandomParticleBehaviour(
                      options: ParticleOptions(
                          baseColor: Colors.blueAccent[200],
                          spawnMinSpeed: 3,
                          spawnMaxSpeed: 6.0,
                          particleCount: 30),
                    ),
                    vsync: this,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage(
                                          'lib/assets/images/logo_white.png'),
                                      width: MediaQuery.of(context).size.width / 4,
                                    ),
                                    Container(
                                      height: 10,
                                    ),
                                    Text(
                                      'Share your story with the world.',
                                      style: TextStyle(
                                          color: Colors.white60, fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                    Container(
                                      height: 40,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 40,
                                      child: GoogleSignInButton(
                                        centered: true,
                                        onPressed: () {
                                          print('Login Google');
                                          _socialService
                                              .signInWithGoogle()
                                              .then((User user) async {
                                            if (user != null) {
                                              _login(1, user);
                                            } else {
                                              print('Google login fail');
                                            }
                                          });
                                        },
                                        text: 'Continue with Google',
                                      ),
                                    ),
                                    Container(
                                      height: 10,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 40,
                                      child: FacebookSignInButton(
                                        centered: true,

                                        onPressed: () {
                                          _socialService
                                              .signInWithFacebook()
                                              .then((User user) async {
                                            if (user != null) {
                                              _login(2, user);
                                            } else {
                                              print('Facebook login error');
                                            }
                                          });
                                        },
                                        text: 'Continue with Facebook',
                                      ),
                                    ),
                                    Container(
                                      height: 10,
                                    ),

                                    Platform.isIOS
                                        ?  Container(
                                      width: double.infinity,
                                      height: 40,
                                      child: AppleSignInButton(
                                        centered: true,
                                        style: AppleButtonStyle.white,
                                        onPressed: () async {
                                          _socialService.appleSignIn().then(
                                                  (User user) async {
                                                if (user != null) {
                                                  print('apple login');
                                                  _login(3, user);
                                                } else {
                                                  print('apple login error');
                                                }
                                              });
                                        },
                                        text: 'Continue with Apple',
                                      ),
                                    )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                                SizedBox(height: 15,),
                                TermsAndPolicy()
                                // Column(
                                //   children: [
                                //     SizedBox(height: 20),
                                //     InkWell(
                                //       child: Text(
                                //         'PRIVACY POLICY',
                                //         style: TextStyle(
                                //             color: Colors.white60, fontSize: 18),
                                //         textAlign: TextAlign.center,
                                //       ),
                                //       onTap: (){
                                //           _launchURL('https://stoppoint.com/privacy.html');
                                //       },
                                //     ),
                                //     Container(
                                //       height: 10,
                                //     ),
                                //     InkWell(
                                //       child: Text(
                                //         'TERMS OF SERVICE',
                                //         style: TextStyle(
                                //             color: Colors.white60, fontSize: 18),
                                //         textAlign: TextAlign.center,
                                //       ),
                                //       onTap: (){
                                //         _launchURL('https://stoppoint.com/terms.html');
                                //       },
                                //     ),
                                //     Container(
                                //       height: 10,
                                //     ),
                                //     InkWell(
                                //       child: Text(
                                //         'LICENSE AGREEMENT',
                                //         style: TextStyle(
                                //             color: Colors.white60, fontSize: 18),
                                //         textAlign: TextAlign.center,
                                //       ),
                                //       onTap: (){
                                //         _launchURL('https://stoppoint.com/licenseagreement.html');
                                //       },
                                //     ),
                                //   ],
                                // )
                              ],
                            ),
                          ),
                        ),
                      ),
//          decoration: BoxDecoration(
//            image: DecorationImage(
//              image: AssetImage('lib/assets/images/loginBackground.jpg'),
//              fit: BoxFit.cover
//            )
//          ),
                    ),
                  )
                ],
              );
            } else {
              return Container(
                color: Colors.white,
              );
            }
          },
        ),
      ),
      isLoading: _loading,
      color: Colors.black,
      opacity: 0.8,
    );
  }

  _launchURL(String url) async {
    //const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchUrl(String url) async {
    print('launch');
  }
  _login(int type, User user) async {
    AppUser.User userResponse;
    String typeString = _stringKeyFromType(type);
    var body = {
      'email': user.providerData[0].email,
      'loginType': type,
      typeString: user.uid,
      'pushToken': _storage.getItem('pushToken'),
    };

    print("body =========================");
    print(body);
    print("body =========================2");

    setState(() {
      _loading = true;
    });
    var response = await AuthApiService().login(body);

    if(response != null){
      if (response.statusCode == 423) {
        var registerBody;
//      registerBody = {
//        'loginType': type,
//        'firstname': user.displayName != null ? user.displayName : user.email.split('@')[0],
//        'email': user.providerData[0].email,
//        typeString: user.uid,
//        'avatar': user.photoURL,
//        'password': 'no password'
//      };

        registerBody = {
          'loginType': type,
          'firstname': user.displayName,
          'email': user.providerData[0].email,
          typeString: user.uid,
          'avatar': user.photoURL,
          'password': 'no password'
        };

        Response registerResponse = await AuthApiService().register(registerBody);
        if (registerResponse.statusCode == 422) {
          Fluttertoast.showToast(
              msg:
              'The email was taken, please recover your password or notify to admin',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          print("=====================");
          print(registerResponse.data);
          print("=====================");
          userResponse = AppUser.User.fromJson(registerResponse.data);
          _storage.setItem('authToken', userResponse.authToken);
        }
      } else {
        print("=====================");
        print(response.data);
        print("=====================");
        userResponse = AppUser.User.fromJson(response.data);
        _storage.setItem('authToken', userResponse.authToken);
      }
    }

    setState(() {
      _loading = false;
      FlowRouter.router.navigateTo(context, 'splash', replace: true);
    });
  }

  String _stringKeyFromType(int type) {
    var result;

    switch (type) {
      case 1:
        result = 'googleId';
        break;
      case 2:
        result = 'facebookId';
        break;
      case 3:
        result = 'appleId';
        break;
    }
    return result;
  }

  Future<dynamic> _preloadFunctions() async {
    await _storage.ready;
    _appleLoginAvaiable = await _socialService.appleSignInAvailable;
    return true;
  }
}
