import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/providers/CoreProvider.dart';
import 'package:video_app/core/widgets/utils/AppbarBackButton.dart';
import 'package:video_app/profile/api/ProfileApiService.dart';
import 'package:video_app/profile/models/Interest.dart';
import 'package:video_app/profile/providers/UserProvider.dart';

import 'CustomChip.dart';

class SelectInterest extends StatefulWidget {
  @override
  _SelectInterestState createState() => _SelectInterestState();
}

class _SelectInterestState extends State<SelectInterest> {
  List<Interest>  interests= List<Interest>();
  CoreProvider _coreProvider;
  List<String> _interestSelectedIds= List<String>();
  bool somethingSelect = false;
  bool loaded = false;
  User _userLogged;
  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context).userLogged;
    _loadList();
    return Scaffold(
      appBar: AppBar(
        leading: _interestSelectedIds.length > 0 ? AppbarBackButton() : Container(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                'Receive personalized recommendations',
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 1,
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
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        child: RaisedButton(

          color: Colors.blueGrey[800],
          onPressed: somethingSelect ? (){
            _saveInterests();
          }:null,
          padding: EdgeInsets.all(00),
          child: Text('NEXT', style: TextStyle(color: Colors.white, fontSize: 20),),
        ),
      ),
    );
  }

  _loadList() async  {
    if(!loaded) {
      _coreProvider = Provider.of<CoreProvider>(context);
      _userLogged.interests.forEach((element) {
        _interestSelectedIds.add(element.id);
      });
      interests = _coreProvider.interests;
      loaded = true;
    }

  }

  _listInterest(){
    return interests.map((e) {
      return CustomChip(
        icon: e.icon,
        label: e.label,
        selected: _interestSelectedIds.contains(e.id),
        onSelect: (){
          if(_interestSelectedIds.contains(e.id)) {
            _interestSelectedIds.remove(e.id);
          }else {
            _interestSelectedIds.add(e.id);
          }
          if(_interestSelectedIds.length > 0) {
            setState(() {
              somethingSelect =true;
            });
          }else {
            setState(() {
              somethingSelect =false;
            });
          }
        }
      ,);
    }).toList();
  }

  _saveInterests() async{
    LocalStorage _storage = LocalStorage('mainStorage');
    Response response = await ProfileApiService().addInterest(_interestSelectedIds, _userLogged.id);
    if(response.statusCode == 200) {
      if(await _storage.ready) {
        _storage.setItem('interestSelected', true);
        _userLogged.interests.clear();
        interests.forEach((interest) {
          if(_interestSelectedIds.contains(interest.id)) {
            _userLogged.interests.add(interest);
          }
        });
        Navigator.of(context).pushNamedAndRemoveUntil('feed', (Route<dynamic> route) => false);
      }

    }
  }
}

