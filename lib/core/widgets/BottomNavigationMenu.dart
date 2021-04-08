import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/widgets/ProfileAppbarPic.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/Widgets/CameraWidget.dart';
import 'package:video_app/questions/ask/AskQuestionFast.dart';
import 'package:video_app/router.dart';
import 'package:video_app/videoQuestion/AddVideo.dart';

class BottomNavigationMenu extends StatefulWidget {
  final iconColor;
  final backgroundColor;
  final selectedIconColor;
  final currentIndex;
  RoutedPushed routedPushed;

  BottomNavigationMenu(
      {this.iconColor,
      this.backgroundColor,
      this.selectedIconColor,
      this.currentIndex,
      this.routedPushed});

  @override
  _BottomNavigationMenuState createState() => _BottomNavigationMenuState();
}

class _BottomNavigationMenuState extends State<BottomNavigationMenu> {
  User _userLogged;
  bool hasNotification = false;

  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context).userLogged;
    hasNotification = _userLogged.directMessagesNotification ||
        _userLogged.questionForYouNotification ||
        _userLogged.interestQuestionNotification;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: (widget.selectedIconColor == null)
          ? widget.iconColor
          : widget.selectedIconColor,
      unselectedItemColor: widget.iconColor,
      backgroundColor: widget.backgroundColor,
      currentIndex: (widget.currentIndex == null) ? 4 : widget.currentIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedFontSize: 0,
      unselectedFontSize: 0,
      items: [
        _navigationItem('Feed', Icons.video_library, 0),
        // _navigationItem('Search', FontAwesomeIcons.search),
        _navigationItem('Search', FlutterIcons.search_fea, 1),
        _navigationItem('Questions', FlutterIcons.help_circle_fea, 2),
        _navigationItem('Chat', FlutterIcons.bell_fea, 3),
        _navigationItem('Profile', FlutterIcons.user_ant, 4),
      ],
      onTap: (index) {
        setState(() {
        });
        _navigationOptions(index);
      },
    );
  }

  BottomNavigationBarItem _navigationItem(
      String label, IconData data, int index) {
    switch (index) {
      case 0:
        return BottomNavigationBarItem(
            icon: Icon(data, size: (data == Icons.help) ? 30 : 24),
            label: label);
        break;
      case 1:
        return BottomNavigationBarItem(
            icon: Icon(data, size: (data == Icons.help) ? 30 : 24),
            label: label);
        //FluroRouter.router.navigateTo(context, 'home', replace: true);
        break;
      case 2:
        return BottomNavigationBarItem(
            icon: Transform.translate(
              offset: Offset(0, 0),
              child: Container(
                height: 40,
                width: 40,
                child: FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () async {
                    showModalBottomSheet<void>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.white,
                        context: context,
                        builder: (BuildContext context) {
                          return new Container(
                              height: 200.0,
                              child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: new EdgeInsets.only(
                                            top: 20,
                                            left: 13,
                                            bottom: 10,
                                            right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Create",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                letterSpacing: 0,
                                                wordSpacing: 0,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            InkWell(
                                                child: Icon(Icons.close,
                                                    color: Colors.black87),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                }),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                          onTap: () async {
                                            setState(() {
                                            });
                                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                                CameraWidget()), (Route<dynamic> route) => true);
                                            /*await Navigator.push(context,
                                                MaterialPageRoute(builder:
                                                    (BuildContext context,) {
                                              return Addvideo();
                                            }));*/
                                          },
                                          child: Container(
                                            margin: new EdgeInsets.only(
                                                top: 20,
                                                left: 13,
                                                bottom: 10,
                                                right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(Icons.upload_outlined,
                                                    color: Colors.black87),
                                                SizedBox(width: 10),
                                                Text(
                                                  "Upload a video",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    letterSpacing: 0,
                                                    wordSpacing: 0,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      InkWell(
                                        onTap: () async {

                                          setState(() {

                                          });
                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                              AskQuestionFast()), (Route<dynamic> route) => true);
                                          /*await Navigator.push(context,
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return AskQuestionFast();
                                          }));*/
                                        },
                                        child: Container(
                                            margin: new EdgeInsets.only(
                                                top: 20,
                                                left: 13,
                                                bottom: 10,
                                                right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(Icons.mic_none,
                                                    color: Colors.black87),
                                                SizedBox(width: 10),
                                                Text(
                                                  "Ask a question",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    letterSpacing: 0,
                                                    wordSpacing: 0,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  )
                              );
                        }
                        );
                  },
                ),
              ),
            ),
            label: label);
        break;
      case 3:
        return BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.topRight,
              children: _notifcationoptions(data),
            ),
            label: label);
        break;
      case 4:
        return BottomNavigationBarItem(
            icon: Container(width: 48, height: 48, child: ProfileAppbarPic()),
            label: label);
        break;
      default:
        return BottomNavigationBarItem(
            icon: Icon(data, size: (data == Icons.help) ? 30 : 24),
            label: label);
    }
  }

  List<Widget> _notifcationoptions(IconData data) {
    if (hasNotification == false) {
      return [Icon(data, size: (data == Icons.help) ? 30 : 24)];
    } else {
      return [
        Icon(data, size: (data == Icons.help) ? 30 : 24),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent,
          ),
          height: 10,
          width: 10,
        )
      ];
    }
  }

  /*_getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: IconThemeData(size: 18, color: Colors.white),
      backgroundColor: Colors.blueAccent,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
            child: Icon(
              Icons.edit_outlined,
              color: Colors.white,
            ),
            backgroundColor: Colors.blueAccent,

            onTap: () async {

              /*
              if (widget.routedPushed != null) widget.routedPushed(true);
              await Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return AskQuestionFast();
              }));
              if (widget.routedPushed != null) widget.routedPushed(false);*/
            },
            label: 'Ask a Question',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.blueAccent),
        SpeedDialChild(
            child: Icon(Icons.video_call, color: Colors.white),
            backgroundColor: Colors.blueAccent,
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return QuestionVideo();
                  }));
              setState(() {});
            },
            label: 'Record Video',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.blueAccent)
      ],
    );
  }*/

  _navigationOptions(int index) {
    switch (index) {
      case 0:
        print(hasNotification);
        setState(() {
          hasNotification = false;
        });
        FlowRouter.router.navigateTo(
          context,
          'feed',
          clearStack: true,
          transition: TransitionType.none,
        );
        break;
      case 1:
        print(hasNotification);
        hasNotification = false;
        setState(() {});
        FlowRouter.router.navigateTo(context, 'explore',
            clearStack: true, transition: TransitionType.none);
        //record
        //FluroRouter.router.navigateTo(context, 'home', replace: true);
        break;
      case 2:
        // FlowRouter.router.navigateTo(context, 'questions', clearStack: true, transition: TransitionType.none);
        break;
      case 3:
        FlowRouter.router.navigateTo(context, 'inbox',
            clearStack: true, transition: TransitionType.none);
        break;
      case 4:
        FlowRouter.router.navigateTo(context, 'profile',
            clearStack: true, transition: TransitionType.material);
        break;
    }
  }
}

typedef void RoutedPushed(bool val);
