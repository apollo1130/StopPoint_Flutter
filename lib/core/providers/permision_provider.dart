

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_app/invitation/ContactsPage.dart';
import 'package:video_app/questions/Widgets/CameraWidget.dart';
import 'package:video_app/questions/models/QuestionData.dart';


class PermisionProvider extends ChangeNotifier {



  Future<bool> getCameraPermission(context, QuestionData question) async{
    try {
      bool restricted;
      bool restrictedMicro;
      Permission permission  = Permission.camera;
      Permission permissionMicroPhone  = Permission.microphone;
      bool grant = await permission.isGranted;
      bool grantMicro = await permissionMicroPhone.isGranted;
      bool undetermined = await permission.isLimited;
      bool undeterminedMicro = await permissionMicroPhone.isLimited;
      bool denied = await permission.isDenied;
      bool deniedMicro = await permissionMicroPhone.isDenied;
      if(Platform.isIOS){
         restricted = await permission.isRestricted;
         restrictedMicro = await permissionMicroPhone.isRestricted;
      }else{
         restricted = await permission.isPermanentlyDenied;
         print('restriced');
         print(restricted);
         restrictedMicro = await permissionMicroPhone.isPermanentlyDenied;
      }

      if (restricted || restrictedMicro){
       await _requestAgainOpenAppSetting(context,'Camera and Microphone');
        _navigateCamera(permissionMicroPhone,permission,context,question);
      }

      if(undetermined || undeterminedMicro){
        await  _requestPermission(permission);
        await _requestPermission(permissionMicroPhone);
        _navigateCamera(permissionMicroPhone,permission,context,question);
      }

      if(!grant || !grantMicro){
        await _requestPermission(permission);
        await _requestPermission(permissionMicroPhone);
        await _navigateCamera(permissionMicroPhone,permission,context,question);
      }else{
        print('calling');
        _navigateCamera(permissionMicroPhone,permission,context,question);
      }

      if(denied || deniedMicro){
        print("erroroororororor");
        if(!Platform.isAndroid){
          await _requestAgainOpenAppSetting(context, 'Camera and Microphone');
          await _navigateCamera(permissionMicroPhone,permission,context,question);
        }else{
//          await _requestPermission(permission);
//          await _requestPermission(permissionMicroPhone);
//          _navigateCamera(permissionMicroPhone,permission,context,question);
        }
      }

    }catch(e){
      return false;
    }
  }


  _navigateCamera(Permission permissionMicroPhone,Permission permission,context,q)async{
    bool grantCam = await permission.isGranted;
    bool grantMicro = await permissionMicroPhone.isGranted;
    if(grantCam && grantMicro){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder:
                  (BuildContext
              context) {
                return CameraWidget(
                    question: q);
              }));
    }
  }



  Future<bool> getContactPermission(context)async{
    try{
      bool restricted;
      Permission permission  = Permission.contacts;
      bool grant = await permission.isGranted;
      bool undetermined = await permission.isLimited;
      bool denied = await permission.isDenied;
      if(Platform.isIOS){
        restricted = await permission.isRestricted;
      }else{
        restricted = await permission.isPermanentlyDenied;
      }

      if (restricted){
        await _requestAgainOpenAppSetting(context,'Contacts');
        _navigateContacts(permission,context);
      }

      if(undetermined){
        await _requestPermission(permission);
        _navigateContacts(permission,context);
      }

      if(!grant){
        await _requestPermission(permission);
        _navigateContacts(permission,context);
      }else{
        print('calling');
        _navigateContacts(permission,context);
      }

      if(denied){
        if(!Platform.isAndroid){
          await _requestAgainOpenAppSetting(context,'Contacts');
          _navigateContacts(permission,context);
        }
      }

    }catch(e){
      return false;
    }
  }


  _navigateContacts(Permission permission,context)async{
    bool grantCam = await permission.isGranted;
    if(grantCam){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder:
                  (BuildContext
              context) {
                return ContactsPage(
                    );
              }));
    }
  }

  Future<bool> _requestPermission(Permission permission) async{
    final status = await permission.request();
    return status.isGranted;
  }




  Future _requestAgainOpenAppSetting(context,String namePermission) async{
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text('Allow app $namePermission Permission'),
          content: Text(
              'This app needs $namePermission access'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Deny'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: Text('Settings'),
              onPressed: (){
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        ));
  }
}