import 'dart:convert';
import 'dart:io';
import 'package:OCWA/models/response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class Services {
  dynamic getValue(String key);
  void setValue(String key, dynamic value);
  void removeValue(String key);
}
