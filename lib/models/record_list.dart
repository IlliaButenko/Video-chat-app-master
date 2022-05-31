import 'package:OCWA/models/user_model.dart';

import 'record.dart';

class RecordList {
  List<UserModel> records = new List();

  RecordList({
    this.records
  });

  factory RecordList.fromJson(List<dynamic> parsedJson) {

    List<UserModel> records = new List<UserModel>();

    records = parsedJson.map((i) => UserModel.fromJson(i)).toList();

    return new RecordList(
      records: records,
    );
  }
}