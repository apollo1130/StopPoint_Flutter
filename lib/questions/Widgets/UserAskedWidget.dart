import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_app/core/widgets/utils/AppbarBackButton.dart';

class UserAskedWidget extends StatefulWidget {
  @override
  _UserAskedWidgetState createState() => _UserAskedWidgetState();
}

class _UserAskedWidgetState extends State<UserAskedWidget> {
  TextEditingController _searchQueryController  = TextEditingController();
  List<ListItem> _userList = List<ListItem>();

  @override
  void initState() {
    generateUserList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Asked'),
        leading: AppbarBackButton(),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: _buildSearchField()
            ),
            Expanded(
              child: _userListWidget(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      child: TextField(
        controller: _searchQueryController,
        decoration: InputDecoration(
          prefixIcon: Icon(FontAwesomeIcons.search, color: Colors.grey,),
          contentPadding: EdgeInsets.all(10),
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
        },
      ),
    );
  }

  _userListWidget() {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return _listItem(_userList[index]);
        },
        itemCount: _userList.length,
    );
  }

  _listItem(User user) {
    return ListTile(
      leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(user.avatar)
      ),
      title:Text(user.username),
      subtitle: Text(user.name),
      trailing: user.followed ?
        OutlineButton(
          onPressed: (){},
          child: Text('Unfollow', style: TextStyle(color: Colors.blue),),
          color: Colors.blue,
          borderSide: BorderSide(color: Colors.blue),
        ):
        RaisedButton(
          onPressed: (){},
          child: Text('Follow', style: TextStyle(color: Colors.white)),
          color: Colors.blue,
        ),
      onTap:(){
      },
    );
  }

  generateUserList() {
    _userList.add(User('https://cdn.vuetifyjs.com/images/lists/1.jpg', 'Ali Connor', '_aconnorX', true));
    _userList.add(User('https://cdn.vuetifyjs.com/images/lists/2.jpg', 'Alex Freites', 'alex', false));
    _userList.add(User('https://cdn.vuetifyjs.com/images/lists/3.jpg', 'Sandra Adamrs', 'sandritaa', false));
    _userList.add(User('https://cdn.vuetifyjs.com/images/lists/4.jpg', 'Kelly Hansen', 'khanssen', true));
    _userList.add(User('https://cdn.vuetifyjs.com/images/lists/5.jpg', 'Britta Holt', 'britaholtT', false));
//    _userList.add(User('https://cdn.vuetifyjs.com/images/lists/1.jpg', 'Ali Connor', '_aconnorX', true));
//    _userList.add(User('https://cdn.vuetifyjs.com/images/lists/2.jpg', 'Alex Freites', 'alex', false));
  }
}

abstract class ListItem {}
class User implements ListItem {
  String avatar;
  String name;
  String username;
  bool followed;

  User(this.avatar, this.name, this.username, this.followed);
}
