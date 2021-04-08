import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class ConfidentialityScreen extends StatefulWidget {
  String resultat;
  ConfidentialityScreen(this.resultat);
  @override
  _ConfidentialityScreenState createState() => _ConfidentialityScreenState();
}

class _ConfidentialityScreenState extends State<ConfidentialityScreen> {
  int languageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.resultat == "Public"){
      languageIndex = 0;
    }else{
      languageIndex = 1;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confidentiality')),
      body: SettingsList(
        sections: [
          SettingsSection(tiles: [
            SettingsTile(
              title: "Public",
              trailing: trailingWidget(0),
              onTap: () {
                changeLanguage(0);
                Navigator.pop(context, "Public");
              },
            ),
            SettingsTile(
              title: "Anonymous",
              trailing: trailingWidget(1),
              onTap: () {
                changeLanguage(1);
                Navigator.pop(context, "Anonymous");
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget trailingWidget(int index) {
    return (languageIndex == index)
        ? Icon(Icons.check, color: Colors.blue)
        : Icon(null);
  }

  void changeLanguage(int index) {
    setState(() {
      languageIndex = index;
    });
  }
}