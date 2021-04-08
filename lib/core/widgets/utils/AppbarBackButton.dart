import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppbarBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
        width: kToolbarHeight,
        height: kToolbarHeight,
        child: Icon(Icons.arrow_back)//Icon(FontAwesomeIcons.chevronLeft),
      ),
    );
  }
}
