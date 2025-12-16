import '../../domain/entities/birthday_entity.dart';
import '../../domain/repositories/birthday_repository.dart';
import '../datasources/local/birthday_local_datasource.dart';
import '../mappers/birthday_mapper.dart';
import '../models/birthday_model.dart';
import '../../core/utils/notification_utils.dart';
import 'package:uuid/uuid.dart';

class BirthdayRepositoryImpl implements BirthdayRepository {
  final BirthdayLocalDataSource localDataSource;
  final Uuid _uuid = const Uuid();

  BirthdayRepositoryImpl({required this.localDataSource});

  @override
  Future<List<BirthdayEntity>> getBirthdays() async {
    try {
      final models = await localDataSource.getBirthdays();
      return models.map(BirthdayMapper.modelToEntity).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BirthdayEntity> addBirthday(BirthdayEntity entity) async {
    try {
      final now = DateTime.now();
      final model = BirthdayModel(
        id: _uuid.v4(),
        name: entity.name,
        birthDate: entity.birthDate,
        relationship: entity.relationship,
        phone: entity.phone,
        email: entity.email,
        notes: entity.notes,
        notificationsEnabled: entity.notificationsEnabled,
        createdAt: now,
        updatedAt: now,
      );

      await localDataSource.addBirthday(model);
      final createdEntity = BirthdayMapper.modelToEntity(model);

      // Programmer la notification si activée
      if (createdEntity.notificationsEnabled) {
        await scheduleNotification(createdEntity);
      }

      return createdEntity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateBirthday(BirthdayEntity entity) async {
    try {
      final model = BirthdayMapper.entityToModel(entity);
      final updatedModel = BirthdayModel(
        id: model.id,
        name: model.name,
        birthDate: model.birthDate,
        relationship: model.relationship,
        phone: model.phone,
        email: model.email,
        notes: model.notes,
        notificationsEnabled: model.notificationsEnabled,
        createdAt: model.createdAt,
        updatedAt: DateTime.now(),
      );

      await localDataSource.updateBirthday(updatedModel);

      // Mettre à jour la notification
      await cancelNotification(entity.id);
      if (entity.notificationsEnabled) {
        await scheduleNotification(entity);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteBirthday(String id) async {
    try {
      await cancelNotification(id);
      await localDataSource.deleteBirthday(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> scheduleNotification(BirthdayEntity birthday) async {
    try {
      final nextBirthday = _getNextBirthday(birthday.birthDate);
      final notificationTime = DateTime(
        nextBirthday.year,
        nextBirthday.month,
        nextBirthday.day,
        9, // 9h du matin
      );

      await NotificationUtils.scheduleBirthdayNotification(
        id: birthday.id.hashCode,
        title: "🎂 Anniversaire aujourd'hui!",
        body: "C'est l'anniversaire de ${birthday.name}!",
        scheduledDate: notificationTime,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelNotification(String id) async {
    try {
      await NotificationUtils.cancelNotification(id.hashCode);
    } catch (e) {
      rethrow;
    }
  }

  DateTime _getNextBirthday(DateTime birthDate) {
    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }

    return nextBirthday;
  }
}