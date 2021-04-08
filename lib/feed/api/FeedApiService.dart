import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:video_app/core/utils/ApiUrl.dart';

class FeedApiService {
  var _http;
  FeedApiService () {
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

  Future<Response> getFeed(String userId, int skip, int limit) async {
    try {
      Response response = await this._http.post(ApiUrl.GET_FEED , data: {"userId": userId, "skip": skip, "limit":limit});
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getSuggestedListForFollow(String userId) async {
    try {

      Response response = await this._http.get(ApiUrl.GET_USER_FOR_FOLLOW + userId);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> share(String userId, String questionId) async {
    try {

      Response response = await this._http.post(ApiUrl.SHARE_QUESTION , data: {"userId": userId, "questionId":questionId,});
      return response;
    } catch (e) {
      return e.response;
    }
  }
  Future<Response> upVote(String userId, String answerId) async {
    try {

      Response response = await this._http.post(ApiUrl.UPVOTE_ANSWER , data: {"userId": userId, "answerId":answerId,});
      return response;
    } catch (e) {
      return e.response;
    }
  }
  Future<Response> downVote(String userId, String answerId) async {
    try {

      Response response = await this._http.post(ApiUrl.DOWNVOTE_ANSWER , data: {"userId": userId, "answerId":answerId,});
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> sendComment(request) async {
    try {
      Response response = await this._http.post(ApiUrl.SEND_COMMENT , data: request);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> sendReport(request) async {
    try {
      Response response = await this._http.post(ApiUrl.SEND_REPORT , data: request);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getComments(String answerId) async {
    try {
      Response response = await this._http.get(ApiUrl.GET_COMMENTS  + answerId);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> updateComment(request) async {
    try {

      Response response = await this._http.post(ApiUrl.UPDATE_COMMENTS , data: request);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> deleteComment(String CommentId) async {
    try {
      Response response = await this._http.get(ApiUrl.DELETE_COMMENTS+CommentId);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> sendVote(request) async {
    try {

      Response response = await this._http.post(ApiUrl.COMMENT_VOTE, data: request);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> deleteVote(request) async {
    try {

      Response response = await this._http.delete(ApiUrl.COMMENT_VOTE, data: request);
      return response;
    } catch (e) {
      return e.response;
    }
  }
}