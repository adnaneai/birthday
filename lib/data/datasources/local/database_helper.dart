import 'package:hive/hive.dart';
import '../../models/birthday_model.dart';

class DatabaseHelper {
  static Future<void> ensureInitialized() async {
    // Cette méthode doit être appelée UNE SEULE FOIS au démarrage de l'app
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BirthdayModelAdapter());
    }

    if (!Hive.isBoxOpen('birthdays')) {
      await Hive.openBox<BirthdayModel>('birthdays'); // IMPORTANT: Spécifier le type
    }
  }

  Box<BirthdayModel> get _box {
    return Hive.box<BirthdayModel>('birthdays'); // IMPORTANT: Spécifier le type
  }

  Future<void> addBirthday(BirthdayModel birthday) async {
    await _box.put(birthday.id, birthday); // Stockez l'objet directement
  }

  Future<List<BirthdayModel>> getAllBirthdays() async {
    return _box.values.toList(); // Pas besoin de conversion
  }

  Future<BirthdayModel?> getBirthdayById(String id) async {
    return _box.get(id);
  }

  Future<void> updateBirthday(BirthdayModel birthday) async {
    await _box.put(birthday.id, birthday);
  }

  Future<void> deleteBirthday(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  Future<List<BirthdayModel>> getUpcomingBirthdays(int days) async {
    final allBirthdays = await getAllBirthdays(); // AJOUT: 'await' manquant
    final now = DateTime.now();

    return allBirthdays.where((birthday) {
      final nextBirthday = _getNextBirthday(birthday.birthDate);
      final daysUntil = nextBirthday.difference(now).inDays;
      return daysUntil <= days && daysUntil >= 0;
    }).toList();
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