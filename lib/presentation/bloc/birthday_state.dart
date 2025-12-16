import 'package:equatable/equatable.dart';
import '../../../domain/entities/birthday_entity.dart';

abstract class BirthdayState extends Equatable {
  const BirthdayState();

  @override
  List<Object> get props => [];
}

class BirthdayInitial extends BirthdayState {}

class BirthdayLoading extends BirthdayState {}

class BirthdayLoaded extends BirthdayState {
  final List<BirthdayEntity> birthdays;

  const BirthdayLoaded({required this.birthdays});

  @override
  List<Object> get props => [birthdays];
}

class BirthdayError extends BirthdayState {
  final String message;

  const BirthdayError({required this.message});

  @override
  List<Object> get props => [message];
}

class BirthdayAdded extends BirthdayState {
  final BirthdayEntity birthday;

  const BirthdayAdded({required this.birthday});

  @override
  List<Object> get props => [birthday];
}

class BirthdayDeleted extends BirthdayState {
  final String id;

  const BirthdayDeleted({required this.id});

  @override
  List<Object> get props => [id];
}

class BirthdayUpdated extends BirthdayState {
  final BirthdayEntity birthday;

  const BirthdayUpdated({required this.birthday});

  @override
  List<Object> get props => [birthday];
}