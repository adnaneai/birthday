import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_birthdays_usecase.dart';
import '../../../domain/usecases/add_birthday_usecase.dart';
import '../../../domain/usecases/delete_birthday_usecase.dart';
import '../../../domain/usecases/schedule_notification_usecase.dart';
import 'birthday_event.dart';
import 'birthday_state.dart';

class BirthdayBloc extends Bloc<BirthdayEvent, BirthdayState> {
  final GetBirthdaysUseCase getBirthdaysUseCase;
  final AddBirthdayUseCase addBirthdayUseCase;
  final DeleteBirthdayUseCase deleteBirthdayUseCase;
  final ScheduleNotificationUseCase scheduleNotificationUseCase;

  BirthdayBloc({
    required this.getBirthdaysUseCase,
    required this.addBirthdayUseCase,
    required this.deleteBirthdayUseCase,
    required this.scheduleNotificationUseCase,
  }) : super(BirthdayInitial()) {
    on<LoadBirthdaysEvent>(_onLoadBirthdays);
    on<AddBirthdayEvent>(_onAddBirthday);
    on<UpdateBirthdayEvent>(_onUpdateBirthday);
    on<DeleteBirthdayEvent>(_onDeleteBirthday);
    on<ToggleNotificationEvent>(_onToggleNotification);
  }

  Future<void> _onLoadBirthdays(
      LoadBirthdaysEvent event,
      Emitter<BirthdayState> emit,
      ) async {
    emit(BirthdayLoading());
    try {
      final birthdays = await getBirthdaysUseCase();
      emit(BirthdayLoaded(birthdays: birthdays));
    } catch (e) {
      emit(BirthdayError(message: 'Erreur lors du chargement: $e'));
    }
  }

  Future<void> _onAddBirthday(
      AddBirthdayEvent event,
      Emitter<BirthdayState> emit,
      ) async {
    try {
      final addedBirthday = await addBirthdayUseCase(event.birthday);
      emit(BirthdayAdded(birthday: addedBirthday));

      // Recharger la liste
      add(LoadBirthdaysEvent());
    } catch (e) {
      emit(BirthdayError(message: 'Erreur lors de l\'ajout: $e'));
    }
  }

  Future<void> _onUpdateBirthday(
      UpdateBirthdayEvent event,
      Emitter<BirthdayState> emit,
      ) async {
    try {
      // Mettre à jour la notification
      await scheduleNotificationUseCase(event.birthday);
      emit(BirthdayUpdated(birthday: event.birthday));

      // Recharger la liste
      add(LoadBirthdaysEvent());
    } catch (e) {
      emit(BirthdayError(message: 'Erreur lors de la mise à jour: $e'));
    }
  }

  Future<void> _onDeleteBirthday(
      DeleteBirthdayEvent event,
      Emitter<BirthdayState> emit,
      ) async {
    try {
      await deleteBirthdayUseCase(event.id);
      emit(BirthdayDeleted(id: event.id));

      // Recharger la liste
      add(LoadBirthdaysEvent());
    } catch (e) {
      emit(BirthdayError(message: 'Erreur lors de la suppression: $e'));
    }
  }

  Future<void> _onToggleNotification(
      ToggleNotificationEvent event,
      Emitter<BirthdayState> emit,
      ) async {
    try {
      emit(BirthdayLoaded(birthdays: [])); // Placeholder
    } catch (e) {
      emit(BirthdayError(message: 'Erreur lors du toggle: $e'));
    }
  }
}