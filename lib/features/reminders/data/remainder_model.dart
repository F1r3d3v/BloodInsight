import 'package:cloud_firestore/cloud_firestore.dart';

class BloodworkReminder {
  BloodworkReminder({
    required this.id,
    required this.labName,
    required this.scheduledDate,
    this.isFasting = false,
    this.notes,
  });

  factory BloodworkReminder.fromJson(Map<String, dynamic> json) {
    return BloodworkReminder(
      id: json['id'].toString(),
      labName: json['labName'].toString(),
      scheduledDate: (json['scheduledDate'] as Timestamp).toDate(),
      isFasting: json['isFasting'] as bool? ?? false,
      notes: json['notes'].toString(),
    );
  }
  final String id;
  final String labName;
  final DateTime scheduledDate;
  final bool isFasting;
  final String? notes;

  BloodworkReminder copyWith({
    String? id,
    String? labName,
    DateTime? scheduledDate,
    bool? isFasting,
    String? notes,
  }) {
    return BloodworkReminder(
      id: id ?? this.id,
      labName: labName ?? this.labName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isFasting: isFasting ?? this.isFasting,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labName': labName,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'isFasting': isFasting,
      'notes': notes,
    };
  }
}
