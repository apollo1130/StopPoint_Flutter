import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/feed/api/FeedApiService.dart';
import 'package:video_app/feed/models/Comment.dart';
import 'package:video_app/profile/providers/UserProvider.dart';
import 'package:video_app/profile/utils/ProfileHelpers.dart';
import 'package:video_app/profile/widgets/ConfimDeleteDialog.dart';

class CommentsWidget extends StatefulWidget {
  final String answerId;

  CommentsWidget({this.answerId});

  @override
  _CommentsWidgetState createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  Future<dynamic> _getCommentsFuture;
  User _userLogged;
  TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = List<Comment>();
  bool answerMode = false;
  Comment answerComment;
  bool editMode = false;
  Comment editComment;
  GlobalKey _textFieldKey = GlobalKey();
  double bottomOffset;
  var txt = TextEditingController();

  @override
  void initState() {
    _getCommentsFuture = _getComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userLogged = Provider.of<UserProvider>(context, listen: false).userLogged;
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
        centerTitle: true,
        elevation: 1,
      ),
      body: FutureBuilder(
        future: _getCommentsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: <Widget>[
                  _commentsList(),
                  Positioned(
                    bottom: 10,
                    child: Container(
                      key: _textFieldKey,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: _userLogged.avatarImageProvider(),
                          ),
                          Expanded(
                            child: textField(),
                          ),
                          FlatButton(
                            onPressed: _commentController.text.length > 0
                                ? () {
                                    _sendComment();
                                  }
                                : null,
                            child: Text(
                              'Publish',
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border(top: BorderSide(color: Colors.grey[300]))),
                    ),
                  ),
                  _answerMessage(),
                  _EditMessage(),
                ],
              ),
            );
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  textField() {
    if (editMode) {
      return TextField(
        onChanged: (_) {
          setState(() {});
        },
        controller: _commentController,
        decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 10, bottom: 10, top: 10, right: 10),
            hintText: 'Write a comment...'),
      );
    } else {
      return TextField(
        onChanged: (_) {
          setState(() {});
        },
        controller: _commentController,
        decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 10, bottom: 10, top: 10, right: 10),
            hintText: 'Write a comment...'),
      );
    }
  }

  _getComments() async {
    Response response = await FeedApiService().getComments(widget.answerId);

    if (response.statusCode == 200) {
      response.data.forEach((x) {
        _comments.add(Comment.fromJson(x));
      });
    }
    return true;
  }

  _sendComment() async {
    int parenComentId = -1;
    if (editMode) {
      var body = {"id": editComment.id, "body": _commentController.text};
      Response response = await FeedApiService().updateComment(body);
      if (response.statusCode == 200) {
        print('response' + response.toString());
        int index = _comments.indexWhere((element) => element.id == editComment.id);
        editComment.body = _commentController.text;
        _comments[index] = editComment;
      } else {
        print('error');
      }
      setState(() {
        FocusScope.of(context).unfocus();
        _commentController.clear();
        editMode = false;
        answerComment = null;
      });
    } else {
      if (answerMode) {
        if (answerComment.parentComment != null) {
          parenComentId = answerComment.parentComment.id;
        } else {
          parenComentId = answerComment.id;
        }
      }
      var body = {
        "userId": _userLogged.id,
        "answerId": widget.answerId,
        "commentData": {"body": _commentController.text},
        "parentCommentId": parenComentId
      };
      Response response = await FeedApiService().sendComment(body);
      if (response.statusCode == 200) {
        print('response');
        if (parenComentId == -1) {
          _comments.add(Comment.fromJson(response.data));
        } else {
          int parentIndex =
              _comments.indexWhere((element) => element.id == parenComentId);
          _comments[parentIndex].answers.add(Comment.fromJson(response.data));
        }
      } else {
        print('error');
      }
      setState(() {
        FocusScope.of(context).unfocus();
        _commentController.clear();
        answerMode = false;
        answerComment = null;
      });
    }
  }

  /*_sendRapport() async {
    int parenComentId = -1;
    if (editMode) {
      var body = {"id": editComment.id, "body": _commentController.text};
      Response response = await FeedApiService().sendReport(body);
      if (response.statusCode == 200) {
        print('response' + response.toString());
        int index = _comments.indexWhere((element) => element.id == editComment.id);
        editComment.body = _commentController.text;
        _comments[index] = editComment;
      } else {
        print('error');
      }
      setState(() {
        FocusScope.of(context).unfocus();
        _commentController.clear();
        editMode = false;
        answerComment = null;
      });
    } else {
      if (answerMode) {
        if (answerComment.parentComment != null) {
          parenComentId = answerComment.parentComment.id;
        } else {
          parenComentId = answerComment.id;
        }
      }
      var body = {
        "userId": _userLogged.id,
        "answerId": widget.answerId,
        "commentData": {"body": _commentController.text},
        "parentCommentId": parenComentId
      };
      Response response = await FeedApiService().sendComment(body);
      if (response.statusCode == 200) {
        print('response');
        if (parenComentId == -1) {
          _comments.add(Comment.fromJson(response.data));
        } else {
          int parentIndex =
          _comments.indexWhere((element) => element.id == parenComentId);
          _comments[parentIndex].answers.add(Comment.fromJson(response.data));
        }
      } else {
        print('error');
      }
      setState(() {
        FocusScope.of(context).unfocus();
        _commentController.clear();
        answerMode = false;
        answerComment = null;
      });
    }
  }*/

  _commentsList() {
    return Container(
      child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _commentItem(_comments[index]);
          },
          itemCount: _comments.length),
    );
  }

  _commentItem(Comment comment) {
    try {
      print(comment.user.avatar);
      return Padding(
        padding: EdgeInsets.only(top: 0),
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: () async {
                await ProfileHelpers().navigationProfileHelper(context, comment.user.id);
                },
              leading: CircleAvatar(
                radius: 16,
                backgroundImage: comment.user.avatarImageProvider(),
              ),
              title: RichText(
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                          text: comment.user.getFullName(),
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      TextSpan(
                          style: TextStyle(color: Colors.grey[800]),
                          text: ' ' + comment.body),
                    ]),
              ),
              subtitle: Row(
                children: <Widget>[
                  Text(timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(comment.date),
                      locale: 'en_short')),
                  SizedBox(width: 10),
                  _likeButton(comment),
                  // _voteButton(comment, 'upvote', 'Upvote'),/*
                  //                   _likeButton(comment),*/
                  // _voteButton(comment, 'downvote', 'Downvote'),
                ],
              ),
              trailing: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                width: 20,
                height: 20,
                child: iconEdit(comment),
              ),
            ),
            comment.answers.length > 0
                ? _answerItems(comment.answers)
                : SizedBox.shrink(),
          ],
        ),
      );
    } catch (e) {
      return Text("");
    }
  }

  iconEdit(Comment comment) {
    if (_userLogged.id == comment.user.id) {
      return IconButton(
          alignment: Alignment.topRight,
          iconSize: 20,
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.more_horiz),
          onPressed: () {
            showMaterialModalBottomSheet(
              expand: false,
              context: context,
              builder: (context) => Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        child: Center(
                          child: Text(
                            "Comment",
                            style: TextStyle(
                              color: Color(0xFF939598),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                      FlatButton(
                        child: Text('Edit'),
                        onPressed: () async {
                          _Edit(comment);
                          Navigator.pop(context, true);
                        },
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                      FlatButton(
                          onPressed: () {
                            _deleteComment(comment);
                          },
                          child: Text('Delete')),
                      Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                    ],
                  ),
                  height: MediaQuery.of(context).size.height / 3),
            );
          });
    } else {
      return Text("");
    }
  }

  _deleteComment(Comment comment) async {
    var result = await showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: 'Warning!',
        subtitle: 'Are you sure you want to delete this answer ?',
        onDelete: () {
          Navigator.pop(context, true);
        },
      ),
    );
    if (result) {
      Navigator.pop(context);
      Response response =
          await FeedApiService().deleteComment(comment.id.toString());

      if (response.statusCode == 200) {
        int index = _comments.indexWhere((element) => element.id == comment.id);
        _comments.removeAt(index);
        print("response delete " + response.toString());
        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: 'ERROR: Cannot delete comment',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0);
      }
    }
  }

  _Edit(Comment comment) {
    setState(() {
      editMode = true;
      _commentController.text = comment.body;
      editComment = comment;
      bottomOffset = _textFieldKey.currentContext.size.height;
    });
    print('editComment');
  }

  _EditMessage() {
    return Positioned(
      bottom: editMode ? bottomOffset : -400,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[300],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Edit ' + (editMode ? editComment.user.getFullName() : '')),
              GestureDetector(
                onTap: () {
                  setState(() {
                    editMode = false;
                    bottomOffset = _textFieldKey.currentContext.size.height;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    FontAwesomeIcons.times,
                    color: Colors.grey[800],
                    size: 18,
                  ),
                ),
              )
            ],
          )),
    );
  }

  _likeButton(Comment comment) {
    return GestureDetector(
      onTap: () {
        _answer(comment);
      },
      child: Container(
        padding: EdgeInsets.all(0),
        child: Text("reply", style: TextStyle(color: Colors.blue)),
      ),
    );
  }

  _answer(Comment comment) {
    setState(() {
      answerMode = true;
      answerComment = comment;
      bottomOffset = _textFieldKey.currentContext.size.height;
    });
    print('answer');
  }

  _answerMessage() {
    return Positioned(
      bottom: answerMode ? bottomOffset : -400,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[300],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Answer to ' +
                  (answerMode ? answerComment.user.getFullName() : '')),
              GestureDetector(
                onTap: () {
                  setState(() {
                    answerMode = false;
                    bottomOffset = _textFieldKey.currentContext.size.height;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    FontAwesomeIcons.times,
                    color: Colors.grey[800],
                    size: 18,
                  ),
                ),
              )
            ],
          )),
    );
  }

  _answerItems(List<Comment> answers) {
    return Container(
      padding: EdgeInsets.only(left: 80),
      child: ExpandablePanel(
        header: ExpandableButton(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 1,
              color: Colors.grey[400],
            ),
            Container(
              width: 10,
            ),
            Text(
              'See answers (${answers.length})',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            )
          ],
        )),
        expanded: ListView.builder(
            shrinkWrap: true,
            itemCount: answers.length,
            itemBuilder: (BuildContext context, int index) {
              return _commentItem(answers[index]);
            }),
        theme: ExpandableThemeData(hasIcon: false),
      ),
    );
  }

  _voteButton(Comment comment, String voteType, String label) {
    Color iconColor = Colors.grey[700];
    if (voteType == 'upvote') {
      comment.upVotes.forEach((element) {
        if (element.id == _userLogged.id) {
          iconColor = Colors.blue;
        }
      });
    } else {
      comment.downVotes.forEach((element) {
        if (element.id == _userLogged.id) {
          iconColor = Colors.blue;
        }
      });
    }
    return GestureDetector(
      onTap: () {
        _sendVote(comment.id, voteType);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: <Widget>[
            Icon(
              voteType == 'upvote'
                  ? FontAwesomeIcons.solidArrowAltCircleUp
                  : FontAwesomeIcons.solidArrowAltCircleDown,
              size: 12,
              color: iconColor,
            ),
            Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  StringUtils.capitalize(label),
                  style: TextStyle(color: iconColor, fontSize: 12),
                ))
          ],
        ),
      ),
    );
  }

  _sendVote(int commentId, String voteType) async {
    var body = {
      "userId": _userLogged.id,
      "commentId": commentId,
      "voteType": voteType
    };
    Response response = await FeedApiService().sendVote(body);
    if (response.statusCode == 200) {
      _comments.forEach((element) {
        if (element.id == commentId) {
          if (voteType == 'upvote') {
            element.upVotes.add(User(id: _userLogged.id));
            element.downVotes
                .removeWhere((element) => _userLogged.id == element.id);
          } else {
            element.downVotes.add(User(id: _userLogged.id));
            element.upVotes
                .removeWhere((element) => _userLogged.id == element.id);
          }
        }
      });
      setState(() {});
    }
  }
}
