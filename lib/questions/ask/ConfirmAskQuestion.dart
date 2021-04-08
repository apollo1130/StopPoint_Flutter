import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/feed/widgets/QuestionDetailsWidget.dart';
import 'package:video_app/feed/widgets/QuestionInterestDetails.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/questions/api/QuestionApiService.dart';
import 'package:video_app/questions/ask/AnotherQuestionDialog.dart';
import 'package:video_app/questions/models/QuestionData.dart';
import 'package:video_app/questions/models/QuestionRequest.dart';

class ConfirmAskQuestion extends StatefulWidget {
  final QuestionData question;
  final String userId;
  final String interestId;
  ConfirmAskQuestion({this.question, this.userId, this.interestId});

  @override
  _ConfirmAskQuestionState createState() => _ConfirmAskQuestionState();
}

class _ConfirmAskQuestionState extends State<ConfirmAskQuestion> {
  List<QuestionData> similarQuestions = List<QuestionData>();
  User _userLogged;
  @override
  Widget build(BuildContext context) {
    _userLogged =  Provider.of<UserProvider>(context, listen:false).userLogged;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: Icon(Icons.arrow_back)//Icon(FontAwesomeIcons.times),
          ),
        ),
        title: Text('Question'),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: _getSimilarQuestions(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _main();
            }else {
              return Center(child: CircularProgressIndicator());
            }
          }
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        child: RaisedButton(
          onPressed: (){
            _sendQuestion();
          },
          color: Colors.blue,
          child: Text('Submit', style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }

  _main() {
    return Container(
      padding: EdgeInsets.all(20),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Text('Your question', style: TextStyle(color: Colors.grey, fontSize: 12),),
          Text(widget.question.text + '?',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), ),
          Divider(color: Colors.transparent,),
          Row(
            children: [
              Icon(FontAwesomeIcons.checkCircle, color: Colors.blue,size: 16,),
              Container(width: 10,),
              Text('We found similar questions: ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey), ),
            ],
          ),
          Divider(color: Colors.transparent),
          Expanded(
            child: _similarQuestions(),
          )
        ],
      ),
    );
  }

  _similarQuestions() {
    return Container(
      child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return _questionItem( similarQuestions[index]);
          },
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemCount: similarQuestions.length
      ),
    );
  }

  _questionItem(QuestionData question) {
    return ListTile(
      onTap: (){
        Navigator.push(context,
            MaterialPageRoute(
                builder: (BuildContext context) {
                  if(widget.userId !=  null ) {
                    return QuestionDetailsWidget(
                      question: question,
                      needFetch: true,
                    );
                  }else {
                    return QuestionInterestDetailsWidget(
                      question: question,
                    );
                  }
                }
            )
        );
      },
      title: Text(question.text + '?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
      subtitle: _answerInformation(question),
      trailing: Container(
        width: 83,
        child: Row(
          children: [
            Text('View answers', style: TextStyle(fontSize: 10),),
            Container(width: 5,),
            Icon(FontAwesomeIcons.chevronRight, size: 14)
          ],
        ),
      ),
    );
  }

  Future<List<QuestionData>> _getSimilarQuestions() async  {
    var response;
    if (widget.userId != null){
      print('############### ${widget.question.text}  ### ${widget.userId}');
      response = await QuestionApiService().getUserRelatedQuestions(widget.question.text,widget.userId);
    }else {
      print('####**########### ${widget.question.text}  ### ${widget.interestId}');
      response = await QuestionApiService().getInterestRelatedQuestions(widget.question.text,widget.interestId);
    }

    if (response.statusCode == 200){
      response.data.forEach( (x) {
        similarQuestions.add(QuestionData.fromJson(x));
      });
    }
    return similarQuestions;
  }

  _sendQuestion() async  {

    print("widget.question.privacy");
    print(widget.question.text);
    QuestionRequest _request = QuestionRequest();
    if(widget.userId != null) {
      _request.type = QuestionType.USER_QUESTION;
      _request.userReceiverId = widget.userId;
    }else {
      _request.type = QuestionType.GENERAL_QUESTION;
      _request.interestId = widget.interestId;
    }
    _request.userSenderId = _userLogged.id;
    _request.questionData = widget.question;
    Response response =  await QuestionApiService().sendQuestion(_request);
    if (response.statusCode == 200 ) {
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 2);
    }else if(response.statusCode == 422){
      Fluttertoast.showToast(
          msg: 'The same question was sent to this user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  _answerInformation(QuestionData question){

    if(widget.userId != null) {
      return Text(question.answer != null ? 'Has answer': 'Not answered yet', style: TextStyle(fontSize: 11),);
    }else {
      return Text(question.answers.length > 0 ? question.answers.length.toString() + ' Answers': 'Not answered yet' , style: TextStyle(fontSize: 11),);
    }
  }

}
