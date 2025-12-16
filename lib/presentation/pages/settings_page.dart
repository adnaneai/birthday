import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../widgets/notification_settings.dart';
import '../bloc/birthday_bloc.dart';
import '../bloc/birthday_event.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Paramètres',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Apparence
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apparence',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Mode sombre'),
                    subtitle: const Text('Activer le thème sombre'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Thème de couleurs'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Naviguer vers les paramètres de couleur
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section Notifications
          NotificationSettingsWidget(
            notificationsEnabled: _notificationsEnabled,
            notificationTime: _notificationTime,
            onNotificationsChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            onTimeChanged: (time) {
              setState(() {
                _notificationTime = time;
              });
            },
          ),
          const SizedBox(height: 16),

          // Section Données
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Données',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Sauvegarde'),
                    subtitle: const Text('Sauvegarder vos données'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Sauvegarde des données
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Restauration'),
                    subtitle: const Text('Restaurer une sauvegarde'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Restauration des données
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      'Supprimer toutes les données',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onTap: () {
                      _showClearDataDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section À propos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'À propos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Aide et support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Naviguer vers l'aide
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Politique de confidentialité'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Naviguer vers la politique
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Conditions d\'utilisation'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Naviguer vers les conditions
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer toutes les données'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer toutes les données? '
                'Cette action est irréversible et supprimera tous vos anniversaires.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BirthdayBloc>().add(LoadBirthdaysEvent());
                // Ajouter une logique pour supprimer toutes les données
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les données ont été supprimées'),
                    backgroundColor: Colors.red,
                  ),
                );
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