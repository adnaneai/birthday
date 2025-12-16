import '../entities/birthday_entity.dart';
import '../repositories/birthday_repository.dart';

class GetBirthdaysUseCase {
  final BirthdayRepository repository;

  GetBirthdaysUseCase({required this.repository});

  Future<List<BirthdayEntity>> call() async {
    try {
      return await repository.getBirthdays();
    } catch (e) {
      rethrow;
    }
  }
}