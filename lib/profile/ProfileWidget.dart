import 'dart:ui';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_app/auth/api/AuthApiService.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:readmore/readmore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:video_app/core/utils/JwtHelper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/widgets/BottomNavigationMenu.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/widgets/EditProfile.dart';
import 'package:video_app/profile/widgets/tabs/AnswersTabWidget.dart';
import 'package:video_app/profile/widgets/tabs/FollowersTabWidget.dart';
import 'package:video_app/profile/widgets/tabs/FollowingTabWidget.dart';
import 'package:video_app/profile/widgets/tabs/QuestionsTabWidget.dart';
import 'package:dio/dio.dart';

class ProfileWidget extends StatefulWidget {
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  int actualPage = 0;
  bool expanded = true;
  TabController _tabController;
  UserProvider _userProvider;
  User _user;
  double headerHeight;
  bool tabsInfoLoaded = false;
  int currentIndex = 0;
  bool routedPushed = false;
  LocalStorage _storage = LocalStorage('mainStorage');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    headerHeight = MediaQuery.of(context).size.height * 0.58;
    _user = Provider.of<UserProvider>(context, listen: true).userLogged;
    _onRefresh();
    return _main();
  }

  _main() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          //backgroundColor: Colors.white,
          // title: _basicUserInformation(),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => EditProfile(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 0.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        size: 20.0,
                        color: Colors.black,
                      ),
                      // SizedBox(
                      //   width: 5.0,
                      // ),
                      // Text(
                      //   "Edit Profile",
                      //   style: TextStyle(fontSize: 16.0),
                      // ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        body: SafeArea(
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: _header(),
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
                  ))),
                ];
              },
              body: Container(
                  // child: tabsInfoLoaded ?
                  child: TabBarView(
                children: <Widget>[
                  _user.questionsAnswered.length == 0
                      ? NoContent(
                          icon: Icons.video_collection_outlined,
                          text: 'No questions answered yet',
                        )
                      : AnswersTabWidget(
                          questions: _user.questionsAnswered,
                          isUserLogged: false,
                          routedPushed: routedPushed,
                        ),
                  _user.questionsAsked.length == 0
                      ? NoContent(
                          icon: Icons.video_collection_outlined,
                          text: 'No questions asked yet',
                        )
                      : QuestionsTabWidget(
                          questions: _user.questionsAsked,
                          isUserLogged: true,
                          isComefromAnotherProfile: false,
                        ),

                  // _user.followers.length == 0 ?
                  // NoContent(text: 'No followers yet',
                  //   icon: Icons.supervisor_account,) :
                  // FollowersTabWidget(
                  //   member: _user, fromanotherprofile: false,),
                  // _user.following.length == 0 ?
                  // NoContent(icon: Icons.supervisor_account,
                  //     text: 'No one is following yet') :
                  // FollowingTabWidget(
                  //   member: _user, currentUserProfile: true,)

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
                ],
              )
                  // : Center(child: CircularProgressIndicator(),

                  )),
        ),
        bottomNavigationBar: BottomNavigationMenu(
          iconColor: Color(0xff252525),
          backgroundColor: Color(0xffFAFAFA),
          selectedIconColor: Color(0xFF3982f3),
          currentIndex: 4,
          routedPushed: (route) {
            setState(() {
              routedPushed = route;
            });
          },
        ),
      ),
    );
  }

  _header() {
    return SafeArea(
        child: Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Container(
              child: Row(
                children: [
                  Container(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: _user.avatarImageProvider(),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: _basicUserInformation(),
                  ),
                  // SizedBox(height: 10),
                  // _basicUserInformation()
                  // Expanded(
                  //   child: _basicUserInformation(),
                  // ),
                  InkWell(
                    child: Column(
                      children: [
                        Text(
                          _user.followers.length.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text('Follower', style: TextStyle(color: Colors.grey))
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        tabsInfoLoaded = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowersTabWidget(
                            member: _user,
                            fromanotherprofile: false,
                            isPrivateAccount: false,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 15.0),
                  InkWell(
                    child: Column(
                      children: [
                        Text(
                          _user.following.length.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text('Following', style: TextStyle(color: Colors.grey))
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        tabsInfoLoaded = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowingTabWidget(
                              member: _user,
                              currentUserProfile: true,
                              isPrivateAccount: false),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 10.0),
                ],
              ),
            ),
          ),
          Container(
            child: _credentialInformation(),
          ),
        ],
      ),
    ));
  }

  _basicUserInformation() {
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: <Widget>[
    //     userFirstname(),
    //     /*Text(
    //       StringUtils.capitalize(_user.firstname.trim(), allWords: true),
    //       style: TextStyle(
    //         fontWeight: FontWeight.bold,
    //         fontSize: 17,
    //         color: Colors.black,
    //       ),
    //     ),*/
    //     SizedBox(
    //       height: 0.0,
    //     ),
    //   ],
    // );
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

  _credentialInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
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
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (BuildContext context) => EditProfile(),
              //       ),
              //     );
              //   },
              //   child: Container(
              //     padding: EdgeInsets.symmetric(vertical: 0.0),
              //     child: Row(
              //       children: [
              //         Icon(
              //           Icons.edit,
              //           size: 15.0,
              //           color: Colors.black,
              //         ),
              //         SizedBox(
              //           width: 5.0,
              //         ),
              //         Text(
              //           "Edit Profile",
              //           style: TextStyle(fontSize: 16.0),
              //         ),
              //       ],
              //     ),
              //   ),
              // )
            ],
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300], width: 8),
            ),
          ),
          padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300], width: 8),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 0, top: 10, bottom: 0),
                //vertical: 10.0,
                //horizontal: 10.0,
                //),
                child: Text(
                  "Credentials & Highlights",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
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

  userFirstname() {
    try {
      return Text(
        StringUtils.capitalize(_user.firstname.trim(), allWords: true),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: Colors.black,
        ),
      );
    } catch (e) {
      print("the email :" + _user.email);
      return Text(
        StringUtils.capitalize(_user.email, allWords: true),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: Colors.black,
        ),
      );
    }
  }

  _tabStyle(int quantity, String tabName) {
    return Tab(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          quantity.toString() + " " + tabName,
          style: TextStyle(color: Colors.black),
        ),
      ],
    ));
  }

  _credentialRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 10.0, right: 10.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 14.0,
            color: Colors.grey[600],
          ),
          Container(
            width: 15,
          ),
          Expanded(child: Builder(builder: (context) {
            if (text == '') {
              return GestureDetector(
                child: Text(
                  'Add credentials',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => EditProfile(),
                    ),
                  );
                },
              );
            } else {
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

  Future<void> _onRefresh() async {
    // monitor network fetch
    await reloadUser();
    setState(() {});
    // if failed,use refreshFailed()
    // _refreshController.refreshCompleted();
  }

  Future<User> reloadUser() async {
    // if (!tabsInfoLoaded) {
    if (await _storage.ready) {
      String authToken = _storage.getItem("authToken");
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      Response response = await AuthApiService(token: authToken)
          .getProfile(_userProvider.userLogged.id);
      _userProvider.userLogged = User.fromJson(response.data);
      // print(User.fromJson(response.data));
      // setState(() {
      //   tabsInfoLoaded = true;
      // });
    }

    return _userProvider.userLogged;
    // }
  }
}

class NoContent extends StatelessWidget {
  NoContent({this.text, this.icon});

  String text;
  IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          Icon(
            icon,
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
