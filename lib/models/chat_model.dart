import 'dart:convert';
import 'package:hive/hive.dart';
part 'chat_model.g.dart';

@HiveType(typeId: 0)
class ChatModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  int userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String timestamps;

  @HiveField(4)
  String message;

  @HiveField(5)
  dynamic data;

  @HiveField(6)
  String avatar;

  @HiveField(7)
  String type;

  @HiveField(8)
  String transferStatus;

  @HiveField(9)
  int isRead;

  @HiveField(10)
  int isSend;

  @HiveField(11)
  int isDeliver;

  @HiveField(12)
  int unreadMessage;

  @HiveField(13)
  int sender;

  @HiveField(14)
  int fromId;

  @HiveField(15)
  int toId;

  @HiveField(16)
  int status;

  ChatModel(
      {this.userId,
      this.id,
      this.name,
      this.message,
      this.timestamps,
      this.isRead,
      this.isSend,
      this.isDeliver,
      this.unreadMessage,
      this.sender,
      this.type,
      this.fromId,
      this.toId,
      this.status,
      this.data,
      this.transferStatus,
      this.avatar});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
        userId: json['userId'] is String
            ? int.parse(json['userId'])
            : json['userId'],
        id: json['id'],
        name: json['name'] as String,
        message: json['message'] as String,
        data: json['data'] as String,
        timestamps: json['timestamps'] as String,
        isRead: json['isRead'],
        isSend: json['isSend'],
        isDeliver: json['isDeliver'],
        status: json['status'],
        unreadMessage: json['unreadMessage'] is String
            ? int.parse(json['unreadMessage'])
            : json['unreadMessage'],
        sender: json['sender'] is String
            ? int.parse(json['sender'])
            : json['sender'],
        fromId: json['fromId'] is String
            ? int.parse(json['fromId'])
            : json['fromId'],
        toId: json['toId'] is String ? int.parse(json['toId']) : json['toId'],
        type: json['type'] as String,
        transferStatus: json['transferStatus'] as String,
        avatar: json['avatar'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'name': name,
      'message': message,
      'data': data,
      'timestamps': timestamps,
      'isRead': isRead,
      'isSend': isSend,
      'isDeliver': isDeliver,
      'status': status,
      'unreadMessage': unreadMessage,
      'sender': sender,
      'type': type,
      'fromId': fromId,
      'toId': toId,
      'transferStatus': transferStatus,
      'avatar': avatar
    };
  }
}
