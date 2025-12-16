import 'package:flutter/material.dart';
import '../../core/themes/colors.dart';

class NotificationSettingsWidget extends StatefulWidget {
  final bool notificationsEnabled;
  final TimeOfDay notificationTime;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const NotificationSettingsWidget({
    super.key,
    required this.notificationsEnabled,
    required this.notificationTime,
    required this.onNotificationsChanged,
    required this.onTimeChanged,
  });

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget> {
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.notificationTime) {
      widget.onTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Configurez les rappels d\'anniversaires',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Activer les notifications'),
              subtitle: const Text('Recevoir des rappels pour les anniversaires'),
              value: widget.notificationsEnabled,
              onChanged: widget.onNotificationsChanged,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Heure de notification'),
              subtitle: Text(
                'Les notifications seront envoyées à ${widget.notificationTime.format(context)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _selectTime(context),
              ),
              enabled: widget.notificationsEnabled,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Jours d\'avance'),
              subtitle: const Text('Rappeler 1 jour avant l\'anniversaire'),
              trailing: const Icon(Icons.chevron_right),
              enabled: widget.notificationsEnabled,
              onTap: () {
                // Configurer les jours d'avance
              },
            ),
            if (!widget.notificationsEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Les notifications sont désactivées. Activez-les pour recevoir des rappels.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}