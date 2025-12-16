import '../../models/birthday_model.dart';
import '../local/database_helper.dart';
import '../birthday_data_source.dart'; // AJOUT: Nouvel import

abstract class BirthdayLocalDataSource implements BirthdayDataSource { // MODIF: Ajout "implements BirthdayDataSource"
  Future<List<BirthdayModel>> getBirthdays();
  Future<void> addBirthday(BirthdayModel birthday);
  Future<void> updateBirthday(BirthdayModel birthday);
  Future<void> deleteBirthday(String id);
  Future<List<BirthdayModel>> getUpcomingBirthdays(int days);
}

class BirthdayLocalDataSourceImpl implements BirthdayLocalDataSource {
  final DatabaseHelper _databaseHelper;

  BirthdayLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<BirthdayModel>> getBirthdays() async {
    return await _databaseHelper.getAllBirthdays();
  }

  @override
  Future<void> addBirthday(BirthdayModel birthday) async {
    await _databaseHelper.addBirthday(birthday);
  }

  @override
  Future<void> updateBirthday(BirthdayModel birthday) async {
    await _databaseHelper.updateBirthday(birthday);
  }

  @override
  Future<void> deleteBirthday(String id) async {
    await _databaseHelper.deleteBirthday(id);
  }

  @override
  Future<List<BirthdayModel>> getUpcomingBirthdays(int days) async {
    return await _databaseHelper.getUpcomingBirthdays(days);
  }

  // AJOUT: Nouvelle méthode pour l'interface BirthdayDataSource
  @override
  Stream<List<BirthdayModel>> birthdaysStream() {
    // Implémentation simple pour le mobile avec Hive
    // Retourne un stream qui émet la liste des anniversaires une fois
    return Stream.fromFuture(getBirthdays());
  }
}