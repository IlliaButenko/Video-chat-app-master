import 'package:json_annotation/json_annotation.dart';

// will be generated later
part 'response.g.dart';

@JsonSerializable()
class ResponseModel {
  final String status;
  final String message;
  final dynamic data;

  ResponseModel({this.status, this.message, this.data});

  factory ResponseModel.fromJson(Map<String, dynamic> json) => _$ResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseModelToJson(this);
}
