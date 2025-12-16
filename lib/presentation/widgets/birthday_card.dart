import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/themes/colors.dart';
import '../../../domain/entities/birthday_entity.dart';

class BirthdayCardWidget extends StatelessWidget {
  final BirthdayEntity birthday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BirthdayCardWidget({
    super.key,
    required this.birthday,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntil = birthday.daysUntilNextBirthday;
    final isToday = daysUntil == 0;
    final isUpcoming = daysUntil <= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    birthday.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'AUJOURD\'HUI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (birthday.relationship != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  birthday.relationship!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            Text(
              'Date de naissance: ${DateFormat('dd/MM/yyyy').format(birthday.birthDate)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Âge: ${birthday.age} ans',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.cake,
                  size: 16,
                  color: isToday
                      ? AppColors.accent
                      : isUpcoming
                      ? AppColors.warning
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _getDaysUntilText(daysUntil),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isToday
                          ? AppColors.accent
                          : isUpcoming
                          ? AppColors.warning
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Supprimer',
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDaysUntilText(int days) {
    if (days == 0) {
      return '🎂 Anniversaire aujourd\'hui!';
    } else if (days == 1) {
      return '🎉 Anniversaire demain!';
    } else {
      return 'Prochain anniversaire dans $days jours';
    }
  }
}