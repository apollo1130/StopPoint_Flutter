import 'package:cached_network_image/cached_network_image.dart';
import 'package:clip_shadow/clip_shadow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_app/core/widgets/BottomNavigationMenu.dart';
import 'package:video_app/core/widgets/CustomDrop.dart';
import 'package:video_app/pages/widgets/CreatePage.dart';
import 'package:video_app/pages/widgets/DemoBody.dart';
import 'package:video_app/pages/widgets/PageInfoWidget.dart';

class PagesWidget extends StatefulWidget {
  @override
  _PagesWidgetState createState() => _PagesWidgetState();
}

class _PagesWidgetState extends State<PagesWidget> with TickerProviderStateMixin  {

  String _selectedFilterSpaces = 'Recently Visited';
  double appbarHeight = 100;
  ScrollController _controller;
  bool needRect = true;
  PageController _pageController = PageController();
  int _actualPage = 0;

  AnimationController _animationController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController  = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: NestedScrollView(
          controller: _controller ,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            Size size = new Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
            print(MediaQuery.of(context).size.height);
            return <Widget>[
              SliverAppBar(
                expandedHeight: 150.0,
                floating: true,
                pinned: true,
                backgroundColor: Colors.grey[100],
                flexibleSpace: FlexibleSpaceBar(
                  background:  Container(
                    color: Colors.grey[100],
                    padding: EdgeInsets.only(bottom: 20),
                    child: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        ClipShadow(
                          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black87)],
                          clipper: OvalBottomBorderClipper(),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xffa8c0ff),
                                  Color(0xff3f2b96)
                                ],

                              ),
                            ),
                          ),
                        ),
                        AnimatedAlign(
                            alignment: _actualPage == 0 ? Alignment.center: Alignment.centerLeft,
                            duration: Duration(milliseconds: 250),
                            child: AnimatedOpacity(
                              opacity: _actualPage == 0 ? 1: 0,
                              duration: Duration(milliseconds: 250),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 250),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Text('My Pages', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                            )
                        ),
                        AnimatedAlign(
                            alignment: _actualPage == 0 ? Alignment.centerRight: Alignment.center,
                            duration: Duration(milliseconds: 250),
                            child: AnimatedOpacity(
                              opacity: _actualPage == 0 ? 0: 1,
                              duration: Duration(milliseconds: 250),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 250),
                                child: Text('Discover New Pages', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                              ),
                            )
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Transform.translate(
                            offset: Offset(0,20),
                            child: RaisedButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return CreatePage();
                                    }
                                ));
                              },
                              color: Colors.blueGrey[700],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(50))
                              ),
                              child: Text('Create Page', style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  collapseMode: CollapseMode.pin,
                ),
                title: !needRect ?  _actualPage == 0 ? Text('My Pages') : Text('Discover new') : SizedBox.shrink(),
                centerTitle: true,
                actions: <Widget>[
                  needRect ?
                  SizedBox.shrink():
                  GestureDetector(
                    child: Container(
                      width: 40,
                      height: 25,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(FontAwesomeIcons.plus),
                    ),
                  )
                ],
              ),

            ];
          },
          body: PageView(
            controller: _pageController,

            onPageChanged: (x) {
              if (x == 0) {
                _animationController.forward();

              }else {
                _animationController.reverse();
              }
              setState(() {
                _actualPage = x;
              });
            },
            children: <Widget>[
              Container(
                color: Colors.grey[100],
                child:  ListView(
                  children: <Widget>[
                    _mySpacesItem(
                      name: 'Coronavirus',
                      description: 'Shared knowledge and experiences regarding COVID-19',
                      follow: 1500000,
                      image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg',
                      personal: true,
                    ),
                    _mySpacesItem(
                        name: 'Coronavirus Watch',
                        description: 'Keeping an eye on COVID-19 coronavirus, briging you the latest updates',
                        follow: 152400,
                        image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
                    ),
                    _mySpacesItem(
                        name: 'Politics Insider',
                        description: 'The Latest political news and analysis from Bussisness Insider',
                        follow: 32700,
                        image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
                    ),
                    _mySpacesItem(
                        name: 'Politics Insider',
                        description: 'The Latest political news and analysis from Bussisness Insider',
                        follow: 32700,
                        image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
                    ),
                    _mySpacesItem(
                        name: 'Politics Insider',
                        description: 'The Latest political news and analysis from Bussisness Insider',
                        follow: 32700,
                        image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey[100],
                child:  ListView(
                  children: <Widget>[
                    _spacesItemV3(
                        name: 'Coronavirus',
                        description: 'Shared knowledge and experiences regarding COVID-19',
                        follow: 1500000,
                        image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
                    ),
                    _spacesItemV3(
                        name: 'Coronavirus Watch',
                        description: 'Keeping an eye on COVID-19 coronavirus, briging you the latest updates',
                        follow: 152400,
                        image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
                    ),
                    _spacesItemV3(
                        name: 'Politics Insider',
                        description: 'The Latest political news and analysis from Bussisness Insider',
                        follow: 32700,
                        image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
                    ),
                    _spacesItemV3(
                        name: 'Politics Insider',
                        description: 'The Latest political news and analysis from Bussisness Insider',
                        follow: 32700,
                        image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
                    ),
                    _spacesItemV3(
                        name: 'Politics Insider',
                        description: 'The Latest political news and analysis from Bussisness Insider',
                        follow: 32700,
                        image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
      bottomNavigationBar:  BottomNavigationMenu(iconColor: Colors.grey, backgroundColor:Colors.white)
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  _mySpaces() {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Your Spaces', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),),
                    CustomDrop(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(_selectedFilterSpaces, style: TextStyle(color: Colors.grey),),
                          Container(width: 5,),
                          AnimatedContainer(

                            duration: Duration(milliseconds: 200),
                            child: Icon(FontAwesomeIcons.chevronDown, color: Colors.grey, size: 15,),
                          )
                        ],
                      ),
                      options: [
                        DropdownMenuItem(child: Text('Recently Visited'), value: 'recent',),
                        DropdownMenuItem(child: Text('User asked'),value: 'userAsked' ),
                        DropdownMenuItem(child: Text('Spaces'), value: 'spaces'),
                        DropdownMenuItem(child: Text('Answer later'),value: 'answerLater'),
                        DropdownMenuItem(child: Text('The app questions'),value: 'appQuestions'),
                      ],
                      onSelect: (DropdownMenuItem item){
                        setState(() {
                          _selectedFilterSpaces = (item.child as Text).data;
                        });
                      },

                    )
                  ],
                ),
                Container(height: 5,),
                Row(
                  children: <Widget>[
                    Chip(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      avatar: Icon(FontAwesomeIcons.compass, color: Colors.blue,),
                      label: Text('Discover', style: TextStyle(color: Colors.grey[800]),),
                    ),
                    Container(width: 10,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreatePage()),
                        );
                      },
                      child: Chip(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        avatar: Icon(Icons.add_circle_outline, color: Colors.blue,),
                        label: Text('Create',style: TextStyle(color: Colors.grey[800])),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Text('VA', style:TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text('Video App Partners', style: TextStyle(fontWeight: FontWeight.w900),),
            trailing: Icon(FontAwesomeIcons.chevronRight),
          )
        ],
      ),
    );
  }

  _otherSpaces(){
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.topLeft,
                child: Text('Discover New Pages', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),)),
          ),
          Divider(),
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              _spacesItem(
                name: 'Coronavirus',
                description: 'Shared knowledge and experiences regarding COVID-19',
                follow: 1500000,
                image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
              ),
              Divider(),
              _spacesItem(
                  name: 'Coronavirus Watch',
                  description: 'Keeping an eye on COVID-19 coronavirus, briging you the latest updates',
                  follow: 152400,
                  image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
              ),
              Divider(),
              _spacesItem(
                  name: 'Politics Insider',
                  description: 'The Latest political news and analysis from Bussisness Insider',
                  follow: 32700,
                  image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
              ),
              Divider(),
              _spacesItem(
                  name: 'Politics Insider',
                  description: 'The Latest political news and analysis from Bussisness Insider',
                  follow: 32700,
                  image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
              ),
              Divider(),
              _spacesItem(
                  name: 'Politics Insider',
                  description: 'The Latest political news and analysis from Bussisness Insider',
                  follow: 32700,
                  image: 'https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'
              ),
            ],
          )
        ],
      ),
    );
  }

  _spacesItem({String image, String name, String description, double follow}){
    String  followText;
    if(follow >= 1000 && follow <  1000000) {
      followText = (follow/1000).toString() + 'k';
    } else if(follow >= 1000000 ){
      followText = (follow/1000000).toString() + 'm';
    }

    return Card(

      margin: EdgeInsets.all(10),
      child:ListTile(
        leading:CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(image),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.w900),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(description),
            Chip(
              backgroundColor: Color(0xFFE3F2FD),
              padding: EdgeInsets.only(left: 10, right: 10),
              avatar: Icon(FontAwesomeIcons.pager, size: 20, color: Colors.blue,),
              label: Text('Follow ' + followText, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
            )
          ],
        ),

      ),
    );
  }

  _spacesItemV3({String image, String name, String description, double follow}){
    String  followText;
    if(follow >= 1000 && follow <  1000000) {
      followText = (follow/1000).toString() + 'k';
    } else if(follow >= 1000000 ){
      followText = (follow/1000000).toString() + 'm';
    }

    return Card(

      margin: EdgeInsets.all(10),
      child:ListTile(
        leading:CircleAvatar(
          radius: 25,
          backgroundImage: CachedNetworkImageProvider(image),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.w900),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis,),
            Chip(
              backgroundColor: Colors.blue[800],
              padding: EdgeInsets.only(left: 10, right: 10),
              avatar: Icon(FontAwesomeIcons.pager, size: 20, color: Colors.white,),
              label: Text('Follow ' + followText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            )
          ],
        ),

      ),
    );
  }

  _mySpacesItem({String image, String name, String description, double follow, bool personal = false}){
    String  followText;
    if(follow >= 1000 && follow <  1000000) {
      followText = (follow/1000).toString() + 'k';
    } else if(follow >= 1000000 ){
      followText = (follow/1000000).toString() + 'm';
    }

    return Card(

      margin: EdgeInsets.all(10),
      child:ListTile(
        onTap: (){
          Navigator.push(context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return PageInfoWidget();
              }
            )
          );
        },
        leading:CircleAvatar(
          radius: 25,
          backgroundImage: CachedNetworkImageProvider(image),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.w900),),
        subtitle:personal ?  Row(
          children: <Widget>[
            Icon(FontAwesomeIcons.shieldAlt, color: Colors.grey, size: 20,),
            Container(width: 5,),
            Text('Admin')
          ],
        ) : Text(description, maxLines: 2, overflow: TextOverflow.ellipsis,),
        trailing: Container(
          width: 20,
          child: Center(child: Icon(FontAwesomeIcons.chevronRight, color: Colors.grey,)),
        ),
      ),
    );
  }

  _spacesItemV2({String image, String name, String description, double follow}){
    String  followText;
    if(follow >= 1000 && follow <  1000000) {
      followText = (follow/1000).toString() + 'k';
    } else if(follow >= 1000000 ){
      followText = (follow/1000000).toString() + 'm';
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(10,15,10,15),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: CachedNetworkImageProvider(image),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(name, style: TextStyle(fontWeight: FontWeight.w900),),
                  Text(description, textAlign: TextAlign.center,),
                ],
              ),
            ),
          ),

          Container(

            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.blue[800],
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    bottomRight: Radius.circular(50)
                ),

            ),
            child: Text('Follow \n' + followText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          )
        ],
      ),
    );
    return Card(

      margin: EdgeInsets.all(10),
      child:ListTile(
        leading:CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(image),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.w900),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(description),
            Chip(
              backgroundColor: Color(0xFFE3F2FD),
              padding: EdgeInsets.only(left: 10, right: 10),
              avatar: Icon(FontAwesomeIcons.pager, size: 20, color: Colors.blue,),
              label: Text('Follow ' + followText, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
            )
          ],
        ),

      ),
    );
  }

  oldPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),),
      ),
      body:Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _mySpaces(),
              Container(
                color: Colors.grey[300],
                width: MediaQuery.of(context).size.width,
                height: 8,
              ),
              _otherSpaces()
            ],
          ),
        ) ,
      ),
      bottomNavigationBar: BottomNavigationMenu(iconColor: Colors.grey, backgroundColor:Colors.white),
    );
  }

  _scrollListener() {

    print(_controller.offset);
    if(_controller.offset  >= 97 && needRect ) {
      setState(() {
        needRect =false;
      });
    }
    if(_controller.offset  < 97 && !needRect) {
      setState(() {
        needRect =true;
      });
    }

  }
}
