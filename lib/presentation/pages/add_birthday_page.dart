import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/error_widget.dart';
import '../widgets/birthday_form.dart';
import '../bloc/birthday_bloc.dart';
import '../bloc/birthday_event.dart';
import '../bloc/birthday_state.dart';
import '../../../domain/entities/birthday_entity.dart';

class AddBirthdayPage extends StatefulWidget {
  const AddBirthdayPage({super.key});

  @override
  State<AddBirthdayPage> createState() => _AddBirthdayPageState();
}

class _AddBirthdayPageState extends State<AddBirthdayPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  bool _notificationsEnabled = true;

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
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
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
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final birthday = BirthdayEntity(
        id: '', // Sera généré par le repository
        name: _nameController.text.trim(),
        birthDate: _selectedDate!,
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<BirthdayBloc>().add(AddBirthdayEvent(birthday: birthday));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ajouter un anniversaire',
        showBackButton: true,
      ),
      body: BlocConsumer<BirthdayBloc, BirthdayState>(
        listener: (context, state) {
          if (state is BirthdayAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Anniversaire ajouté avec succès!'),
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
              isEditing: false,
            ),
          );
        },
      ),
    );
  }
}