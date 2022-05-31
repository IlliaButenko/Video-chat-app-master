import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/chat_model.dart';
import 'package:OCWA/models/general_model.dart';
import 'package:OCWA/models/message_model.dart';
import 'package:OCWA/models/response.dart';
import 'package:OCWA/models/transaction_model.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/ui/dialog/loading.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkUtil {
//  static final BASE_URL = "http://10.211.55.5/oudomsup/api/app-api/app";
  static String root = "http://202.137.134.58/api/app-api/app";
  static String serverIP = 'http://202.137.134.58';
  static String media = 'http://202.137.134.58:8090';
  static const int SERVER_PORT = 4002;
  static String connectUrl = '$serverIP:$SERVER_PORT';
  static const headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json'
  };
  static NetworkUtil _instance = new NetworkUtil.internal();

  NetworkUtil.internal();

  static Services services = new StorageServiceSharedPreferences();

  factory NetworkUtil() => _instance;

  static GlobalKey<State> _keyLoader = new GlobalKey<State>();

  Map<String, dynamic> error(title, message) {
    return {title: title, message: message};
  }

  static Future<dynamic> get(String url) {
    try {
      return http.get(url, headers: headers).then((response) {
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw new Future.error('error' + response.body.toString());
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<ResponseModel> post(String url, dynamic data) {
    try {
      return http
          .post(root + url, headers: headers, body: data)
          .then((response) {
        if (response.statusCode == 200) {
          return new ResponseModel.fromJson(jsonDecode(response.body));
        } else {
          throw new Future.error('error' + response.body.toString());
        }
      });
    } catch (e) {
      print(url + e.toString());
    }
  }

  static Future<List<TransferHistoryModel>> getTransferContact(
      String url) async {
    try {
      dynamic id = await services.getValue(ACCOUNT_ID);
      final data = jsonEncode({"id": id});
      final response =
          await http.post(root + url, headers: headers, body: data);
      if (response.statusCode == 200) {
        // List<TransferHistoryModel> list = parseResponse(response.body);
        // return list;
        return compute(parseResponse, response.body);
      } else {
        print('error');
        return List<TransferHistoryModel>();
      }
    } catch (e) {
      print('error catch: ' + e.toString());
      return List<TransferHistoryModel>();
    }
  }

  static List<TransferHistoryModel> parseResponse(String responseBody) {
    final parsed =
        json.decode(responseBody)['data'].cast<Map<String, dynamic>>();
    return parsed
        .map<TransferHistoryModel>(
            (json) => TransferHistoryModel.fromJson(json))
        .toList();
  }

  static Future<List<Transaction>> getTransaction(String url) async {
    try {
      dynamic id = await services.getValue(ACCOUNT_ID);
      final data = jsonEncode({"id": id});
      final response =
          await http.post(root + url, headers: headers, body: data);
      if (response.statusCode == 200) {
         List<Transaction> list = parseResponseTransaction(response.body);
         return list;
      } else {
        return List<Transaction>();
      }
    } catch (e) {
      print('error catch: ' + e.toString());
      return List<Transaction>();
    }
  }

  static List<Transaction> parseResponseTransaction(String responseBody) {
    final parsed =
        json.decode(responseBody)['data'].cast<Map<String, dynamic>>();
    return parsed
        .map<Transaction>((json) => Transaction.fromJson(json))
        .toList();
  }

  // Chat
  static Future<List<ChatModel>> getChatList(String url) async {
    try {
      dynamic id = await services.getValue("id");
      final response = await http.get(connectUrl + url + id, headers: headers);
      if (response.statusCode == 200) {
        // List<ChatModel> list = parseResponseChatModel(response.body);
        // return list;
        return compute(parseResponseChatModel, response.body);
      } else {
        print('error: ${response.body}');
        return List<ChatModel>();
      }
    } catch (e) {
      print('error catch: ' + e.toString());
      return List<ChatModel>();
    }
  }

  static List<ChatModel> parseResponseChatModel(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<ChatModel>((json) => ChatModel.fromJson(json)).toList();
  }

  // Chat Transfer
  static Future<ResponseModel> chatTransfer(String url, dynamic data) async {
    try {
      final response =
          await http.post(connectUrl + url, headers: headers, body: data);
      if (response.statusCode == 200) {
        if (response.body != 'error') {
          return ResponseModel.fromJson(jsonDecode(response.body));
        } else {
          return null;
        }
      } else {
        print('error: ${response.body}');
        return new ResponseModel();
      }
    } catch (e) {
      print('error catch: ' + e.toString());
      return new ResponseModel();
    }
  }

  static Future<List<MessageModel>> getMessageList(String url) async {
    try {
      dynamic id = await services.getValue("id");
      final data = jsonEncode({"id": id});
      final response =
          await http.post(root + url, headers: headers, body: data);
      if (response.statusCode == 200) {
        // List<MessageModel> list = parseResponseMessageModel(response.body);
        // return list;
        return compute(parseResponseMessageModel, response.body);
      } else {
        print('error');
        return List<MessageModel>();
      }
    } catch (e) {
      print('error catch: ' + e.toString());
      return List<MessageModel>();
    }
  }

  static List<MessageModel> parseResponseMessageModel(String responseBody) {
    final parsed =
        json.decode(responseBody)['data'].cast<Map<String, dynamic>>();
    return parsed
        .map<MessageModel>((json) => MessageModel.fromJson(json))
        .toList();
  }

  static Future<List<UserModel>> getUserList(String url) async {
    try {
      dynamic id = await services.getValue("id");
      final data = jsonEncode({"id": id});
      final response =
          await http.post(root + url, headers: headers, body: data);
      if (response.statusCode == 200) {
        // List<UserModel> list = parseResponseUserModel(response.body);
        // return list;
        return compute(parseResponseUserModel, response.body);
      } else {
        log('error: ${response.body}');
        return List<UserModel>();
      }
    } catch (e) {
      print('error catch: ' + e.toString());
      return List<UserModel>();
    }
  }

  static List<UserModel> parseResponseUserModel(String responseBody) {
    final parsed =
        json.decode(responseBody)['data'].cast<Map<String, dynamic>>();
    return parsed.map<UserModel>((json) => UserModel.fromJson(json)).toList();
  }
}
