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

  // Méthode existante - NE PAS MODIFIER
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

  // Méthode existante - NE PAS MODIFIER
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

  // AJOUT: Méthode factory pour créer depuis un Map<String, dynamic> (pour Firebase)
  factory BirthdayModel.fromFirebaseJson(Map<String, dynamic> json) {
    return BirthdayModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      birthDate: DateTime.parse(json['birthDate']),
      relationship: json['relationship'],
      phone: json['phone'],
      email: json['email'],
      notes: json['notes'],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // AJOUT: Méthode pour copier l'objet avec de nouvelles valeurs
  BirthdayModel copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? relationship,
    String? phone,
    String? email,
    String? notes,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BirthdayModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}