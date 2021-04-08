import 'dart:math';
import 'dart:ui';
import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:video_app/inbox/widgets/directMessages/Conversation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/widgets/BottomNavigationMenu.dart';
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/widgets/tabs/AnswersTabWidget.dart';
import 'package:video_app/profile/widgets/tabs/FollowersTabWidget.dart';
import 'package:video_app/profile/widgets/tabs/FollowingTabWidget.dart';
import 'package:video_app/profile/widgets/tabs/QuestionsTabWidget.dart';
import 'package:video_app/questions/ask/AskQuestionWidget.dart';
import 'package:localstorage/localstorage.dart';

import 'UserBlocked.dart';
class AnotherUserProfileWidget extends StatefulWidget {
  final String userId;
  AnotherUserProfileWidget({this.userId});
  @override
  _AnotherUserProfileWidgetState createState() =>
      _AnotherUserProfileWidgetState();
}

class _AnotherUserProfileWidgetState extends State<AnotherUserProfileWidget> {
  int actualPage = 0;
  ScrollController _controller;
  bool expanded = true;
  User _user;
  double headerHeight;
  bool tabsInfoLoaded = false;
  Future _getUserProfile;
  User _userLogged;


  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getUserProfile = _getUserProfileDb(widget.userId);
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    headerHeight = MediaQuery.of(context).size.height / 1.6;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(icon: Icon(Icons.more_vert), onPressed: (){
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoActionSheet(
                      actions: [
                        _blockUserButton()
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                    );
                  }
              );

            })
          ],
        ),
        body: FutureBuilder(
          future: _getUserProfile,
          builder: (BuildContext context, snapshot) {
            if (snapshot.data != null) {
              return _mainBuild(context);
            } else {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
        bottomNavigationBar: BottomNavigationMenu(
            iconColor: Color(0xff252525), backgroundColor: Colors.white),
      ),
    );
  }

  _mainBuild(BuildContext context) {
    return NestedScrollView(
        controller: _controller,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _header(context),
            ),
            SliverPersistentHeader(
                delegate: MyDelegate(TabBar(
                  isScrollable: false,
                  tabs: <Widget>[
                    _tabStyle(_user.questionsAnswered.length, 'Answers'),
                    _tabStyle(_user.questionsAsked.length, 'Questions'),
                    // _tabStyle(_user.questionsShared.length, 'Shares'),
                    // _tabStyle(_user.followers.length, 'Followers'),
                    // _tabStyle(_user.following.length, 'Following'),
                  ],
                  indicatorColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  labelColor: Colors.black,
                )))
          ];
        },
        body: Builder(
          builder: (context) {
            bool iFollow = _getFollowInformation(_user.id);
            if (_user.privateProfile && !iFollow) {
              return Container(
                  height: 20,
                  width: 40,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Icon(
                        Icons.lock,
                        size: 100,
                      ),
                      Text(
                        'Account is Private',
                      ),
                    ],
                  ));
            } else {
              return Container(
                  child: tabsInfoLoaded ?TabBarView(
                    children: <Widget>[
                      _user.questionsAnswered.length == 0 ?
                      NoContent(text: 'No answers yet',):
                      AnswersTabWidget(questions: _user.questionsAnswered, isUserLogged:false ),
                      _user.questionsAsked.length == 0 ?
                      NoContent(text: 'No questions asked yet',):
                      QuestionsTabWidget(questions: _user.questionsAsked, isUserLogged: false, isComefromAnotherProfile: true, ),
                      // Builder(builder: (context) {
                      //   if (_user.questionsShared.length == 0) {
                      //     return NoContent(
                      //       text: 'No questions shared yet',
                      //     );
                      //   } else {
                      //     return QuestionsSharedTabWidget(
                      //       questions: _user.questionsShared,
                      //     );
                      //   }
                      // }),

                      // _user.followers.length == 0 ?
                      // NoContent(text: 'No followers yet',):
                      // FollowersTabWidget(member: _user,fromanotherprofile: true,),
                      // _user.following.length == 0 ?
                      // NoContent( text: 'No one is following yet'):
                      // FollowingTabWidget(member: _user,currentUserProfile: false,)
                    ],
                  ): Center(child: CircularProgressIndicator(),)) ;
            }
          },
        ));
  }

  // TODO: Header Data
  _header(BuildContext context) {
    return SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 0,
              ),
              // Container(
              //   alignment: Alignment.topLeft,
              //   child: GestureDetector(
              //     onTap: () {
              //       Navigator.pop(context);
              //     },
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Icon(
              //             Icons.arrow_back,
              //             //Icons.keyboard_backspace,
              //             //color: Colors.black,
              //             //size: 25,
              //           ),
              //         ),
              //         IconButton(icon: Icon(Icons.more_vert), onPressed: (){
              //           showCupertinoModalPopup(
              //               context: context,
              //               builder: (BuildContext context) {
              //                 return CupertinoActionSheet(
              //                   actions: [
              //                     _blockUserButton()
              //                   ],
              //                   cancelButton: CupertinoActionSheetAction(
              //                     onPressed: (){
              //                       Navigator.pop(context);
              //                     },
              //                     child: Text('Cancel'),
              //                   ),
              //                 );
              //               }
              //           );
              //
              //         })
              //       ],
              //     ),
              //   ),
              // ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: _user.avatarImageProvider() ?? '',
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: _basicUserInformation(),
                      ),
                      InkWell(
                        child: Column(
                          children: [
                            Text(_user.followers.length.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                            Text('Follower',style: TextStyle(color: Colors.grey))
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            tabsInfoLoaded = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (BuildContext context) => FollowersTabWidget(member: _user, fromanotherprofile: false,isPrivateAccount: true),),);
                        },
                      ),
                      SizedBox(width: 15.0),
                      InkWell(
                        child: Column(
                          children: [
                            Text(_user.following.length.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                            Text('Following',style: TextStyle(color: Colors.grey))
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            tabsInfoLoaded = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (BuildContext context) => FollowingTabWidget(member: _user, currentUserProfile: true,isPrivateAccount: true),),);
                        },
                      ),
                      SizedBox(width: 10.0),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 0.0,
              ),
              Container(
                child: _credentialInformation(),
              ),
            ],
          ),
        ));
  }

  // TODO: Private Tabs
  _checkPrivateTabBar() {
    if (_user.privateProfile == false) {
      return TabBar(
        isScrollable: true,
        tabs: <Widget>[
          _tabStyle(_user.questionsAnswered.length, 'Answers'),
          _tabStyle(_user.questionsAsked.length, 'Questions'),
          _tabStyle(_user.questionsShared.length, 'Shares'),
          _tabStyle(_user.followers.length, 'Followers'),
          _tabStyle(_user.following.length, 'Following'),
        ],
      );
    } else {
      return null;
    }
  }

  // TODO: User Information
  _basicUserInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _user.getFullName(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(
          height: 0.0,
        ),
        Text(
          StringUtils.defaultString(_user.job),
          style: TextStyle(
            fontSize: 12.0,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // TODO: User Bio
  _bioSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300], width: 8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 10.0,
            ),
            child: Text(
              "Bio",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
          Divider(),
          Container(
            child: Text(
              StringUtils.defaultString(_user.bio),
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
          ),
        ],
      ),
    );
  }

  // TODO: User Credentials
  _credentialInformation() {
    bool iFollow = _getFollowInformation(_user.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Padding(
        //   padding: EdgeInsets.only(bottom: 10, left: 10.0, right: 10.0),
        //   child: Container(
        //     child: ReadMoreText(
        //       StringUtils.defaultString(_user.bio),
        //       trimLines: 5,
        //       colorClickableText: Colors.blue,
        //       trimMode: TrimMode.Line,
        //       trimCollapsedText: '...Read more',
        //       trimExpandedText: ' Read less',
        //       style: TextStyle(
        //         fontSize: 14.0,
        //       ),
        //     ),
        //   ),
        // ),
        SizedBox(
          height: 0,
        ),
        Container(
          // decoration: BoxDecoration(
          //   border: Border(
          //     bottom: BorderSide(color: Colors.grey[300], width: 8),
          //   ),
          // ),
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Builder(builder: (context) {
              bool iFollow = _getFollowInformation(_user.id);
              print(iFollow);
              if (_user.privateProfile && !iFollow) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(child: _followButton()),
                    Container(
                      width: 5,
                    ),
                    Expanded(
                      child: RaisedButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  AskQuestionWidget(
                                    userToAsk: _user,
                                  ),
                            ),
                          );
                        },
                        child: Text('Ask'),
                      ),
                    )
                  ],
                );
              } else if (iFollow){
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(child: _followButton()),
                    Container(
                      width: 5,
                    ),
                    Expanded(
                      child: RaisedButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Conversation(_user.id)),
                          );
                        },
                        child: Text('Message'),
                      ),
                    ),
                    Container(
                      width: 5,
                    ),
                    Expanded(
                      child: RaisedButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  AskQuestionWidget(
                                    userToAsk: _user,
                                  ),
                            ),
                          );
                        },
                        child: Text('Ask'),
                      ),
                    )
                  ],
                );
              }else{
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(child: _followButton()),
                    Container(
                      width: 5,
                    ),
                    // Expanded(
                    //   child: RaisedButton(
                    //     color: Colors.white,
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => Conversation(_user.id)),
                    //       );
                    //     },
                    //     child: Text('Message'),
                    //   ),
                    // ),
                    Container(
                      width: 5,
                    ),
                    Expanded(
                      child: RaisedButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  AskQuestionWidget(
                                    userToAsk: _user,
                                  ),
                            ),
                          );
                        },
                        child: Text('Ask'),
                      ),
                    )
                  ],
                );
              }
            }),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10, left: 10.0, right: 10.0,top:0),
          child: Container(
            child: ReadMoreText(
              StringUtils.defaultString(_user.bio),
              trimLines: 5,
              colorClickableText: Colors.blue,
              trimMode: TrimMode.Line,
              trimCollapsedText: '...Read more',
              trimExpandedText: ' Read less',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
        ),
        Container(
            height: 10,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300], width: 8),
              ),
            )),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300], width: 8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3.0,
                  horizontal: 10.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top:5.0),
                  child: Text(
                    "Credentials & Highlights",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
              Divider(),
              _credentialRow(FlutterIcons.briefcase_medical_faw5s,
                  StringUtils.defaultString(_user.job)),
              _credentialRow(FontAwesomeIcons.graduationCap,
                  StringUtils.defaultString(_user.education)),
              _credentialRow(FontAwesomeIcons.mapMarkerAlt,
                  StringUtils.defaultString(_user.live)),
            ],
          ),
        )
      ],
    );
  }

  // TODO: User Credentials
  _credentialRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 10.0, right: 0.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 14.0,
            color: Colors.grey[600],
          ),
          Container(
            width: 14,
          ),
          Expanded(child: Builder(builder: (context) {
            if (text == '') {
              return GestureDetector(
                child: Text(
                  'No information available yet',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }
            else {
              return Text(
                icon == FontAwesomeIcons.mapMarkedAlt ? "Lives in $text" : text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              );
            }
          }))
        ],
      ),
    );
  }

  // TODO: Tab Style
  _tabStyle(int quantity, String tabName) {
    return Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "${quantity.toString()} $tabName",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ));
  }

  // TODO: Scroll Listerner
  _scrollListener() {
    if (_controller.offset > (MediaQuery.of(context).size.height / 1.6) &&
        expanded) {
      setState(() {
        expanded = false;
      });
    } else if (_controller.offset <=
        (MediaQuery.of(context).size.height / 1.6) &&
        !expanded) {
      setState(() {
        expanded = true;
      });
    }
  }

  // TODO: Get User Profile
  _getUserProfileDb(userId) async {
    LocalStorage _storage = LocalStorage('mainStorage');
    if (!tabsInfoLoaded) {
      if (await _storage.ready) {
        String authToken = _storage.getItem('authToken');
        Response response = await ProfileApiService(token: authToken).getProfile(userId);
        if (response.statusCode == 200) {
          try {
            _user = User.fromJson(response.data);
            setState(() {
              tabsInfoLoaded = true;
            });
          } catch (e) {
            print(e);
          }
        } else if(response.statusCode == 409 ) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (BuildContext context) {
                    return UserBlocked();
                  }
              )
          );
        } else {
          Fluttertoast.showToast(
              msg: 'ERROR: Cannot fetch userProfile',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    }
    return true;
  }

  // TODO: Follow Profile
  _follow() async {
    Response response =
    await ProfileApiService().follow(_userLogged.id, _user.id);

    if (response.statusCode == 200) {
      _userLogged.following.add(User.fromJson(response.data));
      _user.followers.add(_userLogged);
      setState(() {});
    } else if (response.statusCode == 209) {
      Fluttertoast.showToast(
          msg: 'Request Sent',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: 'Error following the user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  // TODO: UnFollow Profile
  _unFollow() async {
    Response response =
    await ProfileApiService().unfollow(_userLogged.id, _user.id);
    if (response.statusCode == 200) {
      int index =
      _userLogged.following.indexWhere((element) => element.id == _user.id);
      _userLogged.following.removeAt(index);

      int indexLogged =
      _user.followers.indexWhere((element) => element.id == _userLogged.id);
      _user.followers.removeAt(indexLogged);
      setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: 'Error stopping following the user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  // TODO: Follow Button
  _followButton() {
    bool iFollow = _getFollowInformation(_user.id);
    if (iFollow) {
      return RaisedButton(
          color: Colors.white,
          onPressed: () {
            _unFollow();
            // _showProfileActionSheet();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Following ',
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
              // Expanded(child: Padding(
              //   padding: EdgeInsets.only(top: 3),
              //   child: Icon(Icons.arrow_drop_down,size: 15,color: Colors.black,),
              // ))
            ],
          )
      );
    } else {
      return RaisedButton(
        color: Colors.blue,
        onPressed: () {
          _follow();
          // showCupertinoModalPopup(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return CupertinoActionSheet(
          //         actions: [
          //           CupertinoActionSheetAction(
          //             onPressed: (){
          //               _follow();
          //             },
          //             child: Text('Follow'),
          //           ),
          //           CupertinoActionSheetAction(
          //               onPressed: (){
          //                 _blockUser();
          //               },
          //               child: Text('Block')
          //           )
          //         ],
          //         cancelButton: CupertinoActionSheetAction(
          //           onPressed: (){
          //             Navigator.pop(context);
          //           },
          //           child: Text('Cancel'),
          //         ),
          //       );
          //     }
          // );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Follow',
              style: TextStyle(color: Colors.white),textAlign: TextAlign.center,
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 3),
            //   child: Container(child: Icon(Icons.arrow_drop_down,size: 20,color: Colors.white,)),
            // )
          ],
        ),
      );
    }
  }

  // TODO: Get Follow Information
  _getFollowInformation(String userId) {
    bool result = false;
    _userLogged.following.forEach((element) {
      if (element.id == userId) {
        result = true;
      }
    });
    return result;
  }

  // TODO: Profile Actions
  _showProfileActionSheet () {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            actions: [
              // CupertinoActionSheetAction(
              //   onPressed: (){
              //     _unFollow();
              //   },
              //   child: Text('Unfollow'),
              // ),
              CupertinoActionSheetAction(
                  onPressed: (){
                    _blockUser();
                  },
                  child: Text('Block')
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          );
        }
    );

  }

  // TODO: Can't Message
  _cantmessage() async {
    var result = await showDialog(
      context: context,
      builder:(context) => AlertDialog(
          title: Text(
            'follow to text',
            textAlign: TextAlign.center,
          )),
    );
    if (result) {}
  }

  // TODO: Block User
  _blockUser() async {
    Response response = await ProfileApiService().blockUser(_userLogged.id, _user.id);

    if(response.statusCode == 200) {
      int index = _userLogged.following.indexWhere((element) => element.id == _user.id);
      if (index >= 0) {
        _userLogged.following.removeAt(index);
      }
      int indexFollowers = _userLogged.followers.indexWhere((element) => element.id == _user.id);
      if (indexFollowers >= 0) {
        _userLogged.followers.removeAt(indexFollowers);
      }
      int indexLogged = _user.followers.indexWhere((element) => element.id == _userLogged.id);
      if(indexLogged >= 0) {
        _user.followers.removeAt(indexLogged);
      }
      int indexLoggedFollowing = _user.followers.indexWhere((element) => element.id == _userLogged.id);
      if (indexLoggedFollowing >= 0) {
        _user.following.removeAt(indexLoggedFollowing);
      }
      this._userLogged.blockedUsers.add(_user);
      Navigator.pop(context);
    }
  }

  _unblockUser() async {
    Response response = await ProfileApiService().unblockUser(_userLogged.id, _user.id);

    Navigator.pop(context);
    if(response.statusCode == 200) {
      this._userLogged.blockedUsers.removeWhere((element) => element.id == _user.id);
    } else {
      Fluttertoast.showToast(
          msg: 'ERROR: Cannot unblock user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  _blockUserButton () {
    bool iBlocked = _userLogged.blockedUsers.any((element) => element.id == _user.id);

    if (iBlocked) {
      return    CupertinoActionSheetAction(
          onPressed: (){
            _unblockUser();
          },
          child: Text('Unblock')
      );
    }else {
      return    CupertinoActionSheetAction(
          onPressed: (){
            _blockUser();
          },
          child: Text('Block')
      );
    }

  }
}

class MyDelegate extends SliverPersistentHeaderDelegate {
  MyDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class NoContent extends StatelessWidget {
  NoContent({this.text});
  String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          Icon(
            Icons.hourglass_empty,
            size: 150,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
