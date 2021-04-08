import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:video_app/core/utils/ApiUrl.dart';

class InboxApiService {
  var _http;
  InboxApiService () {
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

  Future<Response> getUserNotifications(String userId) async {
    try {

      Response response = await this._http.get(ApiUrl.GET_USER_NOTIFICATIONS + userId);
      return response;
    } catch (e) {
      return e.response;
    }
  }



}