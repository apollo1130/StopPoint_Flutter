import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';

class FollowersTabWidget extends StatefulWidget {
  final User member;
  bool fromanotherprofile;
  bool isPrivateAccount;

  FollowersTabWidget({this.member, this.fromanotherprofile, this.isPrivateAccount});

  @override
  _FollowersTabWidgetState createState() => _FollowersTabWidgetState();
}

class _FollowersTabWidgetState extends State<FollowersTabWidget> {
  User _user;
  bool isMember = false;

  @override
  Widget build(BuildContext context) {

    isMember = widget.member != null;
    _user = isMember
        ? widget.member
        : Provider.of<UserProvider>(context).userLogged;
    bool iFollow = _getFollowInformation(_user.id);
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(
            'Follower',
            style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: widget.isPrivateAccount && _user.privateProfile && !iFollow?Center(
          child: Padding(
            padding: const EdgeInsets.only(top:50.0),
            child: Container(
              // height: 20,
              // width: 40,
                color: Colors.transparent,
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
                )),
          ),
        ):Container(
          color: Colors.white,
          child: _user.followers.length == 0 ?NoContent(text: 'No followers yet',
            icon: Icons.supervisor_account,) :ListView.separated(
              padding: EdgeInsets.all(0),
              itemBuilder: (BuildContext context, int index) {
                return _userItem(_user.followers[index]);
              },
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemCount: _user.followers.length),
        ),
      ),
    );
  }

  _userItem(User user) {
    /*Container(
            width: 50.0,
            height: 75.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image:  user.avatarImageProvider()),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
          ),*/
    return Container(
      color: Colors.white,
      child: ListTile(
          onTap: () {
            ProfileHelpers().navigationProfileHelper(context, user.id);
          },
          leading: CircleAvatar(backgroundImage: user.avatarImageProvider()),
          title: Text(
            user.getFullName(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle:
          Text(StringUtils.defaultString(user.username, defaultStr: '')),
          trailing: _followButton(user.id)),
    );
  }

  _followButton(String userId) {
    bool iFollowThisUser = _getFollowInformation(userId);
    if (!widget.fromanotherprofile) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          iFollowThisUser
              ? OutlineButton(
            color: Colors.blue,
            onPressed: () {
              if (!widget.fromanotherprofile) {
                _unfollow(userId);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.userCheck,
                  color: Colors.grey[700],
                  size: 16,
                ),
                Container(
                  width: 10,
                  height: 0,
                ),
                Text(
                  'Following ',
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          )
              : RaisedButton(
            color: Colors.blue,
            onPressed: () {
              _follow(userId);
            },
            child: Row(
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.userPlus,
                  color: Colors.white,
                  size: 16,
                ),
                Container(
                  width: 10,
                  height: 0,
                ),
                Text(
                  'Follow',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          )
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  _getFollowInformation(String userId) {
    bool result = false;
    _user.following.forEach((element) {
      if (element.id == userId) {
        result = true;
      }
    });
    return result;
  }

  _follow(String memberId) async {
    Response response = await ProfileApiService().follow(_user.id, memberId);

    if (response.statusCode == 200) {
      _user.following.add(User.fromJson(response.data));
      _onRefresh();
      // reloadUser();
      // setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: 'Account is private request sent',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  _unfollow(String memberId) async {
    Response response = await ProfileApiService().unfollow(_user.id, memberId);
    if (response.statusCode == 200) {
      int index =
      _user.following.indexWhere((element) => element.id == memberId);
      _user.following.removeAt(index);
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

  Future<void> _onRefresh() async {
    // monitor network fetch
    await reloadUser();
    setState(() {});
    // if failed,use refreshFailed()
    // _refreshController.refreshCompleted();
  }

  Future<User> reloadUser() async {
    print(_user.id);
    Provider.of<UserProvider>(context, listen: false).updateProvider();
    // Response response = await AuthApiService().getProfile(_user.id);
    // Provider.of<UserProvider>(context, listen: false).userLogged = User.fromJson(response.data);
    return _user;
  }
}
class NoContent extends StatelessWidget {
  NoContent({this.text, this.icon});

  String text;
  IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:50),
      child: Container(
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
      ),
    );
  }
}