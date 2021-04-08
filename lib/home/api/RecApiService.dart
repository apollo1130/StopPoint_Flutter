import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:video_app/core/utils/ApiUrl.dart';
import 'package:video_app/questions/models/QuestionRequest.dart';

class RecApiService {
  var _http;
  RecApiService () {
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

  Future<Response> getSuggestedList(String userId) async {
    try {
      Response response = await this._http.get(ApiUrl.GET_SUGGESTED_AND_RECENT + userId);
      return response;
    } catch (e) {
      return e.response;
    }
  }
  Future<Response> sentQuestion(QuestionRequest body) async {
    try {

      Response response = await this._http.post(ApiUrl.SEND_QUESTION, data: body);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> answerQuestion(body) async {
    try {

      Response response = await this._http.post(ApiUrl.ANSWER_QUESTION, data: body);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getUser(stringSearch) async {
    try {

      Response response = await this._http.post(ApiUrl.GET_USERS_BY_QUERY, data:{'query':stringSearch});
      return response;
    } catch (e) {
      return e.response;
    }
  }



}