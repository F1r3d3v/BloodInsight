import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    this.bloodType,
    required this.height,
    required this.weight,
    this.photoUrl,
  });

  factory UserProfile.fromJson(String id, Map<String, dynamic> json) {
    return UserProfile(
      id: id,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dateOfBirth: (json['dateOfBirth'] as Timestamp).toDate(),
      gender: json['gender']?.toString() ?? '',
      bloodType: json['bloodType']?.toString(),
      height: (json['height'] ?? 0) as double,
      weight: (json['weight'] ?? 0) as double,
      photoUrl: json['photoUrl']?.toString(),
    );
  }
  final String id;
  final String name;
  final String email;
  final DateTime dateOfBirth;
  final String gender;
  final String? bloodType;
  final double height;
  final double weight;
  final String? photoUrl;

  UserProfile copyWith({
    String? name,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
    String? photoUrl,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'photoUrl': photoUrl,
    };
  }
}
