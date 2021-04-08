import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_app/explore/api/ExploreApiService.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class SearchQuestionWidget extends StatefulWidget {
  @override
  _SearchQuestionWidgetState createState() => _SearchQuestionWidgetState();
}

class _SearchQuestionWidgetState extends State<SearchQuestionWidget> {
  SearchBarController _controller = SearchBarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SearchBar<QuestionData> (

            searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
            headerPadding: EdgeInsets.symmetric(horizontal: 10),
            listPadding: EdgeInsets.symmetric(horizontal: 10),
            searchBarController: _controller,
            icon: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Icon(FontAwesomeIcons.arrowLeft, color: Colors.blueGrey,),
            ),
            hintText: 'Search',
            placeHolder: Center(
              child: Text('Write something to start searching', style: TextStyle(color: Colors.blueGrey,)),
            ),
            cancellationWidget: Text("Cancel"),
            emptyWidget: Center(
              child: Text('This question doesn\'t exist yet', style: TextStyle(color: Colors.blueGrey,)),
            ),
            onItemFound: (QuestionData item, int index) {
              return _questionItem(item);
            },
            onSearch: _getQuestions,
            onError: (err) {
                return Center(
                  child: Text('Error on the query, try again.!', style: TextStyle(color: Colors.blueGrey,)),
                );
            },

        ),
      )
    );
  }

  Future<List<QuestionData>> _getQuestions(String text) async {
    List<QuestionData> questions = List<QuestionData>();
    Response response = await ExploreApiService().getQuestionByName(text);
    response.data.forEach((x) {
      return questions.add(QuestionData.fromJson(x));
    });
    return questions;
  }

  _questionItem (QuestionData question) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: (){
          print('GO To question');
        },
        leading: Container(
          width: 20,
          child: Center(
            child: Text(question.interest.icon, style: TextStyle(fontSize: 16),),
          ),
        ),
        title: Text(StringUtils.capitalize(question.text) + '?'),
        trailing: Container(
          width: 20,
          child: Icon(FontAwesomeIcons.chevronRight, color: Colors.blueGrey,),
        ),
      ),
    );
  }
}
