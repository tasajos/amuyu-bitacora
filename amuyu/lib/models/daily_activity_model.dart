import 'package:flutter/material.dart';

class DailyActivity {
  final String id;
  final String activityName;
  final IconData icon;
  final String? notes;
  final DateTime date;

  DailyActivity({
    required this.id,
    required this.activityName,
    required this.icon,
    this.notes,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityName': activityName,
      'iconCodePoint': icon.codePoint, // Guardamos el código del ícono
      'notes': notes,
      'date': date.toIso8601String(),
    };
  }

  factory DailyActivity.fromMap(Map<String, dynamic> map) {
    return DailyActivity(
      id: map['id'],
      activityName: map['activityName'],
      icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
      notes: map['notes'],
      date: DateTime.parse(map['date']),
    );
  }
}

// 2. Actualiza tu archivo: lib/helpers/database_helper.dart

