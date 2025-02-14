import 'dart:async';

import 'package:bloodinsight/core/connectivity_status.dart';
import 'package:bloodinsight/features/bloodwork/data/bloodmarker_model.dart';
import 'package:bloodinsight/features/bloodwork/data/bloodwork_model.dart';
import 'package:bloodinsight/shared/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:stream_transform/stream_transform.dart';

class BloodworkService {
  BloodworkService({required this.db, required this.auth});

  final FirebaseFirestore db;
  final AuthService auth;

  Future<void> _wrapper(Future<void> Function() operation) async {
    if (GetIt.I<ConnectionStatus>().hasConnection) {
      await operation();
    } else {
      unawaited(operation());
    }
  }

  // Get user's bloodwork collection reference
  CollectionReference getBloodworkRef() {
    return db
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('bloodwork');
  }

  // Add new bloodwork
  Future<void> addBloodwork(Bloodwork bloodwork) async {
    unawaited(
      _wrapper(() async {
        // Create bloodwork document
        final bloodworkRef = await getBloodworkRef().add({
          'labName': bloodwork.labName,
          'dateCollected': Timestamp.fromDate(bloodwork.dateCollected),
        });

        // Add markers as subcollection
        final markersRef = bloodworkRef.collection('markers');
        for (final marker in bloodwork.markers) {
          await markersRef.add({
            'name': marker.name,
            'value': marker.value,
            'unit': marker.unit,
            'minRange': marker.minRange,
            'maxRange': marker.maxRange,
            'category': marker.category.name,
          });
        }
      }),
    );
  }

  // Update existing bloodwork
  Future<void> updateBloodwork(String bloodworkId, Bloodwork bloodwork) async {
    unawaited(
      _wrapper(() async {
        final bloodworkRef = getBloodworkRef().doc(bloodworkId);

        // Start a batch write
        final batch = db.batch()

          // Update bloodwork metadata
          ..update(bloodworkRef, {
            'labName': bloodwork.labName,
            'dateCollected': Timestamp.fromDate(bloodwork.dateCollected),
          });

        // Delete existing markers
        final existingMarkers = await bloodworkRef.collection('markers').get();
        for (final doc in existingMarkers.docs) {
          batch.delete(doc.reference);
        }

        // Commit the batch
        await batch.commit();

        // Add new markers
        final markersRef = bloodworkRef.collection('markers');
        for (final marker in bloodwork.markers) {
          await markersRef.add({
            'name': marker.name,
            'value': marker.value,
            'unit': marker.unit,
            'minRange': marker.minRange,
            'maxRange': marker.maxRange,
            'category': marker.category.name,
          });
        }
      }),
    );
  }

  // Update specific marker
  Future<void> updateMarker(
    String bloodworkId,
    String markerId,
    BloodMarker marker,
  ) async {
    unawaited(
      _wrapper(
        () async => getBloodworkRef()
            .doc(bloodworkId)
            .collection('markers')
            .doc(markerId)
            .update({
          'value': marker.value,
          'unit': marker.unit,
          'minRange': marker.minRange,
          'maxRange': marker.maxRange,
          'category': marker.category.name,
        }),
      ),
    );
  }

  // Delete bloodwork and all its markers
  Future<void> deleteBloodwork(String bloodworkId) async {
    unawaited(
      _wrapper(() async {
        final bloodworkRef = getBloodworkRef().doc(bloodworkId);

        // Delete all markers first
        final markersSnapshot = await bloodworkRef.collection('markers').get();
        final batch = db.batch();

        for (final doc in markersSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // Delete the bloodwork document
        batch.delete(bloodworkRef);

        // Commit the batch
        await batch.commit();
      }),
    );
  }

  // Delete specific marker
  Future<void> deleteMarker(String bloodworkId, String markerId) async {
    await getBloodworkRef()
        .doc(bloodworkId)
        .collection('markers')
        .doc(markerId)
        .delete();
  }

  // Get bloodwork with markers
  Future<Bloodwork> getBloodwork(String bloodworkId) async {
    // Get bloodwork document
    final bloodworkDoc = await getBloodworkRef().doc(bloodworkId).get();

    // Get markers subcollection
    final markersSnapshot =
        await bloodworkDoc.reference.collection('markers').get();

    // Convert markers to BloodMarker objects
    final markers = markersSnapshot.docs.map((doc) {
      final data = doc.data();
      return BloodMarker(
        name: data['name'].toString(),
        value: data['value'] as double,
        unit: data['unit'].toString(),
        minRange: data['minRange'] as double,
        maxRange: data['maxRange'] as double,
        category:
            BloodMarkerCategory.values.byName(data['category'].toString()),
      );
    }).toList();

    final data = bloodworkDoc.data()! as Map<String, dynamic>;
    return Bloodwork(
      id: bloodworkDoc.id,
      labName: data['labName'].toString(),
      dateCollected: (data['dateCollected'] as Timestamp).toDate(),
      markers: markers,
    );
  }

  // Stream bloodwork
  Stream<Bloodwork?> streamBloodwork(String bloodworkId) {
    return getBloodworkRef().doc(bloodworkId).snapshots().combineLatest(
        getBloodworkRef().doc(bloodworkId).collection('markers').snapshots(),
        (bloodworkDoc, markersSnapshot) {
      final markers = markersSnapshot.docs.map((doc) {
        final data = doc.data();
        return BloodMarker(
          name: data['name'].toString(),
          value: data['value'] as double,
          unit: data['unit'].toString(),
          minRange: data['minRange'] as double,
          maxRange: data['maxRange'] as double,
          category:
              BloodMarkerCategory.values.byName(data['category'].toString()),
        );
      }).toList();

      if (!bloodworkDoc.exists) {
        return null;
      }

      final bloodworkData = bloodworkDoc.data()! as Map<String, dynamic>;
      return Bloodwork(
        id: bloodworkDoc.id,
        labName: bloodworkData['labName'].toString(),
        dateCollected: (bloodworkData['dateCollected'] as Timestamp).toDate(),
        markers: markers,
      );
    });
  }

  // Stream latest bloodwork
  Stream<Bloodwork?> streamLatestBloodwork() {
    final bloodworkRef =
        getBloodworkRef().orderBy('dateCollected', descending: true).limit(1);
    return bloodworkRef.snapshots().switchMap(
      (snapshot) {
        if (snapshot.docs.isEmpty) {
          return Stream.value(null);
        }
        return streamBloodwork(snapshot.docs.first.id);
      },
    );
  }

  // Get all bloodwork for a user, messy but works
  Stream<List<Bloodwork>> streamUserBloodwork() {
    return getBloodworkRef().snapshots().switchMap((snapshot) {
      if (snapshot.docs.isEmpty) {
        return Stream.value(<Bloodwork>[]);
      }

      final streams = snapshot.docs
          .map(
            (doc) => streamBloodwork(doc.id)
                .where((bloodwork) => bloodwork != null)
                .map(
                  (bloodwork) => [bloodwork!],
                ),
          )
          .toList();

      for (var i = 0; i < streams.length - 1; i++) {
        streams[i + 1] = streams[i].combineLatest(
          streams[i + 1],
          (a, b) => a + b,
        );
      }

      return streams.last;
    });
  }
}
