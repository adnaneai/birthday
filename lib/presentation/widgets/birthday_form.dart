import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/themes/colors.dart';
import '../../core/utils/validators.dart';

class BirthdayFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController relationshipController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController notesController;
  final DateTime? selectedDate;
  final bool notificationsEnabled;
  final VoidCallback onDateSelected;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onSubmit;
  final bool isEditing;

  const BirthdayFormWidget({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.relationshipController,
    required this.phoneController,
    required this.emailController,
    required this.notesController,
    required this.selectedDate,
    required this.notificationsEnabled,
    required this.onDateSelected,
    required this.onNotificationsChanged,
    required this.onSubmit,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Modifier l\'anniversaire' : 'Nouvel anniversaire',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Nom
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nom *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: Validators.validateName,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 16),
          // Relation
          TextFormField(
            controller: relationshipController,
            decoration: const InputDecoration(
              labelText: 'Relation (famille, ami, collègue...)',
              prefixIcon: Icon(Icons.group),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Date de naissance
          InkWell(
            onTap: onDateSelected,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date de naissance *',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                        : 'Sélectionner une date',
                    style: selectedDate != null
                        ? Theme.of(context).textTheme.bodyMedium
                        : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          if (selectedDate != null && selectedDate!.year > 1900) ...[
            const SizedBox(height: 8),
            Text(
              'Âge: ${_calculateAge(selectedDate!)} ans',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Téléphone
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          // Email
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                return Validators.validateEmail(value);
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 16),
          // Notes
          TextFormField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              prefixIcon: Icon(Icons.note),
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          // Notifications
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recevoir une notification le jour de l\'anniversaire',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Activer les notifications'),
                    value: notificationsEnabled,
                    onChanged: onNotificationsChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Bouton de soumission
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isEditing ? 'Mettre à jour' : 'Ajouter l\'anniversaire',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }
}