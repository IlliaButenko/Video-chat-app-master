import 'dart:convert';

import 'package:OCWA/data/services.dart';
import 'package:OCWA/models/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServiceSharedPreferences extends Services {
  @override
  dynamic getValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) ?? null;
  }

  @override
  void setValue(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
  }

  @override
  void removeValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}