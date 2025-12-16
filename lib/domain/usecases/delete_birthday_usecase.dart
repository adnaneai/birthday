import '../repositories/birthday_repository.dart';

class DeleteBirthdayUseCase {
  final BirthdayRepository repository;

  DeleteBirthdayUseCase({required this.repository});

  Future<void> call(String id) async {
    try {
      await repository.deleteBirthday(id);
    } catch (e) {
      rethrow;
    }
  }
}