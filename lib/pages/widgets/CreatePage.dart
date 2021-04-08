import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_app/router.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  int _actualStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stepper(
          currentStep: _actualStep,
          type: StepperType.horizontal,
          controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
            return Row(
              children: <Widget>[
                Container(
                  child: null,
                ),
                Container(
                  child: null,
                ),
              ],
            );
          },
          steps: [
            Step(
              title: Text('Info'),
              content: _firstPage(),
            ),
            Step(
              title: Text('Info'),
              content: _secondPage(),
            )
          ],
        ),
      ),
      bottomNavigationBar:  Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: _buttonsOptions(),
      ),
    );
  }

  _firstPage() {
    return  Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child:Column(
        children: <Widget>[
          Text('Crate a Page', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Text(
              'Pages are collections and communities for just about anuything. Create a Page that matches your interests',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Container(height: 20),
          Align(
            alignment: Alignment.topLeft,
            child: RichText(
              text: TextSpan(
                  children: [
                    TextSpan(text: 'Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                    TextSpan(text: ' *', style: TextStyle(color: Colors.red[900], fontSize: 20, fontWeight: FontWeight.w900),),
                  ]
              ),
            ),
          ),
          Container(height: 10,),
          Material(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            child: TextField(
              
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  alignLabelWithHint: true,


                  hintText: 'e.g. Travels, Climbing Club...',
                filled: true,
                fillColor: Colors.white,
                border:OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide(color: Colors.transparent)
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide(color: Colors.transparent)
                ),
                
              ),
            ),
          ),
          Container(height: 30),
          Align(
            alignment: Alignment.topLeft,
            child: RichText(
              text: TextSpan(
                  children: [
                    TextSpan(text: 'About', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                    TextSpan(text: ' *', style: TextStyle(color: Colors.red[900], fontSize: 20, fontWeight: FontWeight.w900),),
                  ]
              ),
            ),
          ),
          Container(height: 10,),
          Material(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            child: TextField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  alignLabelWithHint: true,
                  hintText: '1-line description of your space',
                filled: true,
                fillColor: Colors.white,
                border:OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide(color: Colors.transparent)
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide(color: Colors.transparent)
                ),
              ),
            ),
          ),
          Container(height: 60,),

        ],
      ),
    );
  }

  _secondPage(){
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.blueGrey[400], size: 30,),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide(
                    color: Colors.grey[300]
                  )
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide(
                        color: Colors.grey[300]
                    )
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide(
                        color: Colors.grey[300]
                    )
                ),
                hintText: 'Search for a topic'
              ),
            ),
          )
        ],
      )
    );
  }

  _buttonsOptions() {
    if (_actualStep == 0) {
      return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            onPressed: (){
              FlowRouter.router.pop(context);
            },
            child: Text('Cancel'.toUpperCase()),
          ),
          RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            color: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            onPressed: (){
              setState(() {
                _actualStep =1;
              });
            },
            child: Text('Continue'.toUpperCase(), style: TextStyle(color: Colors.white),),
          ),
        ],
      );
    }else {
      return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            onPressed: (){
              setState(() {
                _actualStep=0;
              });
            },
            child: Text('Back'.toUpperCase()),
          ),
          RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            color: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            onPressed: (){
              FlowRouter.router.pop(context);
            },
            child: Text('Finish'.toUpperCase(), style: TextStyle(color: Colors.white),),
          ),
        ],
      );
    }
  }


}
