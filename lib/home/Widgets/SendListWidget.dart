import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/CoreProvider.dart';
import 'package:video_app/home/api/RecApiService.dart';
import 'package:video_app/home/models/SuggestedAndRecentResponse.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/ask/AnotherQuestionDialog.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/questions/models/QuestionRequest.dart';
import 'package:video_app/router.dart';

class SendListWidget extends StatefulWidget {
  final QuestionData questionData;
  SendListWidget({this.questionData});

  @override
  _SendListWidgetState createState() => _SendListWidgetState();
}

class _SendListWidgetState extends State<SendListWidget>  with SingleTickerProviderStateMixin {

  TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = "Search query";
  List<ListItem> _userList = List<ListItem>();
  int userSelected = -1;
  List<ListItem> _nearList = List<ListItem>();
  List<ListItem> _interestList = List<ListItem>();
  int interestSelected = -1;
  int selected = -1; //attention
  List<ListItem> _recentList = List<ListItem>();
  bool anonymous = false;
  GlobalKey containerKey = GlobalKey();
  bool listLoaded = false;
  QuestionRequest _request = QuestionRequest();
  int actualTab = 0;
  TabController _tabController;
  User _userLogged;
  List<UserListItem> _usersFound = List<UserListItem>();
  List<InterestListItem> _interestsFound = List<InterestListItem>();
  List<ListItem> _sendList = List<ListItem>();


  @override
  void initState() {
    super.initState();

    print(widget.questionData.text);
    print("widget.questionData.text");
    _tabController = TabController(vsync: this, length: 4);
    _tabController.addListener(() {
      _sendList.clear();
      if(_searchQueryController.text.length >0 ) {
        _searchDb(_searchQueryController.text);
      }
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;

    return  Scaffold(
      appBar: AppBar(

        automaticallyImplyLeading: false,
        title: _buildSearchField(),
        actions: <Widget>[
          FlatButton(

            child: Text('Cancel', style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
            onPressed: (){
              FlowRouter.router.pop(context);
//                _searchQueryController.clear();
//                FocusScope.of(context).requestFocus(new FocusNode());
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueGrey,
          unselectedLabelColor: Color(0xffB2BAC5),
          indicatorColor: Colors.blueAccent[400],
          tabs: <Widget>[
            Tab(icon: Icon(FontAwesomeIcons.bars)),
            Tab(icon: Icon(FontAwesomeIcons.user)),
            Tab(icon: Icon(FontAwesomeIcons.thLarge)),
            Tab(icon: Icon(FontAwesomeIcons.mapMarkerAlt)),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: _loadLists(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if (snapshot.data != null) {
                return TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    allList(_recentList),
                    _searchQueryController.text.length > 0 ? allList(_usersFound):  allList(_userList),
                    _searchQueryController.text.length > 0 ? allList(_interestsFound):  allList(_interestList),
                    allList(_nearList),
                  ],
                );
              }else {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),

          _confirmMessage()
        ],
      ) ,
    );
  }


  Widget _buildSearchField() {
    return Container(

      child: Stack(
        children: <Widget>[
          TextField(

            controller: _searchQueryController,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(40, 10,10,10),
              fillColor: Colors.grey[200],
              hintText: 'Search',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide.none
              ),

              filled: true,
              hintStyle: TextStyle(color: Colors.blueGrey),
            ),
            style: TextStyle(color: Colors.black, fontSize: 16.0),
            onChanged: (query) {
              _searchDb(query);
            },
          ),
          Positioned(
            left: 5,
           top: 7,
           child: Icon(FontAwesomeIcons.search, color: Colors.grey),
          )
        ],
      ),
    );
  }


  Widget allList(List<ListItem> localList){

    return Container(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (localList[index] is InterestListItem) {
            return _listInterestItem(localList[index], index);
          }else if (localList[index] is UserListItem){
            return _listUserItem(localList[index], index);
          } else {
            return _titleItem(localList[index]);
          }

        },
        itemCount: localList.length,
      ),
    );
  }

  Widget _listInterestItem(InterestListItem interest, int index) {
    return ListTile(
      key:  Key('builder ${selected.toString()}'),
      leading: Text(interest.icon, style: TextStyle(fontSize: 20),),
      title: Text(interest.name),
      trailing: _sendButton(interest),
      onTap: (){
        _selectItem(interest);
      },
    );
  }

  _listUserItem (UserListItem user, int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatar
      ),
      title:Text(user.name),
//      subtitle: Text(user.email),
      trailing: _sendButton(user),
      onTap:(){

        _selectItem(user);
       // _selectItem(index, 'user');
//        _sendQuestionToUser();
      },
    );
  }

  _titleItem(ListTitle title) {
    return ListTile(
      title: Text(title.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
    );
  }

  _sendButton(ListItem item) {
    if (_isSelected(item)) {
      return Icon(FontAwesomeIcons.solidCheckCircle, color: Colors.blue, size: 24,);

    }else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey
          ),
          shape: BoxShape.circle
        ),
      );
    }
  }

  _confirmMessage() {
    return Positioned(
      bottom: 0,
      child:AnimatedContainer(
        duration: Duration(milliseconds: 500),
        transform: Matrix4.translationValues(
            0,
            _sendList.length < 1 ? 100 : 0,
            0),


        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          onPressed: (){
            _sendQuestion();
          },
          color: Colors.blue,
          child: Text('Send', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
//          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 2)]
        ),
      ),
    );
  }

  _selectItem(ListItem item) {

    if(_isSelected(item)) {
      setState(() {
        _sendList.removeWhere((element) {
          if(element is UserListItem && item is UserListItem && element.id == item.id) {
            return true;
          } else if(element is InterestListItem && item is InterestListItem &&  element.id == item.id){
            return true;
          }else {
            return false;
          }
        });
      });
    }else {
      setState(() {
        _sendList.clear(); //Remove this line for send question to multiple user at same time;
        _sendList.add(item);
      });
    }
  }

  _loadLists() async {
    if (!listLoaded) {
      User userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
      Response response = await RecApiService().getSuggestedList(userLogged.id);
      if (response.statusCode == 200) {
        SuggestedAndRecentResponse suggestedAndRecentResponse = SuggestedAndRecentResponse.fromJson(response.data);
        _loadInterestList(suggestedAndRecentResponse.interests, suggestedAndRecentResponse.recentInterests);
        _loadUserList(suggestedAndRecentResponse.usersSuggested, suggestedAndRecentResponse.recentUsers);
        _loadRecentList(suggestedAndRecentResponse.recentInterests,suggestedAndRecentResponse.recentUsers);
        listLoaded = true;

      }
    }
    return true;
  }

  _loadUserList(List<User> usersDb, List<User> recent) {
    _userList.clear();
    if(recent != null  && recent.length > 0) {
      _userList.add(ListTitle(title: 'Recent'));
      recent.forEach((element) {
        _userList.add(UserListItem(avatar: element.avatarImageProvider(), name: element.getFullName(), email: element.email, id: element.id));
      });
    }
    _userList.add(ListTitle(title: 'Suggested'));
    usersDb.forEach((element) {
      _userList.add(UserListItem(avatar: element.avatarImageProvider(), name: element.getFullName(), email: element.email, id: element.id));
    });
    return _userList;
  }

  _loadInterestList(List<Interest> interestsDb, List<Interest> recent) {
    _interestList.clear();
    if(recent != null  && recent.length > 0) {
      _interestList.add(ListTitle(title: 'Recent'));
      recent.forEach((element) {
        _interestList.add(InterestListItem(name: element.label, icon: element.icon, id: element.id));
      });
    }
    _interestList.add(ListTitle(title: 'Suggested'));
    interestsDb.forEach((element) {
      _interestList.add(InterestListItem(name: element.label, icon: element.icon, id: element.id));
    });
  }

  _sendQuestionToUser(UserListItem user) async {
    _request.type = QuestionType.USER_QUESTION;
//    _request.userQuestionsList = List<UserQuestion>();
//    _request.userQuestionsList.add(UserQuestion(userSendId: _userLogged.id, userReceivedId: user.id, questionData: widget.questionData));
    Response response =  await RecApiService().sentQuestion(_request);
    if (response.statusCode == 200 ) {
      showDialog(
          context: context,
          builder: (BuildContext context){
            return AnotherQuestionDialog();
          }
      );
    }else if(response.statusCode == 422){
      Fluttertoast.showToast(
          msg: 'The same question was sent to this user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  _sendQuestionToInterest(InterestListItem interest) async {
    _request.type = QuestionType.GENERAL_QUESTION;
//    _request.interestQuestionList = List<InterestQuestion>();
//    _request.interestQuestionList.add(InterestQuestion(userSendId: _userLogged.id, interestId: interest.id , questionData: widget.questionData));
    Response response =  await RecApiService().sentQuestion(_request);
    if (response.statusCode == 200 ) {
      Fluttertoast.showToast(
          msg: 'The question was sent',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
      await Future.delayed(Duration(milliseconds: 1500));
      Navigator.pop(context, true);
    }else if(response.statusCode == 404){
      Fluttertoast.showToast(
          msg: 'The same question was sent to this interest',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  getCorrectIndex(String tag) {
    int result = -1;
    switch (tag) {
      case 'user' :
        result = userSelected;break;
      case 'interest':
        result = interestSelected;break;
      case 'recent':
      case 'near':
    }
    return result;
  }

  setCorrectIndex(String tag , int index) {
    switch (tag) {
      case 'user' :
        userSelected = index; break;
      case 'interest':
        interestSelected = index ;break;
      case 'recent':
      case 'near':
    }
  }

  somethingIsSelectedOnCurrentTab() {
      bool somethingSelect = false;
      switch (_tabController.index) {
        case  0 : break;
        case  1 : somethingSelect = userSelected != -1 ? true: false;break;
        case  2 : somethingSelect = interestSelected != -1 ? true: false;break;
        case  3 : break;

      }
      return somethingSelect;
  }

  _sendQuestion() {
    _sendList.forEach((element) {
      if(element is UserListItem) {
        _sendQuestionToUser(element);
      }else {
        _sendQuestionToInterest(element);
      }
    });
  }

  _loadRecentList(List<Interest> interests, List<User> users){
    users.forEach((element) {
      _recentList.add(UserListItem(avatar: element.avatarImageProvider(), name: element.getFullName(), email: element.email, id: element.id, timestamp: element.timestamp));
    });
    interests.forEach((element) {
      _recentList.add(InterestListItem(name: element.label, icon: element.icon, id: element.id, timestamp: element.timestamp));
    });

    _recentList.sort((x, y) {
      return x.timestamp < y.timestamp ? 1 : 0 ;
    });

    _recentList.insert(0, ListTitle(title:'Recent'));
    print('sorted');
  }

  _searchDb( String query) {
    print (_tabController.index);
    switch(_tabController.index) {
      case 0 : break;
      case 1: _searchUserInDb(query);break;
      case 2: _searchInterestInDb(query);break;
    }
  }

  _searchUserInDb(String query) async {
     Response response =  await RecApiService().getUser(query);
     _usersFound.clear();
     if(response.statusCode == 200) {
       response.data.forEach( (user) {
         var usr = User.fromJson(user);
         _usersFound.add(UserListItem(avatar: usr.avatarImageProvider(), name: usr.getFullName(), email: usr.email, id: usr.id));
       });
       setState(() {
       });
     }else {
       Fluttertoast.showToast(
           msg: 'Error searching user',
           toastLength: Toast.LENGTH_SHORT,
           gravity: ToastGravity.BOTTOM,
           timeInSecForIosWeb: 1,
           backgroundColor: Colors.red,
           textColor: Colors.white,
           fontSize: 16.0
       );
     }
  }

  _searchInterestInDb(String query) async {
    List<Interest> allInterests = Provider.of<CoreProvider>(context, listen: false).interests;
    _interestsFound.clear();
    allInterests.forEach((element) {
      if (element.label.toLowerCase().contains(query.toLowerCase())){
        _interestsFound.add(InterestListItem(icon: element.icon, name:element.label, id:element.id));
      }
    });
    setState(() {

    });
  }

  _isSelected(ListItem item) {
    bool selected = false;
    _sendList.forEach((element) {
      if (element is UserListItem && item is UserListItem && element.id == item.id) {
        selected = true;
      }  else if (element is InterestListItem && item is InterestListItem &&  element.id == item.id) {
        selected =true;
      }
    });
    return selected;
  }
}

abstract class ListItem {
  int timestamp;
  ListItem({this.timestamp});
}

class UserListItem implements ListItem{
  ImageProvider avatar;
  String name;
  String email;
  String id;
  UserListItem({this.avatar, this.name, this.email, this.id, this.timestamp});

  @override
  int timestamp;

}
class InterestListItem implements ListItem {
  String icon;
  String name;
  String id;
  InterestListItem({this.name, this.icon, this.id, this.timestamp});

  @override
  int timestamp;
}

class ListTitle implements ListItem {
  String title;

  ListTitle({this.title});

  @override
  int timestamp;
}

class SelectionCategory {
  bool category;
  List<bool> subCat;
  SelectionCategory(this.category, this.subCat);
}


