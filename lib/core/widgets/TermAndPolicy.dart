import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: RichText (
          textAlign: TextAlign.center,
          text: TextSpan(
              text:'By signing up or logging in, you shall agree to the StopPoint',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12
              ),
              children: [
                TextSpan(text: " "),
                TextSpan(text: "Terms of Service", style: TextStyle(color: Colors.blue[700]), recognizer: TapGestureRecognizer()..onTap = () {
                  _launchUrl('https://stoppoint.com/terms.html');
                }),
                TextSpan(text:","),TextSpan(text: " "),
                TextSpan(text: "Privacy Policy", style: TextStyle(color: Colors.blue[700]), recognizer: TapGestureRecognizer()..onTap = () {
                  _launchUrl('https://stoppoint.com/privacy.html');
                }),
                TextSpan(text:", and"),TextSpan(text: " "),
                TextSpan(text: "License Agreement.", style: TextStyle(color: Colors.blue[700]), recognizer: TapGestureRecognizer()..onTap = () {
                  _launchUrl('https://stoppoint.com/licenseagreement.html');
  }),
              ]
          ),
        )
    );
  }

  _launchUrl(String url) async {
    print('launch');
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
