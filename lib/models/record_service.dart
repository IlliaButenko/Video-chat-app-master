import 'dart:async';
import 'dart:convert';
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/record_list.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:http/http.dart' as http;

class RecordService {
  static Services services = new StorageServiceSharedPreferences();
  static String type = 'new';
  Future<String> _loadRecordsAsset() async {
    dynamic id = await services.getValue("id");
    final data = jsonEncode({"id": id});
    final response =
    await http.post(NetworkUtil.root + '/customer/all/' + type, headers: NetworkUtil.headers, body: data);
    return response.body;
  }

  Future<RecordList> loadRecords() async {
    String jsonString = await _loadRecordsAsset();
    final jsonResponse = json.decode(jsonString)['data'];
    RecordList records = new RecordList.fromJson(jsonResponse);
    return records;
  }

  static List<UserModel> parseResponseUserModel(String responseBody) {
    final parsed =
    json.decode(responseBody)['data'].cast<Map<String, dynamic>>();
    return parsed
        .map<UserModel>((json) => UserModel.fromJson(json))
        .toList();
  }
}