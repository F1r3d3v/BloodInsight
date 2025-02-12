import 'package:flutter_google_maps_webservices/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MedicalFacility {
  MedicalFacility({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.location,
    required this.placeId,
    this.phoneNumber,
    this.website,
    this.isOpen = false,
    this.rating,
    this.photoReference,
  });

  factory MedicalFacility.fromPlace(Map<String, dynamic> place) {
    final location = (place['geometry'] as Geometry).location;

    return MedicalFacility(
      id: place['place_id'].toString(),
      name: place['name'].toString(),
      address: place['formatted_address']?.toString() ??
          place['vicinity']?.toString() ??
          '',
      location: LatLng(location.lat, location.lng),
      placeId: place['place_id'].toString(),
      rating: (place['rating'] as num?)?.toDouble(),
      isOpen: (place['opening_hours'] as OpeningHoursDetail?)?.openNow ?? false,
      photoReference:
          (place['photos'] as List<Photo>).firstOrNull?.photoReference ?? '',
      type: _determineType(place['types'] as List<dynamic>),
    );
  }

  factory MedicalFacility.fromJson(Map<String, dynamic> json) {
    return MedicalFacility(
      id: json['id'].toString(),
      name: json['name'].toString(),
      address: json['address'].toString(),
      type: json['type'].toString(),
      location: LatLng(json['latitude'] as double, json['longitude'] as double),
      placeId: json['placeId'].toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      website: json['website']?.toString(),
      isOpen: json['isOpen'] as bool? ?? false,
      rating: json['rating'] as double?,
      photoReference: json['photoReference']?.toString(),
    );
  }

  final String id;
  final String name;
  final String address;
  final String type; // hospital, lab, clinic, etc.
  final LatLng location;
  final String? phoneNumber;
  final String? website;
  final bool isOpen;
  final double? rating;
  final String? photoReference;
  final String placeId;

  MedicalFacility copyWith({
    String? id,
    String? name,
    String? address,
    String? type,
    LatLng? location,
    String? phoneNumber,
    String? website,
    bool? isOpen,
    double? rating,
    String? placeId,
    String? photoReference,
  }) {
    return MedicalFacility(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      type: type ?? this.type,
      location: location ?? this.location,
      placeId: placeId ?? this.placeId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      isOpen: isOpen ?? this.isOpen,
      rating: rating ?? this.rating,
      photoReference: photoReference ?? this.photoReference,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'type': type,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'placeId': placeId,
      'phoneNumber': phoneNumber,
      'website': website,
      'isOpen': isOpen,
      'rating': rating,
      'photoReference': photoReference,
    };
  }

  static String _determineType(List<dynamic> types) {
    if (types.contains('hospital')) {
      return 'hospital';
    }
    if (types.contains('doctor')) {
      return 'clinic';
    }
    if (types.contains('health')) {
      return 'laboratory';
    }
    return 'other';
  }
}
