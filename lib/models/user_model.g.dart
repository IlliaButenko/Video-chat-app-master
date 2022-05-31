// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 2;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as int,
      accountId: fields[1] as String,
      name: fields[2] as String,
      avatar: fields[3] as String,
      username: fields[4] as String,
      firstName: fields[5] as String,
      lastName: fields[6] as String,
      password: fields[7] as String,
      email: fields[8] as String,
      phone: fields[9] as String,
      mobile: fields[10] as String,
      address: fields[11] as String,
      code: fields[14] as double,
      friendStatus: fields[17] as dynamic,
      customerType: fields[15] as dynamic,
      description: fields[13] as String,
      occupation: fields[12] as String,
      actionUserId: fields[18] as int,
      token: fields[19] as String,
      created: fields[16] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.accountId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.firstName)
      ..writeByte(6)
      ..write(obj.lastName)
      ..writeByte(7)
      ..write(obj.password)
      ..writeByte(8)
      ..write(obj.email)
      ..writeByte(9)
      ..write(obj.phone)
      ..writeByte(10)
      ..write(obj.mobile)
      ..writeByte(11)
      ..write(obj.address)
      ..writeByte(12)
      ..write(obj.occupation)
      ..writeByte(13)
      ..write(obj.description)
      ..writeByte(14)
      ..write(obj.code)
      ..writeByte(15)
      ..write(obj.customerType)
      ..writeByte(16)
      ..write(obj.created)
      ..writeByte(17)
      ..write(obj.friendStatus)
      ..writeByte(18)
      ..write(obj.actionUserId)
      ..writeByte(19)
      ..write(obj.token);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
