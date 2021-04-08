import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:video_app/core/utils/ApiUrl.dart';

class ProfileApiService {
  Dio _http;
  ProfileApiService ({String token}) {
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

  Future<Response> addInterest(List<String> interestsList, String userId) async {
    try {

      Response response = await this._http.post(ApiUrl.USER_ADD_INTERESTS + userId ,data: interestsList);
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getInterests() async {
    try {

      Response response = await this._http.get(ApiUrl.GET_INTERESTS);
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

  Future<Response> follow(String userId, String memberId) async {
    try {

      Response response = await this._http.post(ApiUrl.FOLLOW_USER, data: {"userId": userId, "memberId": memberId});
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> acceptFollow(String userId, String memberId) async {
    try {

      Response response = await this._http.post(ApiUrl.ACCEPT_FOLLOW, data: {"userId": userId, "memberId": memberId});
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> declineFollow(String userId, String memberId) async {
    try {

      Response response = await this._http.post(ApiUrl.DECLINE_FOLLOW, data: {"userId": userId, "memberId": memberId});
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> unfollow(String userId, String memberId) async {
    try {

      Response response = await this._http.post(ApiUrl.UNFOLLOW_USER, data: {"userId": userId, "memberId": memberId});
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> followInterest(String userId, String interestId) async {
    try {

      Response response = await this._http.post(ApiUrl.FOLLOW_INTEREST, data: {"userId": userId, "interestId": interestId});
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> unFollowInterest(String userId, String interestId) async {
    try {

      Response response = await this._http.post(ApiUrl.UNFOLLOW_INTEREST, data: {"userId": userId, "interestId": interestId});
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> blockUser(String userId, String memberId) async {
    try {

      Response response = await this._http.post(ApiUrl.BLOCK_USER, data: {"userId": userId, "memberId": memberId});
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> unblockUser(String userId, String memberId) async {
    try {

      Response response = await this._http.post(ApiUrl.UNBLOCK_USER, data: {"userId": userId, "memberId": memberId});
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> blockUserMessage(String userId, String memberId) async {
    try {

      Response response = await this._http.post(ApiUrl.BLOCK_USER_MESSAGE, data: {"userId": userId, "memberId": memberId});
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

  Future<Response> unblockUserMessage(String userId, String memberId) async {
    try {

      Response response = await this._http.post(ApiUrl.UNBLOCK_USER_MESSAGE, data: {"userId": userId, "memberId": memberId});
      return response;
    } catch (e) {
      print(e);
      return e.response;
    }
  }

}