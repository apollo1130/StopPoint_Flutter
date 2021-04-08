import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/widgets/BottomNavigationMenu.dart';
import 'package:video_app/core/widgets/CustomDrop.dart';

import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/Widgets/CameraWidget.dart';
import 'package:video_app/questions/Widgets/QuestionCard.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class QuestionsWidget extends StatefulWidget {
  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionsWidget> {
  LocalStorage _storage = LocalStorage('mainStorage');
  int _actualIndex = 0;
  int actualItems;
  List<double> yOffset = List<double>();
  List<double> containerWidth = List<double>();
  List<String> images = [
    'https://images.pexels.com/photos/870711/pexels-photo-870711.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
    'https://images.pexels.com/photos/326055/pexels-photo-326055.jpeg?cs=srgb&dl=close-up-of-leaf-326055.jpg&fm=jpg',
    'https://images.pexels.com/photos/45853/grey-crowned-crane-bird-crane-animal-45853.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'
  ];
  CardController controller = CardController();
  bool animateActive = false;
  int _animatedIndex;
  int step = 0;
  String _selectedFilterQuestion = 'All questions';

  GlobalKey cardTarget = GlobalKey();
  List<TargetFocus> targets = List();
  double rotationRad = 0;
  List<QuestionData> _userQuestions = List<QuestionData>();
  List<QuestionData> _actualList = List<QuestionData>();
  User _userLogged;
  bool questionsLoaded = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _loadQuestions();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            iconSize: 16,
            icon: Icon(FontAwesomeIcons.stream, color: Colors.black),
            onPressed: () {}),
        title: Text(
          'Questions',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,

      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.grey[100],
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Divider(color: Colors.transparent, height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Trending Questions',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Theme(
                          data: ThemeData(
                            canvasColor: Color(0xff2c3e50),
                          ),
                          child: CustomDrop(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Transform.rotate(
                                    angle: rotationRad,
                                    child: AnimatedContainer(
                                      padding: EdgeInsets.only(right: 2),
                                      duration: Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.arrow_drop_down_circle,
                                        size: 16,
                                      ),
                                    )),
                                Text(
                                  _selectedFilterQuestion,
                                  style: TextStyle(fontSize: 20),
                                )
                              ],
                            ),
                            options: [
                              DropdownMenuItem(
                                child: Text('All questions'),
                                value: 'all',
                              ),
                              DropdownMenuItem(
                                  child: Text('User asked'),
                                  value: 'userAsked'),
                              DropdownMenuItem(
                                  child: Text('Answer later'),
                                  value: 'answerLater'),
                              DropdownMenuItem(
                                  child: Text('The app questions'),
                                  value: 'appQuestions'),
                            ],
                            onSelect: (DropdownMenuItem item) {
                              _filterQuestion(item);
                            },
                            onOpen: (bool open) {
                              setState(() {
                                rotationRad = open ? 3.14159 : 0;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                                width: 5,
                                height: 48,
                                margin: EdgeInsets.only(right: 8),
                                color: Colors.blueAccent),
                            Expanded(
                                child: Text(
                                    'Awesome, your friend(s) are waiting for a response',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic)))
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _actualList.length > 0
                          ? Swiper(
                              key: cardTarget,
                              itemWidth: double.infinity,
                              itemHeight:
                                  MediaQuery.of(context).size.height * 0.57,
                              layout: SwiperLayout.TINDER,
                              itemBuilder: (BuildContext context, int index) {
                                return SimpleGestureDetector(
                                    onVerticalSwipe: _onVerticalSwipe,
                                    swipeConfig: SimpleSwipeConfig(
                                        verticalThreshold: 20.0,
                                        horizontalThreshold: 4.0,
                                        swipeDetectionBehavior:
                                            SwipeDetectionBehavior
                                                .continuousDistinct),
                                    child: AnimatedContainer(
                                        onEnd: () {
                                          if (animateActive) {
                                            setState(() {
                                              _actualList
                                                  .removeAt(_animatedIndex);
                                              animateActive = false;
                                              _loadContainers();
                                            });
                                          }
                                        },
                                        width: 300,
                                        transform: Matrix4.translationValues(
                                            0, yOffset[index], 0),
                                        duration: Duration(milliseconds: 750),
                                        child: QuestionCard(
                                          question: _actualList[index],
                                          parent: this,
                                        )));
                              },
                              onIndexChanged: (int index) {
                                _actualIndex = index;
                              },
                              itemCount: _actualList.length,
//            pagination:  SwiperPagination(),
//            control:  SwiperControl(),
                            )
                          : Container(
                              child: Center(
                                child: Text('No question yet'),
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder(
            future: _storage.ready,
            builder: (BuildContext context, snapshot) {
              return _overlayTutorial();
            },
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationMenu(
        iconColor: Color(0xff252525),
        backgroundColor: Color(0xffFAFAFA),
        selectedIconColor: Color(0xFF3982f3),
        currentIndex: 2,
      ),
    );
  }

  void _onVerticalSwipe(SwipeDirection direction) {
    _animatedIndex = _actualIndex;
    if (direction == SwipeDirection.up) {
      print("here is question Wid");
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return CameraWidget(question: _actualList[_actualIndex]);
      }));
      questionsLoaded = false;
    } else {

      print("here is question Wid else");
      _saveForLater(_actualList[_actualIndex]);
      setState(() {
        yOffset[_animatedIndex] = MediaQuery.of(context).size.height;
        animateActive = true;
      });
    }
  }

  update() {
    setState(() {});
  }

  _overlayTutorial() {
    print("The value of the item is: ${_storage.getItem('questionTutorial')}");
    if (_storage.getItem('questionTutorial') == null) {
      if (step == 0) {
        return GestureDetector(
          onTap: () {
            setState(() {
              step = 1;
            });
          },
          child: Container(
            padding: EdgeInsets.all(20),
            color: Colors.black87,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    "Swipe right/left to view more questions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Container(
                      width: 200,
                      height: 100,
                      child: FlareActor(
                        "lib/assets/animations/swipeH.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        animation: 'swipe',
                        color: Colors.white,
                      ),
                    )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Tap to next',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        );
      } else if (step == 1) {
        return GestureDetector(
          onTap: () {
            setState(() {
              step = 2;
              _storage.setItem('questionTutorial', true);
            });
          },
          child: Container(
            padding: EdgeInsets.all(20),
            color: Colors.black87,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    "Swipe up to answer the question now and down to answer the question later",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0,
                        decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Container(
                      width: 100,
                      height: 200,
                      child: FlareActor(
                        "lib/assets/animations/swipeV.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        animation: 'swipe',
                        color: Colors.white,
                      ),
                    )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Tap to next',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    } else {
      return SizedBox.shrink();
    }
  }

  _loadQuestions() {
    if (!questionsLoaded) {
      actualItems = images.length;
      _actualList.clear();
      _userLogged = Provider.of<UserProvider>(context).userLogged;
      if (_userLogged.questionsReceived != null) {
        _userQuestions.addAll(_userLogged.questionsReceived);
      }
      _userQuestions.removeWhere((element) {
        return element.answer != null;
      });
      _actualList.addAll(_userQuestions);
      _loadContainers();
      questionsLoaded = true;
    }
  }

  _filterQuestion(DropdownMenuItem item) {
    _actualList.clear();
    String op = item.value;
    switch (op) {
      case 'userAsked':
        _userQuestions.forEach((e) {
          if ((e.saveForLater == null && e.appQuestion == null) ||
              (!e.saveForLater && !e.appQuestion)) {
            _actualList.add(e);
          }
        });
        break;
      case 'answerLater':
        _userQuestions.forEach((e) {
          if (e.saveForLater != null && e.saveForLater) {
            _actualList.add(e);
          }
        });
        break;
      case 'appQuestions':
        _userQuestions.forEach((e) {
          if (e.appQuestion != null && e.appQuestion) {
            _actualList.add(e);
          }
        });
        break;
      case 'all':
        _actualList.addAll(_userQuestions);
        break;
    }
    setState(() {
      _loadContainers();
      _selectedFilterQuestion = (item.child as Text).data;
    });
  }

  _saveForLater(QuestionData question) async {
    Response response =
        await QuestionApiService().saveForLater({"questionId": question.id});

    if (response.statusCode == 200) {
      _userQuestions.forEach((element) {
        if (element.id == question.id) {
          element.saveForLater = true;
        }
      });
    }
  }

  _loadContainers() {
    yOffset.clear();
    yOffset.addAll(_actualList.map((e) {
      return 0.0;
    }));
    containerWidth.addAll(_actualList.map((e) {
      return 300;
    }));
  }

  archive() {
    String questionId = _actualList[_actualIndex].id;
    _actualList.removeAt(_actualIndex);
    int indexFound = -1;
    for (int i = 0; i < _userQuestions.length; i++) {
      if (_userQuestions[i].id == questionId) {
        indexFound = i;
      }
    }
    if (indexFound != -1) {
      _userQuestions.removeAt(indexFound);
    }

    _loadContainers();
    setState(() {});
  }
}
