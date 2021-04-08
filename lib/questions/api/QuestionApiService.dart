import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:video_app/questions/models/QuestionRequest.dart';

class QuestionApiService {
  var _http;
  QuestionApiService () {
    BaseOptions options = new BaseOptions(
      baseUrl: ApiUrl.BASE_URL,
      receiveDataWhenStatusError: true,

    );
    this._http = new Dio(options);
    _http.transformer = FlutterTransformer();
    _http.interceptors.add(LogInterceptor(responseBody: true));
    (_http.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate=(client){
      client.badCertificateCallback=(X509Certificate cert, String host, int port){
        // 默认情况下，这个cert证书是网站颁发机构的证书，并不是网站证书，开发者可以验证一下
        return true; //忽略证书校验
      };
    };
  }

  Future<Response> answerQuestion(body) async {
    try {

      Response response = await this._http.post(ApiUrl.ANSWER_QUESTION, data: body);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getUserRelatedQuestions(String question, String userId) async {
    try {
      Response response = await this._http.post(ApiUrl.GET_RELATED_QUESTIONS, data: {"text": question, "userReceivedId": userId});
      return response;
    } catch (e) {
      return e.response;
    }
  }
  Future<Response> getInterestRelatedQuestions(String question, String interestId) async {
    try {

      Response response = await this._http.post(ApiUrl.GET_RELATED_QUESTIONS, data: {"text": question, "interestReceivedId": interestId});
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> saveForLater(body) async {
    try {

      Response response = await this._http.post(ApiUrl.SAVE_FOR_LATER, data: body);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> archiveQuestion(body) async {
    try {
      Response response = await this._http.post(ApiUrl.ARCHIVE_QUESTION, data: body);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> sendQuestion(QuestionRequest body) async {
    try {
      Response response = await this._http.post(ApiUrl.SEND_QUESTION, data: body);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> sendVideo(QuestionRequest body) async {
    try {
      Response response = await this._http.post(ApiUrl.SEND_VIDEO, data: body);
      return response;
    } catch (e) {
      return e.response;
    }
  }


  Future<Response> deleteQuestion(String questionId) async {
    try {
      Response response = await this._http.delete(ApiUrl.QUESTION, data: {"questionId": questionId});
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> deleteAnswer(String answerId) async {
    try {
      Response response = await this._http.delete(ApiUrl.ANSWER, data: {"answerId": answerId});
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getQuestionById(String questionId, String userId) async {
    try {
      Response response = await this._http.post(ApiUrl.GET_QUESTION_BY_ID , data: {"questionId": questionId, "userId": userId});
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getQuestionInterestById(String questionId) async {
    try {
      Response response = await this._http.get(ApiUrl.QUESTION_INTEREST  + questionId);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getQuestionsByInterest(String interestId, String userId) async {
    try {
      Response response = await this._http.post(ApiUrl.GET_QUESTIONS_BY_INTEREST , data: { "interestId": interestId , "userId": userId});
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> addViewToAnswer(String answerId, String userId) async {
    try {
      Response response = await this._http.post(ApiUrl.ADD_VIEW_COUNT, data: {"answerId": answerId, "userId": userId});
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> updateQuestion(questionJson, String questionId) async {
    try {
      Response response = await this._http.put(ApiUrl.UPDATE_QUESTION + questionId ,data: questionJson);
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> like(String userId, String answerId) async {
    try {
      Response response = await this._http.post(ApiUrl.LIKE_ANSWER , data: {"userId": userId, "answerId":answerId,});
      return response;
    } catch (e) {
      return e.response;
    }
  }
  Future<Response> dislike(String userId, String answerId) async {
    try {
      Response response = await this._http.post(ApiUrl.DISLIKE_ANSWER , data: {"userId": userId, "answerId":answerId,});
      return response;
    } catch (e) {
      return e.response;
    }
  }
}