import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnotherQuestionDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    double  modalHeight = MediaQuery.of(context).size.height * 0.35;
    return Center(
      child: Material(
          color: Colors.transparent,
          child: Container(
              margin: EdgeInsets.all(20.0),
              height: modalHeight,
              decoration: ShapeDecoration(
                  color:  Colors.blueGrey[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    height: modalHeight *0.70,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.blueGrey[200],
                          radius: 16,
                          child: Icon(FontAwesomeIcons.check, color: Colors.white, size: 24,),
                        ),
                        Divider(color: Colors.transparent,),
                        Text('Awesome!', style: TextStyle(color: Colors.blueGrey[700], fontSize: 18, fontWeight: FontWeight.bold),),
                        Divider(color: Colors.transparent,),
                        Expanded(child: Text('Your question was sent successfully', style: TextStyle(color: Colors.blueGrey[700]),)),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    width: MediaQuery.of(context).size.width - 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        OutlineButton(
                          onPressed: (){
                            Navigator.pushNamedAndRemoveUntil(context, 'feed', (route) => false);
                          },
                          borderSide: BorderSide(color: Colors.blueGrey[700]),
                          child: Text('Go to feed', style: TextStyle(color: Colors.blueGrey[700]),),
                        ),
                        RaisedButton(
                          onPressed: (){
                            Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
                          },
                          color: Colors.blueGrey[700],
                          child: Text('Another question', style: TextStyle(color: Colors.white),),
                        )
                      ],
                    ),
                  )
                ],
              )
          )
      ),
    );
  }
}
