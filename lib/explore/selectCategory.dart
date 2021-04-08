//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:video_app/core/providers/CoreProvider.dart';
//import 'package:video_app/explore/widgets/InterestDetailsWidget.dart';
//import 'package:video_app/profile/models/Interest.dart';
//import 'package:video_app/questions/ask/ConfirmAskQuestionFast.dart';
//import 'package:video_app/questions/models/QuestionData.dart';
//import 'package:video_app/questions/ask/AudienceSelect.dart';
//
//class SelectCategory extends StatefulWidget {
//  final QuestionData question;
//  final String userId;
//  final String interestId;
//  SelectCategory({this.question, this.userId, this.interestId});
//  @override
//  _SelectCategoryState createState() => _SelectCategoryState();
//}
//
//class _SelectCategoryState extends State<SelectCategory> {
//  AudienceType _audienceSelected = AudienceType.Public;
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Select Category'),
//      ),
//      body: _interestList(),
//    );
//  }
//  _interestList() {
//    List<Interest> interestList = Provider.of<CoreProvider>(context).interests;
//    return Container(
//      child: ListView.builder(
//          itemBuilder: (BuildContext context, int index) {
//            return ListTile(
//              onTap: () {
////                Navigator.push(context,
////                    MaterialPageRoute(builder: (BuildContext context) {
////                      return InterestDetailsWidget(interest: interestList[index]);
////                    }));
//                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
//                  return ConfirmAskNewQuestion(question: QuestionData(text: widget.question.text.replaceAll("?", ""), privacy: _audienceSelected),
//                      userId: widget.userId != null ? widget.userId : null,
//                      interestId:  interestList[index].id != null ? interestList[index].id: null,userToAsk: interestList[index].label != null ? interestList[index].label: null,icon: interestList[index].icon != null ? interestList[index].icon: null,);
//                }));
//              },
//              leading: CircleAvatar(
//                child: Text(interestList[index].icon),
//                backgroundColor: Colors.transparent,
//              ),
//              title: Text(interestList[index].label),
//            );
//          },
//          itemCount: interestList.length),
//    );
//  }
//}
//


import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/CoreProvider.dart';
import 'package:video_app/core/widgets/BottomNavigationMenu.dart';
import 'package:video_app/core/widgets/CustomChip.dart';
import 'package:video_app/explore/api/ExploreApiService.dart';
import 'package:video_app/explore/models/SearchItem.dart';
import 'package:video_app/explore/widgets/InterestDetailsWidget.dart';
import 'package:video_app/feed/widgets/QuestionDetailsWidget.dart';
import 'package:video_app/feed/widgets/QuestionInterestDetails.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:video_app/questions/ask/ConfirmAskQuestionFast.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/questions/ask/AudienceSelect.dart';

class SelectCategory extends StatefulWidget {
  final QuestionData question;
  final String userId;
  final String interestId;
  final String privacy;
  SelectCategory({this.question, this.userId, this.interestId, this.privacy});
  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory>
    with TickerProviderStateMixin {
  SearchBarController _controller = SearchBarController();
  TabController _tabController;
  TextEditingController _searchQueryController = TextEditingController();
  User _userLogged;
  Timer _debounce;
  List<SearchItem> searchItems = List<SearchItem>();
  bool serverLoad = false;
  AudienceType _audienceSelected = AudienceType.Public;

  @override
  void initState() {
    print("hello word");
    print(widget.question.text);
    print(widget.privacy);
    _tabController = new TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        title: Text("Edit Topics"),//_buildSearchField(),
//        actions: <Widget>[
//          FlatButton(
//            child: Text('Cancel',
//                style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
//            onPressed: () {
//              // FluroRouter.router.pop(context);
//              _searchQueryController.clear();
//              FocusScope.of(context).unfocus();
//            },
//          )
//        ],
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.blueGrey,
//           unselectedLabelColor: Color(0xffB2BAC5),
//           indicatorColor: Colors.blueAccent[400],
//           tabs: <Widget>[
//             Tab(icon: Icon(FontAwesomeIcons.thLarge)),
//             // Tab(icon: Icon(FontAwesomeIcons.bars)),
//             Tab(icon: Icon(FontAwesomeIcons.user)),
//           ],
//         ),
      ),
      body: Stack(
        children: <Widget>[
          _searchQueryController.text.length < 1
              ? TabBarView(
            controller: _tabController,
            children: <Widget>[
              // Container(
              //   child: Text('recents'),
              // ),
              _interestList(),
              _followUserList(),
            ],
          )
              : serverLoad
              ? Center(
            child: CircularProgressIndicator(),
          )
              : _searchList(),
        ],
      ),
//      bottomNavigationBar: BottomNavigationMenu(
//        iconColor: Color(0xff252525),
//        backgroundColor: Color(0xffFAFAFA),
//        selectedIconColor: Color(0xFF3982f3),
//        currentIndex: 1,
//      ),
    );
  }
/*
  Widget _buildSearchField() {
    return Container(
      child: Stack(
        children: <Widget>[
          TextField(
            controller: _searchQueryController,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(40, 10, 10, 10),
              fillColor: Colors.grey[200],
              hintText: 'Search',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide.none),
              filled: true,
              hintStyle: TextStyle(color: Colors.blueGrey),
            ),
            style: TextStyle(color: Colors.black, fontSize: 16.0),
            onChanged: (query) {
              _getSearchItems(query);
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

  Future<List<SearchItem>> _getSearchItems(String text) async {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      serverLoad = true;
      searchItems.clear();
      if (text.length > 0) {
        Response response = await ExploreApiService().getSearchItems(text);
        await response.data.forEach((x) {
          searchItems.add(SearchItem.fromJson(x));
        });
      }
      setState(() {
        serverLoad = false;
      });
    });
  }
*/
  _searchList() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _questionItem(searchItems[index]);
      },
      itemCount: searchItems.length,
    );
  }

  _questionItem(SearchItem item) {
    if (item.text != null) {
      return _questionTile(item);
    } else if (item.label != null) {
      return _interestTile(item);
    } else {
      return _userTile(item);
    }
  }

  _questionTile(SearchItem item) {
    return ListTile(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
              if (item.interest != null) {
                return QuestionInterestDetailsWidget(
                    question: QuestionData(id: item.id));
              } else {
                return QuestionDetailsWidget(
                  question: QuestionData(id: item.id),
                  needFetch: true,
                );
              }
            }));
      },
      leading: Icon(FontAwesomeIcons.questionCircle),
      title: RichText(
        text: TextSpan(
            text: 'Topic: ',
            style: TextStyle(color: Colors.grey),
            children: [
              TextSpan(
                text: item.text,
                style: TextStyle(color: Colors.black),
              )
            ]),
      ),
    );
  }

  _interestTile(SearchItem item) {
    return ListTile(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return InterestDetailsWidget(
                interest: Interest(icon: item.icon, label: item.label, id: item.id),
              );
            }));
      },
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.transparent,
        child: Text(item.icon),
      ),
      title: RichText(
        text: TextSpan(
            text: 'Interest: ',
            style: TextStyle(color: Colors.grey),
            children: [
              TextSpan(
                text: item.label,
                style: TextStyle(color: Colors.black),
              )
            ]),
      ),
    );
  }

  _userTile(SearchItem item) {
    return ListTile(
      onTap: () {
        ProfileHelpers().navigationProfileHelper(context, item.id);
      },
      leading:
      CircleAvatar(radius: 12, backgroundImage: item.avatarImageProvider()),
      title: RichText(
        text: TextSpan(
            text: 'User: ',
            style: TextStyle(color: Colors.grey),
            children: [
              TextSpan(
                text: item.getFullName(),
                style: TextStyle(color: Colors.black),
              )
            ]),
      ),
    );
  }

  _followUserList() {
    List<User> followUser = _userLogged.following;
    return Container(
      child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                print( widget.privacy);
                print("audi");
                //dxqzdq
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                  return ConfirmAskQuestionFast(
                    question: QuestionData(text: widget.question.text.replaceAll("?", ""), privacy: _audienceSelected),
                    userId: followUser[index].id,
                    userToAsk: followUser[index].getFullName(),
                    provideImage: followUser[index].avatarImageProvider(),
                      privacy : widget.privacy
                  );
                }));
              },
              leading: CircleAvatar(
                  backgroundImage: followUser[index].avatarImageProvider()),
              title: Text(followUser[index].getFullName()),
              subtitle: followUser[index].username != null
                  ? Text(followUser[index].username)
                  : null,
            );
          },
          itemCount: followUser.length),
    );
  }



  _interestList() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AutoSizeText(
              'Select your interest',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
            Divider(color: Colors.transparent,),
            AutoSizeText(
              'Everyone has a story to share that can inspire, teach, and motivate people.',
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 2,
              textAlign: TextAlign.left,
            ),
            Divider(color: Colors.transparent,),
            Divider(color: Colors.transparent,),
            Wrap(
                children: _listInterest()
            )
          ],
        ),
      ),
    );


  }


  _listInterest(){
    List<Interest> interests = Provider.of<CoreProvider>(context).interests;
    return interests.map((e) {
      return CustomChip(
          icon: e.icon,
          label: e.label,
          selected: false,
          onSelect: (){
            print("widget.question.text");
            print(widget.question.text);
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
              return ConfirmAskQuestionFast(
                question: QuestionData(text: widget.question.text.replaceAll("?", ""), privacy: _audienceSelected),
                interestId: e.id != null ? e.id: null,
                icon: e.icon,
                userToAsk: e.label,
                  privacy : widget.privacy
              );
            }));
          }
      );
    }).toList();
  }
}

