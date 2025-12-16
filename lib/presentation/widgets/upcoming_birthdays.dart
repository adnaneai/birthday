import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/themes/colors.dart';
import '../../../domain/entities/birthday_entity.dart';

class UpcomingBirthdaysWidget extends StatelessWidget {
  final List<BirthdayEntity> birthdays;

  const UpcomingBirthdaysWidget({
    super.key,
    required this.birthdays,
  });

  @override
  Widget build(BuildContext context) {
    final upcomingBirthdays = birthdays
        .where((birthday) => birthday.daysUntilNextBirthday <= 30)
        .toList();

    if (upcomingBirthdays.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_available,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Anniversaires à venir',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.cake,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucun anniversaire à venir',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Les prochains anniversaires apparaîtront ici',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_available,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Anniversaires à venir (30 jours)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...upcomingBirthdays.map((birthday) {
              final daysUntil = birthday.daysUntilNextBirthday;
              final isToday = daysUntil == 0;
              final isTomorrow = daysUntil == 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.accent.withOpacity(0.1)
                            : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          daysUntil.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? AppColors.accent
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            birthday.name,
                            style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getDaysText(daysUntil),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isToday
                                  ? AppColors.accent
                                  : isTomorrow
                                  ? AppColors.warning
                                  : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (birthday.relationship != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          birthday.relationship!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            if (upcomingBirthdays.length > 3)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/list-birthdays');
                  },
                  child: const Text('Voir tous'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getDaysText(int days) {
    if (days == 0) {
      return 'Aujourd\'hui';
    } else if (days == 1) {
      return 'Demain';
    } else {
      return 'Dans $days jours';
    }
  }
}