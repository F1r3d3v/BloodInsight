import 'package:bloodinsight/features/bloodwork/data/bloodmarker_model.dart';

class Bloodwork {
  Bloodwork({
    required this.id,
    required this.labName,
    required this.dateCollected,
    required this.markers,
  });

  factory Bloodwork.fromJson(Map<String, dynamic> json) {
    return Bloodwork(
      id: json['id'] as String,
      labName: json['labName'] as String,
      dateCollected: DateTime.parse(json['dateCollected'] as String),
      markers: (json['markers'] as List)
          .map(
            (markerJson) =>
                BloodMarker.fromJson(markerJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }
  final String id;
  final String labName;
  final DateTime dateCollected;
  final List<BloodMarker> markers;

  List<BloodMarker> getMarkersByCategory(BloodMarkerCategory category) {
    return markers.where((marker) => marker.category == category).toList();
  }

  List<BloodMarker> get abnormalMarkers {
    return markers.where((marker) => !marker.isNormal).toList();
  }

  Bloodwork copyWith({
    String? id,
    String? labName,
    DateTime? dateCollected,
    List<BloodMarker>? markers,
  }) {
    return Bloodwork(
      id: id ?? this.id,
      labName: labName ?? this.labName,
      dateCollected: dateCollected ?? this.dateCollected,
      markers: markers ?? this.markers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labName': labName,
      'dateCollected': dateCollected.toIso8601String(),
      'markers': markers.map((marker) => marker.toJson()).toList(),
    };
  }
}
