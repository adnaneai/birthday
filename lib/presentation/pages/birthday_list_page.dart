import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../widgets/birthday_card.dart';
import '../bloc/birthday_bloc.dart';
import '../bloc/birthday_event.dart';
import '../bloc/birthday_state.dart';
import '../../../domain/entities/birthday_entity.dart';

class BirthdayListPage extends StatelessWidget {
  const BirthdayListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tous les anniversaires',
        showBackButton: true,
      ),
      body: BlocBuilder<BirthdayBloc, BirthdayState>(
        builder: (context, state) {
          if (state is BirthdayLoading) {
            return const LoadingWidget(message: 'Chargement...');
          } else if (state is BirthdayLoaded) {
            return _buildList(context, state.birthdays);
          } else if (state is BirthdayError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                context.read<BirthdayBloc>().add(LoadBirthdaysEvent());
              },
            );
          }
          return const Center(child: Text('Aucun anniversaire'));
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<BirthdayEntity> birthdays) {
    if (birthdays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cake,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun anniversaire enregistré',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre premier anniversaire!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-birthday');
              },
              child: const Text('Ajouter un anniversaire'),
            ),
          ],
        ),
      );
    }

    // Trier par date de prochain anniversaire
    birthdays.sort((a, b) => a.daysUntilNextBirthday.compareTo(b.daysUntilNextBirthday));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: birthdays.length,
      itemBuilder: (context, index) {
        final birthday = birthdays[index];
        return BirthdayCardWidget(
          birthday: birthday,
          onEdit: () {
            Navigator.pushNamed(
              context,
              '/edit-birthday',
              arguments: birthday,
            );
          },
          onDelete: () {
            _showDeleteDialog(context, birthday.id);
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cet anniversaire?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BirthdayBloc>().add(DeleteBirthdayEvent(id: id));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}