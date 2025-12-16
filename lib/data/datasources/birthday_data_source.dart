// lib/data/datasources/birthday_data_source.dart
import '../models/birthday_model.dart';

abstract class BirthdayDataSource {
  Future<List<BirthdayModel>> getBirthdays();
  Future<void> addBirthday(BirthdayModel birthday);
  Future<void> updateBirthday(BirthdayModel birthday);
  Future<void> deleteBirthday(String id);
  Future<List<BirthdayModel>> getUpcomingBirthdays(int days);
  Stream<List<BirthdayModel>> birthdaysStream(); // NOUVEAU pour Firebase
}