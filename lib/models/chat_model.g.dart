// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatModelAdapter extends TypeAdapter<ChatModel> {
  @override
  final int typeId = 0;

  @override
  ChatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatModel(
      userId: fields[1] as int,
      id: fields[0] as String,
      name: fields[2] as String,
      message: fields[4] as String,
      timestamps: fields[3] as String,
      isRead: fields[9] as int,
      isSend: fields[10] as int,
      isDeliver: fields[11] as int,
      unreadMessage: fields[12] as int,
      sender: fields[13] as int,
      type: fields[7] as String,
      fromId: fields[14] as int,
      toId: fields[15] as int,
      status: fields[16] as int,
      data: fields[5] as dynamic,
      transferStatus: fields[8] as String,
      avatar: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChatModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.timestamps)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.data)
      ..writeByte(6)
      ..write(obj.avatar)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.transferStatus)
      ..writeByte(9)
      ..write(obj.isRead)
      ..writeByte(10)
      ..write(obj.isSend)
      ..writeByte(11)
      ..write(obj.isDeliver)
      ..writeByte(12)
      ..write(obj.unreadMessage)
      ..writeByte(13)
      ..write(obj.sender)
      ..writeByte(14)
      ..write(obj.fromId)
      ..writeByte(15)
      ..write(obj.toId)
      ..writeByte(16)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
