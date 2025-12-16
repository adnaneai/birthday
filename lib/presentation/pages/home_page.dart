import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../widgets/upcoming_birthdays.dart';
import '../bloc/birthday_bloc.dart';
import '../bloc/birthday_event.dart';
import '../bloc/birthday_state.dart';
// DOIT ÊTRE PRÉSENT DANS LES DEUX FICHIERS :
import '../../../domain/entities/birthday_entity.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Birthday Reminder',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: BlocConsumer<BirthdayBloc, BirthdayState>(
        listener: (context, state) {
          if (state is BirthdayError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BirthdayLoading) {
            return const LoadingWidget(message: 'Chargement des anniversaires...');
          } else if (state is BirthdayLoaded) {
            return _buildContent(context, state.birthdays);
          } else if (state is BirthdayError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                context.read<BirthdayBloc>().add(LoadBirthdaysEvent());
              },
            );
          }
          return const Center(
            child: Text('Aucun anniversaire enregistré'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-birthday');
        },
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6A11CB),
                    Color(0xFF2575FC),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.cake,
                      size: 40,
                      color: Color(0xFF6A11CB),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Birthday Reminder',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ne ratez aucun anniversaire',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Tous les anniversaires'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/list-birthdays');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                // Naviguer vers les paramètres de notification
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Aide'),
              onTap: () {
                Navigator.pop(context);
                // Naviguer vers l'aide
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<BirthdayEntity> birthdays) {
    final upcomingBirthdays = birthdays
        .where((birthday) => birthday.daysUntilNextBirthday <= 30)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cake,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vue d\'ensemble',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        'Total',
                        birthdays.length.toString(),
                        Icons.people,
                      ),
                      _buildStatCard(
                        context,
                        'À venir (30j)',
                        upcomingBirthdays.length.toString(),
                        Icons.event_available,
                      ),
                      _buildStatCard(
                        context,
                        'Aujourd\'hui',
                        birthdays
                            .where((b) => b.daysUntilNextBirthday == 0)
                            .length
                            .toString(),
                        Icons.today,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          UpcomingBirthdaysWidget(birthdays: upcomingBirthdays),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions rapides',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    children: [
                      _buildQuickAction(
                        context,
                        'Ajouter un anniversaire',
                        Icons.add_circle,
                        Colors.green,
                            () {
                          Navigator.pushNamed(context, '/add-birthday');
                        },
                      ),
                      _buildQuickAction(
                        context,
                        'Voir tous',
                        Icons.list,
                        Colors.blue,
                            () {
                          Navigator.pushNamed(context, '/list-birthdays');
                        },
                      ),
                      _buildQuickAction(
                        context,
                        'Paramètres',
                        Icons.settings,
                        Colors.orange,
                            () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      _buildQuickAction(
                        context,
                        'Aide',
                        Icons.help,
                        Colors.purple,
                            () {
                          // Naviguer vers l'aide
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildQuickAction(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}