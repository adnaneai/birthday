import '../entities/birthday_entity.dart';
import '../repositories/birthday_repository.dart';

class ScheduleNotificationUseCase {
  final BirthdayRepository repository;

  ScheduleNotificationUseCase({required this.repository});

  Future<void> call(BirthdayEntity birthday) async {
    try {
      await repository.scheduleNotification(birthday);
    } catch (e) {
      rethrow;
    }
  }
}