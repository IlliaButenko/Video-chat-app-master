import 'dart:convert';

import 'package:OCWA/models/user_model.dart';
import 'package:hive/hive.dart';
part 'message_model.g.dart';

@HiveType(typeId: 1)
class MessageModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  dynamic data;

  @HiveField(3)
  int sender;

  @HiveField(4)
  int receiver;

  @HiveField(5)
  String timestamps;

  @HiveField(6)
  int isSend;

  @HiveField(7)
  int isDeliver;

  @HiveField(8)
  String updatedAt;

  @HiveField(9)
  String createdAt;

  @HiveField(10)
  UserModel fromUser;

  @HiveField(11)
  UserModel toUser;

  @HiveField(12)
  String chatId;

  @HiveField(13)
  int isRead;

  @HiveField(14)
  int status;

  @HiveField(14)
  String avatar;

  @HiveField(16)
  String type;

  @HiveField(17)
  String transferStatus;

  @HiveField(18)
  bool onlineStatus;

  MessageModel(
      {this.chatId,
      this.isRead,
      this.fromUser,
      this.toUser,
      this.content,
      this.sender,
      this.receiver,
      this.isSend,
      this.isDeliver,
      this.timestamps,
      this.createdAt,
      this.updatedAt,
      this.onlineStatus,
      this.type,
      this.status,
      this.id,
      this.data,
      this.transferStatus,
      this.avatar});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
        id: json['id'],
        content: json['content'],
        data: json['data'],
        isSend: json['isSend'],
        status: json['status'],
        isDeliver: json['isDeliver'],
        sender: json['sender'],
        receiver: json['receiver'],
        timestamps: json['timestamps'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        chatId: json['chatId'],
        type: json['type'],
        transferStatus: json['transferStatus'],
        onlineStatus: json['to_user_online_status'] as bool,
        isRead: json['isRead'],
        avatar: json['profileImg'] as String);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "chatId": chatId,
        "isSend": isSend,
        "status": status,
        "isDeliver": isDeliver,
        "isRead": isRead,
        "avatar": avatar,
        "fromUser": fromUser != null
            ? {
                "id": fromUser.id,
                "name": fromUser.name,
                "avatar": fromUser.avatar
              }
            : null,
        "toUser": toUser != null
            ? {"id": toUser.id, "name": toUser.name, "avatar": toUser.avatar}
            : null,
        "type": type,
        "transferStatus": transferStatus,
        "content": content,
        "sender": sender,
        "receiver": receiver,
        "timestamps": timestamps,
        "onlineStatus": onlineStatus,
        'data': data
      };
}
