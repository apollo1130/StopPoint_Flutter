import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_app/core/widgets/BottomNavigationMenu.dart';

class ContactsPage extends StatefulWidget {

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<String> list = [""];
  static const MethodChannel _channel = const MethodChannel('mobile_number');

  Iterable<Contact> _contacts;
  bool routedPushed = false;
  @override
  void initState() {
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async {
    //Make sure we already have permissions for contacts when we get to this
    //page, so we can just retrieve it
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
      for(var i in _contacts){
        print(i.displayName);
        list.add( i.displayName);
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        /*actions: <Widget>[
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: Search(list));
            },
            icon: Icon(Icons.search),
          )
        ],*/
        centerTitle: true,
        title: (Text('Invite your friends')),
        elevation: 1,
      ),
      body: _contacts != null
      //Build a list view of all contacts, displaying their avatar and
      // display name
          ? ListView.builder(
        itemCount: _contacts?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          Contact contact = _contacts?.elementAt(index);
          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                ? CircleAvatar(
              backgroundImage: MemoryImage(contact.avatar),
            )
                : CircleAvatar(
              child: Text(contact.initials()),
              backgroundColor: Theme.of(context).accentColor,
            ),
            title: Text(contact.displayName ?? ''),
            trailing: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
              ),
              color: Colors.lightBlue,
              onPressed: () async {
                print(contact.phones.first.value);
                String message = "Hi "+ contact.displayName+",  I have an invite to StopPoint and want you to join😊. Here is the link! https://stoppoint.page.link/app";
                List<String> recipents = [contact.phones.first.value];
                _sendSMS(message, recipents);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.userPlus,
                    color: Colors.white,
                    size: 14,
                  ),
                  Container(
                    width: 10,
                    height: 0,
                  ),
                  Text(
                    'Invite',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          );
        },
      )
          : Center(child: const CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationMenu(
        iconColor: Color(0xff252525),
        backgroundColor: Color(0xffFAFAFA),
        selectedIconColor: Color(0xFF3982f3),
        currentIndex: 4,
        routedPushed: (route) {
          setState(() {
            routedPushed = route;
          });
        },
      ),
    );
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }
}

class Search extends SearchDelegate {

  @override
  List<Widget> buildActions(BuildContext context) {

    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  String selectedResult = "";

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(
        child: Text(selectedResult),
      ),
    );
  }

  final List<String> listExample;
  Search(this.listExample);

  List<String> recentList = [""];

  @override
  Widget buildSuggestions(BuildContext context) {

    List<String> suggestionList = [];
    query.isEmpty
        ? suggestionList = recentList //In the true case
        : suggestionList.addAll(listExample.where(
      // In the false case
          (element) => element.contains(query),
    ));

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            suggestionList[index],
          ),
          leading: query.isEmpty ? Icon(Icons.access_time) : SizedBox(),
          onTap: (){
            selectedResult = suggestionList[index];
            showResults(context);
          },
        );
      },
    );
  }
}