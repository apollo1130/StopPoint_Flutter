import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_app/core/widgets/utils/AppbarBackButton.dart';
import 'package:video_app/pages/widgets/tabs/MainTabPageWidget.dart';
import 'package:video_app/router.dart';

class PageInfoWidget extends StatefulWidget {
  @override
  _PageInfoWidgetState createState() => _PageInfoWidgetState();
}

class _PageInfoWidgetState extends State<PageInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: AppbarBackButton(),
          title: Text('Coronavirus'),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(

            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider('https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'),
                    fit: BoxFit.cover
                  )
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15 - 50 ,
                left: MediaQuery.of(context).size.width /2  - 50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider('https://as01.epimg.net/deporteyvida/imagenes/2020/02/25/portada/1582629638_747744_1582634180_noticia_normal_recorte1.jpg'),
                        fit: BoxFit.cover
                      ),
                      shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4
                    )
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height *0.15 + 20,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        _tabItem(false, false, 'Invite', FontAwesomeIcons.userPlus),
                        _tabItem(true, true, 'Following', FontAwesomeIcons.pager),
                        Container(width: MediaQuery.of(context).size.width /5, height: 2,),
                        _tabItem(false, false, 'Notification', FontAwesomeIcons.bell),
                        _tabItem(false, false, 'More', FontAwesomeIcons.ellipsisH),
                      ],
                    ),
                    Divider(),
                    TabBar(
                      labelPadding: EdgeInsets.all(0),
                      labelStyle: TextStyle(
                        fontSize: 12
                      ),
                      tabs: <Widget>[
                        Tab(
                          child: Text( 'Main') ,
                        ),
                        Tab(
                          child: Text( 'Submission') ,
                        ),
                        Tab(
                          text: 'Queue',
                        ),
                        Tab(
                          child: Text( 'Suggestions') ,
                        ),

                        Tab(
                          text: 'People',
                        )
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.576,
                      child: TabBarView(
                        children: <Widget>[
                          MainTabPageWidget(),
                          Container(child: Text('Submission')),
                          Container(child: Text('Queue')),

                          Container(child: Text('People')),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _tabItem(bool active, bool needCheck, String text, IconData icon) {
    Color iconColor = active ? Colors.blue : Colors.grey[700];
    return Container(
      width: MediaQuery.of(context).size.width / 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: iconColor),
              needCheck ? Transform.translate(
                  offset: Offset(0,-5),
                  child: Icon(FontAwesomeIcons.check, color: iconColor, size: 12,)
              ) : SizedBox.shrink()
            ],
          ),
          Text(text, style: TextStyle(color: Colors.grey[700]),)
        ],
      ),
    );
  }
}
