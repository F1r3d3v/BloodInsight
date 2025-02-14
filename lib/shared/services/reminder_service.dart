import 'dart:async';

import 'package:bloodinsight/core/connectivity_status.dart';
import 'package:bloodinsight/core/notification_service.dart';
import 'package:bloodinsight/features/reminders/data/remainder_model.dart';
import 'package:bloodinsight/shared/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ReminderService {
  ReminderService({
    required FirebaseFirestore db,
    required AuthService auth,
    required NotificationService notifications,
  })  : _db = db,
        _auth = auth,
        _notifications = notifications {
    _clearOldReminders();
  }

  final FirebaseFirestore _db;
  final AuthService _auth;
  final NotificationService _notifications;

  Future<void> _wrapper(Future<void> Function() operation) async {
    if (GetIt.I<ConnectionStatus>().hasConnection) {
      await operation();
    } else {
      unawaited(operation());
    }
  }

  CollectionReference<Map<String, dynamic>> _getRemindersRef() {
    return _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('reminders');
  }

  Stream<List<BloodworkReminder>> streamReminders() {
    return _getRemindersRef()
        .orderBy('scheduledDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BloodworkReminder.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  Stream<BloodworkReminder>? streamReminder(String reminderId) {
    return _getRemindersRef().doc(reminderId).snapshots().map(
          (doc) =>
              BloodworkReminder.fromJson({...doc.data() ?? {}, 'id': doc.id}),
        );
  }

  Future<void> _scheduleNotification(BloodworkReminder reminder) async {
    await _notifications.scheduleNotification(
      id: reminder.id.hashCode,
      title: 'Bloodwork Reminder',
      body: 'Time for your bloodwork: ${reminder.labName}',
      scheduledDate: reminder.scheduledDate,
    );
  }

  Future<void> addReminder(BloodworkReminder reminder) async {
    unawaited(
      _wrapper(() async => _getRemindersRef().add(reminder.toJson())),
    );
    await _notifications.requestPermissions();
    await _scheduleNotification(reminder);
  }

  Future<void> updateReminder(BloodworkReminder reminder) async {
    unawaited(
      _wrapper(() async {
        await _getRemindersRef().doc(reminder.id).update(reminder.toJson());
      }),
    );
    await _notifications.cancelNotification(reminder.id.hashCode);
    await _scheduleNotification(reminder);
  }

  Future<void> deleteReminder(String reminderId) async {
    unawaited(
      _wrapper(() async {
        await _getRemindersRef().doc(reminderId).delete();
      }),
    );
    await _notifications.cancelNotification(reminderId.hashCode);
  }

  Future<void> _clearOldReminders() async {
    unawaited(
      _wrapper(() async {
        final reminders = await _getRemindersRef()
            .where(
              'scheduledDate',
              isLessThan: Timestamp.fromDate(DateTime.now()),
            )
            .get();
        for (final doc in reminders.docs) {
          await _notifications.cancelNotification(doc.id.hashCode);
          await doc.reference.delete();
        }
      }),
    );
  }

  Future<BloodworkReminder?> getReminder(String reminderId) async {
    final doc = await _getRemindersRef().doc(reminderId).get();
    if (!doc.exists) {
      return null;
    }
    return BloodworkReminder.fromJson({...doc.data() ?? {}, 'id': doc.id});
  }

  Stream<BloodworkReminder?> streamNextReminder() {
    return _getTime().switchMap((time) {
      return _getRemindersRef()
          .where('scheduledDate', isGreaterThan: Timestamp.fromDate(time))
          .orderBy('scheduledDate')
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return null;
        }
        final doc = snapshot.docs.first;
        return BloodworkReminder.fromJson({...doc.data(), 'id': doc.id});
      });
    });
  }

  Stream<DateTime> _getTime() async* {
    while (true) {
      yield DateTime.now();
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }
}
