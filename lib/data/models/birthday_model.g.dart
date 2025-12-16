// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birthday_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BirthdayModelAdapter extends TypeAdapter<BirthdayModel> {
  @override
  final int typeId = 0;

  @override
  BirthdayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BirthdayModel(
      id: fields[0] as String,
      name: fields[1] as String,
      birthDate: fields[2] as DateTime,
      relationship: fields[3] as String?,
      phone: fields[4] as String?,
      email: fields[5] as String?,
      notes: fields[6] as String?,
      notificationsEnabled: fields[7] as bool,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BirthdayModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.birthDate)
      ..writeByte(3)
      ..write(obj.relationship)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.notificationsEnabled)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BirthdayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
