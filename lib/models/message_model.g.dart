// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 1;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      chatId: fields[12] as String,
      isRead: fields[13] as int,
      fromUser: fields[10] as UserModel,
      toUser: fields[11] as UserModel,
      content: fields[1] as String,
      sender: fields[3] as int,
      receiver: fields[4] as int,
      isSend: fields[6] as int,
      isDeliver: fields[7] as int,
      timestamps: fields[5] as String,
      createdAt: fields[9] as String,
      updatedAt: fields[8] as String,
      onlineStatus: fields[18] as bool,
      type: fields[16] as String,
      status: fields[14] as int,
      id: fields[0] as String,
      data: fields[2] as dynamic,
      transferStatus: fields[17] as String,
      avatar: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.sender)
      ..writeByte(4)
      ..write(obj.receiver)
      ..writeByte(5)
      ..write(obj.timestamps)
      ..writeByte(6)
      ..write(obj.isSend)
      ..writeByte(7)
      ..write(obj.isDeliver)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.fromUser)
      ..writeByte(11)
      ..write(obj.toUser)
      ..writeByte(12)
      ..write(obj.chatId)
      ..writeByte(13)
      ..write(obj.isRead)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.avatar)
      ..writeByte(16)
      ..write(obj.type)
      ..writeByte(17)
      ..write(obj.transferStatus)
      ..writeByte(18)
      ..write(obj.onlineStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
