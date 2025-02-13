import 'dart:async';

import 'package:bloodinsight/core/connectivity_status.dart';
import 'package:bloodinsight/features/user_profile/data/user_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _wrapper(Future<void> Function() operation) async {
    if (GetIt.I<ConnectionStatus>().hasConnection) {
      await operation();
    } else {
      unawaited(operation());
    }
  }

  // Get reference to user's profile document
  DocumentReference getUserProfileRef(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  // Create or update user profile
  Future<void> upsertProfile(String userId, UserProfile profile) async {
    final profileRef = getUserProfileRef(userId);

    try {
      unawaited(
        _wrapper(
          () => profileRef.set(
            profile.toJson(),
            SetOptions(merge: true),
          ),
        ),
      );
    } catch (err) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Failed to update profile: $err',
      );
    }
  }

  // Get user profile
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final doc = await getUserProfileRef(userId).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserProfile.fromJson(userId, doc.data()! as Map<String, dynamic>);
    } catch (err) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Failed to fetch profile: $err',
      );
    }
  }

  // Stream user profile
  Stream<UserProfile?> streamProfile(String userId) {
    return getUserProfileRef(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserProfile.fromJson(userId, doc.data()! as Map<String, dynamic>);
    });
  }

  // Update specific profile fields
  Future<void> updateProfileFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      unawaited(_wrapper(() => getUserProfileRef(userId).update(fields)));
    } catch (err) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Failed to update profile fields: $err',
      );
    }
  }

  // Delete user profile
  Future<void> deleteProfile(String userId) async {
    try {
      unawaited(_wrapper(() => getUserProfileRef(userId).delete()));
    } catch (err) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Failed to delete profile: $err',
      );
    }
  }

  double calculateBMI(UserProfile profile) {
    final heightInMeters = profile.height / 100;
    return profile.weight / (heightInMeters * heightInMeters);
  }

  int calculateAge(UserProfile profile) {
    final now = DateTime.now();
    var age = now.year - profile.dateOfBirth.year;

    if (now.month < profile.dateOfBirth.month ||
        (now.month == profile.dateOfBirth.month &&
            now.day < profile.dateOfBirth.day)) {
      age--;
    }

    return age;
  }
}
