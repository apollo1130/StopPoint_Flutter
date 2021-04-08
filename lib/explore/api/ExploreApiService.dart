import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:video_app/core/utils/ApiUrl.dart';

class ExploreApiService {
  var _http;
  ExploreApiService ({String token}) {
    BaseOptions options = new BaseOptions(
      baseUrl: ApiUrl.BASE_URL,
      receiveDataWhenStatusError: true,

    );
    this._http = new Dio(options);
    if (token != null) {
      _http.options.headers["Authorization"] = "Bearer " +token;
    }
    _http.transformer = FlutterTransformer();
    _http.interceptors.add(LogInterceptor(responseBody: true));
    (_http.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate=(client){
      client.badCertificateCallback=(X509Certificate cert, String host, int port){
        // 默认情况下，这个cert证书是网站颁发机构的证书，并不是网站证书，开发者可以验证一下
        return true; //忽略证书校验
      };
    };
  }


  Future<Response> getSearchItems(String text) async {
    try {

      Response response = await this._http.post(ApiUrl.GET_EXPLORE_ITEMS , data: {"text" : text});
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getPreviewExplore(String userId) async {
    try {

      Response response = await this._http.get(ApiUrl.GET_PREVIEW_EXPLORE + userId);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getQuestionByName(String text) async {
    try {

      Response response = await this._http.get(ApiUrl.GET_QUESTION_BY_TEXT + text);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getInterestWithVideos() async {
    try {

      Response response = await this._http.get(ApiUrl.INTERESTS_WITH_VIDEOS );
      return response;
    } catch (e) {
      return e.response;
    }
  }
}