import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class PagesWidgetList extends StatefulWidget {
  @override
  _PagesWidgetListState createState() => _PagesWidgetListState();
}

class _PagesWidgetListState extends State<PagesWidgetList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.topLeft,
                child: Text('Discover new pages'.toUpperCase(), style: TextStyle(color: Colors.grey),)
            ),
          ),
          Divider(color: Colors.transparent,),
          Container(
            height: MediaQuery.of(context).size.height /3,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Container(width: 20),
                _pageItem(),
                Container(width: 8),
                _pageItem(),
                Container(width: 8),
                _pageItem(),
                Container(width: 8),
                _pageItem(),
                Container(width: 8),
                _pageItem()
              ],
            ),
          ),
          FlatButton(
            onPressed: (){},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('See more spaces', style: TextStyle(color: Colors.grey[700]),),
                Icon(FontAwesomeIcons.angleRight, color: Colors.grey[700],)
              ],
            ),
          )
        ],
      )
    );
  }

  _pageItem(){
    return Container(
      width:  MediaQuery.of(context).size.width /2.5,
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width /2.5,
           height: 60,
           decoration: BoxDecoration(
             image: DecorationImage(
               image: CachedNetworkImageProvider('https://cdn4.vectorstock.com/i/1000x1000/82/43/science-banner-typography-and-background-vector-18388243.jpg'),
               fit: BoxFit.cover

             ),
             borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
           ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    child: Icon(FontAwesomeIcons.times, color: Colors.white,),
                  ),
                ),
                Container(height: 10,),
                Container(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider('https://cdn3.iconfinder.com/data/icons/scientix-circular/128/science_research_equipment-11-512.png'),
                      ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2
                    )
                  ),
                ),
                Container(height: 8,),
                Text('Science for life', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(height: 8,),
                Text('q/scienceforlife', style: TextStyle(color: Colors.grey, fontSize: 12),),
                Container(height: 8,),
                Text('A space for the dissemination of basic science for life', style: TextStyle(fontSize: 12), textAlign: TextAlign.center,),
                Container(height: 28,),
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.pager, color: Colors.blue, size: 25,),
                        Container(
                          transform: Matrix4.translationValues(0, -5, 0),
                          padding: EdgeInsets.all(2),
                          child: Text('8,2k', style: TextStyle(fontSize: 10, color: Colors.grey[700]),),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                        )
                      ],
                    ),
                    Text('Follow', style: TextStyle(fontSize: 12),)
                  ],
                )

              ],
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: Colors.grey
        )
      ),
    );
  }
}
