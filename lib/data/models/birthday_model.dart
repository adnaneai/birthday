import 'package:hive/hive.dart';

part 'birthday_model.g.dart';

@HiveType(typeId: 0)
class BirthdayModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime birthDate;

  @HiveField(3)
  final String? relationship;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String? email;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final bool notificationsEnabled;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  BirthdayModel({
    required this.id,
    required this.name,
    required this.birthDate,
    this.relationship,
    this.phone,
    this.email,
    this.notes,
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Optionnel: Supprimez les méthodes toJson/fromJson si vous n'en avez pas besoin
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'notes': notes,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // MODIF: Accepter Map<dynamic, dynamic> pour éviter l'erreur de type
  static BirthdayModel fromJson(dynamic json) {
    Map<String, dynamic> jsonMap;

    if (json is Map<dynamic, dynamic>) {
      jsonMap = Map<String, dynamic>.from(json);
    } else {
      jsonMap = json as Map<String, dynamic>;
    }

    return BirthdayModel(
      id: jsonMap['id'] as String,
      name: jsonMap['name'] as String,
      birthDate: DateTime.parse(jsonMap['birthDate'] as String),
      relationship: jsonMap['relationship'] as String?,
      phone: jsonMap['phone'] as String?,
      email: jsonMap['email'] as String?,
      notes: jsonMap['notes'] as String?,
      notificationsEnabled: jsonMap['notificationsEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(jsonMap['createdAt'] as String),
      updatedAt: DateTime.parse(jsonMap['updatedAt'] as String),
    );
  }
}