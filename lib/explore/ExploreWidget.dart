import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/CoreProvider.dart';
import 'package:video_app/core/widgets/BottomNavigationMenu.dart';
import 'package:video_app/core/widgets/CustomChip.dart';
import 'package:video_app/core/widgets/VideoWidget.dart';
import 'package:video_app/explore/api/ExploreApiService.dart';
import 'package:video_app/explore/models/InterestsWithVideosModel.dart';
import 'package:video_app/explore/models/SearchItem.dart';
import 'package:video_app/explore/widgets/InterestDetailsWidget.dart';
import 'package:video_app/explore/widgets/VideoThumbnail.dart';
import 'package:video_app/feed/widgets/QuestionDetailsWidget.dart';
import 'package:video_app/feed/widgets/QuestionInterestDetails.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:localstorage/localstorage.dart';


class ExploreWidget extends StatefulWidget {
  @override
  _ExploreWidgetState createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget>
    with TickerProviderStateMixin {
  SearchBarController _controller = SearchBarController();
  TabController _tabController;
  TextEditingController _searchQueryController = TextEditingController();
  User _userLogged;
  Timer _debounce;
  List<SearchItem> searchItems = List<SearchItem>();
  bool serverLoad = false;
  List<Interest> interests = List<Interest>();
  List<Interest> tempInterest = List<Interest>();
  int initPosition = 1;
  bool textClear = false;
  var focusNode = FocusNode();

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    interests = Provider.of<CoreProvider>(context).interests;
    _tabController = new TabController(vsync: this, length: _searchQueryController.text.length < 1 ? interests.length : 0);
    return  new Scaffold(

      body: new NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
          return <Widget>[
            new SliverAppBar(
              title: _buildSearchField(),
              pinned: true,
              floating: true,
              elevation: 0,
              forceElevated: innerBoxIsScrolled,
              bottom: (_searchQueryController.text.length < 1 && !textClear)?  new TabBar(
                isScrollable: true,
                tabs: List<Widget>.generate(_searchQueryController.text.length < 1 ? interests.length : 0, (int index){
                  print(interests[0]);
                  return new Tab(/*icon: SvgPicture.network(
                        interests[index].icon,
                        width: 20,
                        height: 20,
                      ),*/ child: Text(interests[index].label,style: TextStyle(color: Colors.black),),);
                })
                ,controller: _tabController,
              ) : null,
            ),
          ];
        },
        body: Stack(
          children: <Widget>[
            (_searchQueryController.text.length < 1 && !textClear)
                ?  _interestList()
                : serverLoad
                ? Center(
              child: CircularProgressIndicator(),
            )
                : _searchList(),
          ],
        ),

      ),
      bottomNavigationBar: BottomNavigationMenu(
        iconColor: Color(0xff252525),
        backgroundColor: Color(0xffFAFAFA),
        selectedIconColor: Color(0xFF3982f3),
        currentIndex: 1,
      ),



      /*  body: Stack(
        children: <Widget>[
          _searchQueryController.text.length < 1
              ?  _interestList()
              : serverLoad
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _searchList(),
        ],
      ),*/

    );
  }

  Widget _buildSearchField() {
    return Container(
      child: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: (_searchQueryController.text.length >= 1 || textClear )? GestureDetector(
                  onTap: () => {
                    setState(() {
                      textClear = false;
                      _searchQueryController.clear();
                      FocusScope.of(context).unfocus();
                    })
                  },
                  child: Icon(Icons.arrow_back,color: Colors.blue,),
                )  : Icon(Icons.close,color: Colors.transparent,),
              ),
              Expanded(
                  flex: 13,
                  child: Container(
                    height: 40,
                    child: TextField(
                      focusNode: focusNode,
                      controller: _searchQueryController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        fillColor: _searchQueryController.text.length >= 1 ?  Colors.white :Colors.grey[200],
                        hintText: 'Search',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide.none),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                      onChanged: (query) {
                        textClear = false;
                        _getSearchItems(query);
                      },onSubmitted: (query){

                    },
                    ),
                  )
              ),
              Expanded(
                flex: 1,
                child: (_searchQueryController.text.length >= 1 || textClear )? GestureDetector(
                  onTap: () => {
                    setState(() {
                      textClear = true;
                      _searchQueryController.clear();
                      searchItems.clear();
                      FocusScope.of(context).requestFocus(focusNode);
                    })
                  },
                  child: Icon(Icons.clear,color: Colors.blue,),
                ): Icon(Icons.clear,color: Colors.transparent,),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<List<SearchItem>> _getSearchItems(String text) async {
    LocalStorage _storage = LocalStorage("mainStorage");

    if (await _storage.ready) {
      String token = _storage.getItem('authToken');
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        setState(() {
          serverLoad = true;
        });
        searchItems.clear();
        if (text.length > 0) {
          Response response = await ExploreApiService(token: token).getSearchItems(text);
          await response.data.forEach((x) {
            searchItems.add(SearchItem.fromJson(x));
          });
        }
        setState(() {
          serverLoad = false;
        });
      });
    }
  }

  _searchList() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return _questionItem(searchItems[index]);
            },
            itemCount: searchItems.length,
          )
      ),
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
        child: SvgPicture.network(item.icon),
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

  _interestList() {
    return new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: TabBarView(
          children: List<Widget>.generate(_searchQueryController.text.length < 1 ? interests.length : 0, (int index){

            return new  InterestDetailsWidget(interest: interests[index]);

          }),
          controller: _tabController,
        ),
      ),
    );
  }

  _listInterest(){
    return interests.map((e) {
      return CustomChip(
          icon: e.icon,
          label: e.label,
          selected: false,
          onSelect: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return InterestDetailsWidget(interest: e);
                }));
          }
      );
    }).toList();
  }



}
