import 'package:equatable/equatable.dart';
import '../../../domain/entities/birthday_entity.dart';

abstract class BirthdayEvent extends Equatable {
  const BirthdayEvent();

  @override
  List<Object> get props => [];
}

class LoadBirthdaysEvent extends BirthdayEvent {}

class AddBirthdayEvent extends BirthdayEvent {
  final BirthdayEntity birthday;

  const AddBirthdayEvent({required this.birthday});

  @override
  List<Object> get props => [birthday];
}

class UpdateBirthdayEvent extends BirthdayEvent {
  final BirthdayEntity birthday;

  const UpdateBirthdayEvent({required this.birthday});

  @override
  List<Object> get props => [birthday];
}

class DeleteBirthdayEvent extends BirthdayEvent {
  final String id;

  const DeleteBirthdayEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class ToggleNotificationEvent extends BirthdayEvent {
  final String id;
  final bool enabled;

  const ToggleNotificationEvent({
    required this.id,
    required this.enabled,
  });

  @override
  List<Object> get props => [id, enabled];
}