import '../entities/birthday_entity.dart';

abstract class BirthdayRepository {
  Future<List<BirthdayEntity>> getBirthdays();
  Future<BirthdayEntity> addBirthday(BirthdayEntity birthday);
  Future<void> updateBirthday(BirthdayEntity birthday);
  Future<void> deleteBirthday(String id);
  Future<void> scheduleNotification(BirthdayEntity birthday);
  Future<void> cancelNotification(String id);
  Stream<List<BirthdayEntity>> birthdaysStream();

}