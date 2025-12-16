import '../../domain/entities/birthday_entity.dart';
import '../models/birthday_model.dart';

class BirthdayMapper {
  static BirthdayEntity modelToEntity(BirthdayModel model) {
    return BirthdayEntity(
      id: model.id,
      name: model.name,
      birthDate: model.birthDate,
      relationship: model.relationship,
      phone: model.phone,
      email: model.email,
      notes: model.notes,
      notificationsEnabled: model.notificationsEnabled,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static BirthdayModel entityToModel(BirthdayEntity entity) {
    return BirthdayModel(
      id: entity.id,
      name: entity.name,
      birthDate: entity.birthDate,
      relationship: entity.relationship,
      phone: entity.phone,
      email: entity.email,
      notes: entity.notes,
      notificationsEnabled: entity.notificationsEnabled,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}