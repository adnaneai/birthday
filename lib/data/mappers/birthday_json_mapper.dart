// lib/data/mappers/birthday_json_mapper.dart
import '../models/birthday_model.dart';

class BirthdayJsonMapper {
  static Map<String, dynamic> toJson(BirthdayModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'birthDate': model.birthDate.toIso8601String(),
      'relationship': model.relationship,
      'phone': model.phone,
      'email': model.email,
      'notes': model.notes,
      'notificationsEnabled': model.notificationsEnabled,
      'createdAt': model.createdAt.toIso8601String(),
      'updatedAt': model.updatedAt.toIso8601String(),
    };
  }

  static BirthdayModel fromJson(Map<String, dynamic> json) {
    return BirthdayModel(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      relationship: json['relationship'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}