class BirthdayEntity {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? relationship;
  final String? phone;
  final String? email;
  final String? notes;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  BirthdayEntity({
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

  int get age => _calculateAge();
  int get daysUntilNextBirthday => _daysUntilNextBirthday();

  int _calculateAge() {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  int _daysUntilNextBirthday() {
    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }

    return nextBirthday.difference(now).inDays;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BirthdayEntity &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}