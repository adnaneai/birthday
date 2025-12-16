import '../entities/birthday_entity.dart';
import '../repositories/birthday_repository.dart';

class AddBirthdayUseCase {
  final BirthdayRepository repository;

  AddBirthdayUseCase({required this.repository});

  Future<BirthdayEntity> call(BirthdayEntity birthday) async {
    try {
      return await repository.addBirthday(birthday);
    } catch (e) {
      rethrow;
    }
  }
}