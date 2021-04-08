import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:video_app/core/utils/ApiUrl.dart';

class ChatApiService {
  var _http;
  ChatApiService() {
    BaseOptions options = new BaseOptions(
      baseUrl: ApiUrl.BASE_URL,
      receiveDataWhenStatusError: true,
    );
    this._http = new Dio(options);
    _http.transformer = FlutterTransformer();
    _http.interceptors.add(LogInterceptor(responseBody: true));
    (_http.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // 默认情况下，这个cert证书是网站颁发机构的证书，并不是网站证书，开发者可以验证一下
        return true; //忽略证书校验
      };
    };
  }

  Future<Response> getChats(String username, maxConversations, maxMessages, String kind) async {
    try {
      Response response = await this._http.get(ApiUrl.GET_CHATS, queryParameters: {
        "username": username,
        "maxConversations": maxConversations.toString(),
        "maxMessages": maxMessages.toString(),
        "kind": kind
      });
      return response;
    } catch (e) {
      return e.response;
    }
  }

  Future<Response> getChatByContact(String usernameUUID, String contactUUID, limit, offset, kind) async {
    try {
      Response response = await this._http.get(ApiUrl.GET_CHATS_BY_USER, queryParameters: {
        "username": usernameUUID,
        "contact": contactUUID,
        "limit": limit.toString(),
        "offset": offset.toString(),
        "kind": kind
      });
      return response;
    } catch (e) {
      return e.response;
    }
  }
  Future<Response> deleteChatByContact( String contactUUID, kind) async {
    try {
      Response response = await this._http.get(ApiUrl.DELETE_CHATS_BY_USER, queryParameters: {
        "contact": contactUUID,
        "kind": kind
      });
      return response;
    } catch (e) {
      return e.response;
    }
  }
}
