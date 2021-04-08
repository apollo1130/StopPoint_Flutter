import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_app/core/widgets/utils/AppbarBackButton.dart';
import 'package:provider/provider.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/inbox/widgets/directMessages/Conversation.dart';

class NewChat extends StatefulWidget {
  @override
  _NewChatState createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  List<User> following;

  @override
  void initState() {
    following =
        Provider.of<UserProvider>(context, listen: false).userLogged.following;
    super.initState();
  }

  void getData(String searchTerm) {
    setState(() {
      following = Provider.of<UserProvider>(context, listen: false)
          .userLogged
          .following
          .where((element) =>
          element.getFullName().toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackButton(),
        elevation: 1,
        title: Text('New chat'),
        centerTitle: true,
      ),
      body: Container(
        color: Color(0xffFAFAFA),
        padding: EdgeInsets.all(10),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _buildSearchField(),
            /* Container(
              height: 20,
            ),
            Text('Recent', style: TextStyle(color: Colors.grey)),
            ..._recentList(),*/
            Divider(),
            Text('Following', style: TextStyle(color: Colors.grey)),
            ..._followingList(following),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      child: Stack(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(40, 10, 10, 10),
              fillColor: Colors.grey[200],
              hintText: 'Search',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide.none),
              filled: true,
            ),
            style: TextStyle(color: Colors.black, fontSize: 14.0),
            onChanged: getData,
          ),
          Positioned(
            left: 8,
            top: 8,
            child: Icon(
              FontAwesomeIcons.search,
              color: Colors.grey,
              size: 20,
            ),
          )
        ],
      ),
    );
  }

  /*_recentList() {
    return [
      ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: CachedNetworkImageProvider('https://cdn.vuetifyjs.com/images/lists/1.jpg'),
        ),
        title: Text('Ali Connor', style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          '_aconnorX',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
  }*/

  _followingList(List<User> followingUsers) {
    List<ListTile> followingList = [];

    followingUsers.forEach((element) {
      followingList.add(
        ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Conversation(element.id)),
            );
          },
          contentPadding: EdgeInsets.all(0),
          leading: Builder(
            builder: (context) {
              if (element.avatar != null) {
                return CircleAvatar(
                  radius: 16,
                  backgroundImage: CachedNetworkImageProvider(element.avatar),
                );
              } else {
                return SizedBox();
              }
            },
          ),
          title: Text(element.getFullName(),
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            element.firstname,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    });

    return followingList;

    /*return [
      ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: CachedNetworkImageProvider('https://cdn.vuetifyjs.com/images/lists/1.jpg'),
        ),
        title: Text('Ali Connor', style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          '_aconnorX',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: CachedNetworkImageProvider('https://cdn.vuetifyjs.com/images/lists/2.jpg'),
        ),
        title: Text('Alex Freites', style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          'alex',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: CachedNetworkImageProvider('https://cdn.vuetifyjs.com/images/lists/3.jpg'),
        ),
        title: Text('Sandra Adamrs', style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          'sandritaa',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: CachedNetworkImageProvider('https://cdn.vuetifyjs.com/images/lists/4.jpg'),
        ),
        title: Text('Kelly Hansen', style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          'khanssen',
          overflow: TextOverflow.ellipsis,
        ),
      )
    ];*/
  }
}
