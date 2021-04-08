import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:video_app/core/utils/ApiUrl.dart';

class AuthApiService {
  var _http;
  AuthApiService ({String token}) {
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

  Future<Response> login(loginRequest) async {
    try {

      Response response = await this._http.post(ApiUrl.LOGIN,data: loginRequest);
      print("path ================");
      // print(response. request.path);
      print("path ================2");
      return response;
    } catch (e) {
      return e.response;
    }
  }


  Future<Response> register(registerRequest) async {
    try {

      Response response = await this._http.post(ApiUrl.REGISTER,data: registerRequest);
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> updateUser(user, String userId) async {
    try {

      Response response = await this._http.put(ApiUrl.UPDATE_USER + userId ,data: user);
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> getProfile(String userId) async {
    try {

      Response response = await this._http.get(ApiUrl.USER_PROFILE + userId);
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

}