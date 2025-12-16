// lib/data/datasources/remote/firebase_birthday_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/birthday_model.dart';
import '../birthday_data_source.dart';

class FirebaseBirthdayDataSource implements BirthdayDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _birthdaysCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Utilisateur non authentifié');
    }
    return _firestore.collection('users').doc(userId).collection('birthdays');
  }

  @override
  Future<List<BirthdayModel>> getBirthdays() async {
    try {
      final snapshot = await _birthdaysCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BirthdayModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Erreur Firebase: $e');
      return [];
    }
  }

  @override
  Future<void> addBirthday(BirthdayModel birthday) async {
    await _birthdaysCollection.add(birthday.toJson());
  }

  @override
  Future<void> updateBirthday(BirthdayModel birthday) async {
    await _birthdaysCollection.doc(birthday.id).update(birthday.toJson());
  }

  @override
  Future<void> deleteBirthday(String id) async {
    await _birthdaysCollection.doc(id).delete();
  }

  @override
  Future<List<BirthdayModel>> getUpcomingBirthdays(int days) async {
    final allBirthdays = await getBirthdays();
    final now = DateTime.now();

    return allBirthdays.where((birthday) {
      final nextBirthday = _getNextBirthday(birthday.birthDate);
      final daysUntil = nextBirthday.difference(now).inDays;
      return daysUntil <= days && daysUntil >= 0;
    }).toList();
  }

  DateTime _getNextBirthday(DateTime birthDate) {
    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }

    return nextBirthday;
  }

  @override
  Stream<List<BirthdayModel>> birthdaysStream() {
    return _birthdaysCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BirthdayModel.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }
}