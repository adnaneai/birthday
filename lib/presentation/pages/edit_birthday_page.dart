import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../widgets/birthday_form.dart';
import '../bloc/birthday_bloc.dart';
import '../bloc/birthday_event.dart';
import '../bloc/birthday_state.dart';
import '../../../domain/entities/birthday_entity.dart';

class EditBirthdayPage extends StatefulWidget {
  final BirthdayEntity birthday;

  const EditBirthdayPage({super.key, required this.birthday});

  @override
  State<EditBirthdayPage> createState() => _EditBirthdayPageState();
}

class _EditBirthdayPageState extends State<EditBirthdayPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.birthday.name);
    _relationshipController = TextEditingController(
        text: widget.birthday.relationship ?? '');
    _phoneController = TextEditingController(text: widget.birthday.phone ?? '');
    _emailController = TextEditingController(text: widget.birthday.email ?? '');
    _notesController = TextEditingController(text: widget.birthday.notes ?? '');
    _selectedDate = widget.birthday.birthDate;
    _notificationsEnabled = widget.birthday.notificationsEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedBirthday = BirthdayEntity(
        id: widget.birthday.id,
        name: _nameController.text.trim(),
        birthDate: _selectedDate,
        relationship: _relationshipController.text.trim().isNotEmpty
            ? _relationshipController.text.trim()
            : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        notificationsEnabled: _notificationsEnabled,
        createdAt: widget.birthday.createdAt,
        updatedAt: DateTime.now(),
      );

      context.read<BirthdayBloc>().add(
        UpdateBirthdayEvent(birthday: updatedBirthday),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Modifier l\'anniversaire',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<BirthdayBloc, BirthdayState>(
        listener: (context, state) {
          if (state is BirthdayUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Anniversaire mis à jour avec succès!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is BirthdayError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is BirthdayDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Anniversaire supprimé avec succès!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is BirthdayLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BirthdayFormWidget(
              formKey: _formKey,
              nameController: _nameController,
              relationshipController: _relationshipController,
              phoneController: _phoneController,
              emailController: _emailController,
              notesController: _notesController,
              selectedDate: _selectedDate,
              notificationsEnabled: _notificationsEnabled,
              onDateSelected: () => _selectDate(context),
              onNotificationsChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              onSubmit: _submitForm,
              isEditing: true,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cet anniversaire? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BirthdayBloc>().add(
                  DeleteBirthdayEvent(id: widget.birthday.id),
                );
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