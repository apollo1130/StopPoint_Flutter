import 'dart:collection';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_app/chat/providers/ChatSessionProvider.dart';
import 'package:video_app/profile/widgets/ConfimDeleteDialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/api/AuthApiService.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/auth/social/SocialService.dart';
import 'package:video_app/core/packages/cloudinary/cloudinary_client.dart';
import 'package:video_app/core/packages/cloudinary/models/CloudinaryResponse.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:video_app/core/widgets/SelectInterest.dart';
import 'package:video_app/core/widgets/utils/AppbarBackButton.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/widgets/PushNotificationConfig.dart';
import 'package:video_app/router.dart';
import 'dart:developer';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  User _user;
  bool _isLoading = false;
  var adress;

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<UserProvider>(context).userLogged;
    /*if(_user.address != null){
      adress.text = _user.address.toString()+" ";
    }*/
    // print(_user.toJson());

    return LoadingOverlay(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
                //Icons.keyboard_backspace,
                Icons.arrow_back
                //color: Colors.black,
                //size: 25,
                ),
          ),
          title: Text('Edit Profile'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _saveProfile();
              },
              child: Text('Save'),
            )
          ],
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: FormBuilder(
            key: _fbKey,
            initialValue: {
              'firstname': _user.firstname,
              'lastname': _user.lastname,
              'username': _user.username,
              'bio': _user.bio,
              'job': _user.job,
              'education': _user.education,
              'live': _user.live,
              'privateProfile': _user.privateProfile,
              'notificationEnable': _user.notificationEnable
            },
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    child: GestureDetector(
                      onTap: () {
                        _showPictureOptions();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: _user.avatarImageProvider(),
                            radius: 30,
                          ),
                          Positioned(
                            top: 5,
                            left: MediaQuery.of(context).size.width / 2 + 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.blueAccent[700],
                              radius: 14,
                              child: Icon(
                                FontAwesomeIcons.pencilAlt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  _titleRow('General'),
                  FormBuilderTextField(
                      name: 'firstname',
                      decoration: InputDecoration(
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            FontAwesomeIcons.solidUser,
                            color: Colors.grey[400],
                          ),
                          hintText: 'First name')),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  FormBuilderTextField(
                      name: 'lastname',
                      decoration: InputDecoration(
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            FontAwesomeIcons.solidUser,
                            color: Colors.grey[400],
                          ),
                          hintText: 'Last name')),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  FormBuilderTextField(
                      name: 'username',
                      decoration: InputDecoration(
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            FontAwesomeIcons.solidIdBadge,
                            color: Colors.grey[400],
                          ),
                          hintText: 'Username')),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  FormBuilderTextField(
                      name: 'bio',
                      maxLength: 2000,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            FontAwesomeIcons.infoCircle,
                            color: Colors.grey[400],
                          ),
                          hintText: 'Bio')),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  FormBuilderSwitch(
                    name: 'privateProfile',
                    initialValue: _user.privateProfile,
                    onChanged: (value) {
                      /// TODO add on private account
                      print(value);
                    },
                    title: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.lock, color: Colors.black),
                          VerticalDivider(
                            color: Colors.transparent,
                          ),
                          Text(
                            'Private account',
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),

                  _titleRow('Credentials & Highlights'),
                  FormBuilderTextField(
                      name: 'job',
                      decoration: InputDecoration(
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            FontAwesomeIcons.briefcase,
                            color: Colors.grey[400],
                          ),
                          hintText: 'Job')),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  FormBuilderTextField(
                      name: 'education',
                      decoration: InputDecoration(
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            FontAwesomeIcons.graduationCap,
                            color: Colors.grey[400],
                          ),
                          hintText: 'Education Credential')),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  FormBuilderTextField(
                      name: 'live',
                      decoration: InputDecoration(
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            FontAwesomeIcons.mapMarkerAlt,
                            color: Colors.grey[400],
                          ),
                          hintText: 'State, Country')),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  _titleRow('Edit Topics'),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return SelectInterest();
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'My Interests',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                          ),
                          Icon(
                            FontAwesomeIcons.chevronRight,
                            color: Colors.black,
                            size: 16,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  _titleRow('Notifications'),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return PushNotificationConfig();
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Push Notifications',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                          ),
                          Icon(
                            FontAwesomeIcons.chevronRight,
                            color: Colors.black,
                            size: 16,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  _titleRow('Privacy, Terms, & License Agreement'),
                  GestureDetector(
                    onTap: () {
                      _launchURL('https://stoppoint.com/privacy.html');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Privacy',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            FontAwesomeIcons.externalLinkAlt,
                            size: 16,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchURL('https://stoppoint.com/terms.html');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Terms of Service',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            FontAwesomeIcons.externalLinkAlt,
                            size: 16,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchURL('https://stoppoint.com/licenseagreement.html');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'License Agreement',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            FontAwesomeIcons.externalLinkAlt,
                            size: 16,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
//                  Container(
//                    width: MediaQuery.of(context).size.width,
//                    alignment: Alignment.center,
//                    padding: EdgeInsets.all(15),
//                    child: Column(
//                      children: [
//                        Text(
//                            "Delete your account is irreversible and will result in loss of your account and elimination of your data"),
//                        RaisedButton(
//                            child: Text(
//                              'Delete Account',
//                              style: TextStyle(
//                                  color: Colors.grey[700],
//                                  fontSize: 18,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                            onPressed: _deleteAccount,
//                            shape: RoundedRectangleBorder(
//                                borderRadius: new BorderRadius.circular(30.0))),
//                      ],
//                    ),
//                  ),
                  Container(
                    color: Color(0xffF3F2F7),
                    padding: EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () {
                        _logout();
                      },
                      child: Center(
                        child: Text(
                          'Logout',
                          style:
                              TextStyle(color: Colors.pinkAccent, fontSize: 17),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isLoading: _isLoading,
    );
  }

  _titleRow(String text) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Color(0xffF3F2F7),
      child: Text(
        text,
        style: TextStyle(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  _logout() async {
    LocalStorage _storage = LocalStorage('mainStorage');
    ChatSessionProvider _chatSessionProvider =
        Provider.of<ChatSessionProvider>(context, listen: false);
    _chatSessionProvider.userChatSession = null;
    if (await _storage.ready) {
      _storage.deleteItem('authToken');
      SocialService().logOut();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('auth', (Route<dynamic> route) => false);
    }
  }

  _saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _checkImage(_user.avatar);
      if (_fbKey.currentState.saveAndValidate()) {
        Map<String, dynamic> values =
            HashMap<String, dynamic>.from(_fbKey.currentState.value);
        // values = _fbKey.currentState.value;
        // _fbKey.currentState.value.entries
        //     .forEach((element) => values.addAll({element.key: element.value}));
        // values.removeWhere((key, value) {
        //   if (value is bool || value.length > 1) {
        //     return false;
        //   } else {
        //     return true;
        //   }
        // });
        log(values.toString());
        values['avatar'] = _user.avatar;
        Response response = await AuthApiService().updateUser(values, _user.id);

        log("hello" + response.toString());

        log("hello" + response.extra.toString());

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
              msg: 'The changes were saved successfully',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          Provider.of<UserProvider>(context, listen: false)
              .userLogged
              .updateUser(User.fromJson(response.data));
          await Future.delayed(Duration(milliseconds: 1000));
          FlowRouter.router.pop(context);
        } else {
          Fluttertoast.showToast(
              msg: 'That username already exists. Try another?',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e, s) {
      setState(() {
        _isLoading = false;
      });
      log(e.toString());
      print(s);
    }
  }

  _checkImage(String image) async {
    if (image != null && image.length > 0) {
      if (!image.contains("http://") && !image.contains("https://")) {
        bool uploaded;
        CloudinaryClient client = new CloudinaryClient(ApiUrl.CLOUDINARY_KEY,
            ApiUrl.CLOUDINARY_SECRET, ApiUrl.CLODINARY_CLOUD_NAME);
        try {
          CloudinaryResponse result = await client.uploadImage(image,
              filename: 'avatar', folder: _user.email.split('@')[0]);
          _user.avatar = result.secure_url;
          uploaded = true;
        } catch (e) {
          uploaded = false;
          print(e);
        }

        return uploaded;
      }
    }
  }

  _showPictureOptions() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update profile pictures'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  onTap: () {
                    _pickImage(ImageSource.camera);
                  },
                  leading: Icon(FontAwesomeIcons.camera),
                  title: Text('Camera'),
                  subtitle: Text('Take new picture'),
                ),
                ListTile(
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                  },
                  leading: Icon(FontAwesomeIcons.image),
                  title: Text('Browse'),
                  subtitle: Text('Choose a existing photo'),
                ),
                _user.avatar != null && _user.avatar.length > 0
                    ? ListTile(
                        onTap: () {
                          setState(() {
                            _user.avatar = '';
                            Navigator.pop(context);
                          });
                        },
                        leading: Icon(FontAwesomeIcons.trashAlt),
                        title: Text('Delete'),
                        subtitle: Text('Delete the actual picture'),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          );
        });
  }

  _pickImage(ImageSource source) async {
    var image = await ImagePicker.platform.pickImage(source: source);
    try {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
          compressFormat: ImageCompressFormat.jpg);
      setState(() {
        _user.avatar = croppedFile.path;
      });
      Navigator.pop(context);
    } catch (e) {
      print('Format error');
    }
  }

  _deleteAccount() async {
    var result = await showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: 'Warning!',
        subtitle:
            'Deleting your account is irreversible and will result in loss of your videos and elimination of all your date.',
        onDelete: () async {
          LocalStorage _storage = LocalStorage('mainStorage');

          if (await _storage.ready) {
            _storage.deleteItem('authToken');
            SocialService().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(
                'auth', (Route<dynamic> route) => false);
          }
        },
      ),
    );
    if (result) {}
  }

  _launchURL(String url) async {
    //const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
