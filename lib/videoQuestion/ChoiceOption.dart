import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_app/questions/ask/AskQuestionFast.dart';
import 'package:video_app/videoQuestion/AddVideo.dart';

import '../router.dart';

class ChoiceOption extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ChoiceOption> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              iconSize: 16,
              icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.black),
              onPressed: () {
                FlowRouter.router.pop(context);
              }),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Container(
          color: Colors.white,
          child: ListView(children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return Addvideo();
                  }));
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.circular(20))),
                  width: double.maxFinite,
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Record and upload a video",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "share your video with the word",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.video_call_outlined,
                        color: Colors.blue,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child:InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return AskQuestionFast();
                      }));
                },
                child: Container(
                padding: EdgeInsets.all(20),
                decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.circular(20))),
                width: double.maxFinite,
                height: 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Ask a Question",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "your question will be answered by someone ",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.mic,
                      color: Colors.blue,)
                  ],
                ),
              ),
            ),),
          ]),
        )));
  }
}
