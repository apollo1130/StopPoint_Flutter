import 'package:basic_utils/basic_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/api/AuthApiService.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';

class FollowingTabWidget extends StatefulWidget {
  final User member;
  bool currentUserProfile;
  bool isPrivateAccount;
  FollowingTabWidget({this.member,this.currentUserProfile,this.isPrivateAccount});
  @override
  _FollowingTabWidgetState createState() => _FollowingTabWidgetState();
}

class _FollowingTabWidgetState extends State<FollowingTabWidget> {
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
            'Following',
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
          child: _user.following.length == 0 ?
          NoContent(icon: Icons.supervisor_account, text: 'No one is following yet') :ListView.separated(
              padding: EdgeInsets.all(0),
              itemBuilder: (BuildContext context, int index) {
                return _userItem(_user.following[index]);
              },
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemCount: _user.following.length),
        ),
      ),
    );
  }

  _userItem(User user) {
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
          trailing: widget.isPrivateAccount?SizedBox():_followingButton(user.id)
      ),
    );
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
  _followingButton(String userId) {
    if (widget.currentUserProfile) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          OutlineButton(
            onPressed: () {
              _unfollow(userId);
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
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
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

  Future<void> _onRefresh() async{
    // monitor network fetch
    await reloadUser();
    setState(() {

    });
    // if failed,use refreshFailed()
    // _refreshController.refreshCompleted();
  }

  Future<User> reloadUser() async {
    LocalStorage _storage = LocalStorage('mainStorage');
    if (await _storage.ready) {
      String authToken = _storage.getItem("authToken");
      Response response = await AuthApiService(token: authToken).getProfile(_user.id);
      Provider.of<UserProvider>(context, listen: false).userLogged = User.fromJson(response.data);
      Provider.of<UserProvider>(context, listen: false).updateProvider();
      return _user;
    }

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