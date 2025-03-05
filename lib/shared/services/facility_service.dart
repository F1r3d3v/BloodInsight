import 'dart:math';

import 'package:bloodinsight/core/config/environment.dart';
import 'package:bloodinsight/features/map/data/facility_model.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FacilityService {
  final places = GoogleMapsPlaces(apiKey: Environment.googleMapsAPI);

  Future<List<MedicalFacility>> searchNearbyFacilities(
    LatLng location, {
    double radius = 5000,
  }) async {
    final response = await places.searchNearbyWithRadius(
      Location(lat: location.latitude, lng: location.longitude),
      radius,
      type: 'health',
      keyword: 'blood test laboratory hospital clinic',
    );

    if (response.status == 'OK') {
      final facilities = response.results
          .map((place) => MedicalFacility.fromPlace(place.toJson()))
          .toList()

        // Sort facilities by distance from current location
        ..sort((a, b) {
          final distA = _calculateDistance(
            location.latitude,
            location.longitude,
            a.location.latitude,
            a.location.longitude,
          );
          final distB = _calculateDistance(
            location.latitude,
            location.longitude,
            b.location.latitude,
            b.location.longitude,
          );
          return distA.compareTo(distB);
        });

      return facilities;
    }

    return [];
  }

  Future<List<MedicalFacility>> searchFacilitiesByQuery(
    String query,
    LatLng location,
  ) async {
    final PlacesSearchResponse response;
    if (query.isNotEmpty) {
      response = await places.searchByText(
        query,
        location: Location(lat: location.latitude, lng: location.longitude),
        type: 'health',
      );
    } else {
      response = await places.searchNearbyWithRadius(
        Location(lat: location.latitude, lng: location.longitude),
        5000,
        type: 'health',
        keyword: 'blood test laboratory hospital clinic',
      );
    }

    if (response.status == 'OK') {
      final facilities = response.results
          .map((place) => MedicalFacility.fromPlace(place.toJson()))
          .toList()

        // Sort facilities by distance from current location
        ..sort((a, b) {
          final distA = _calculateDistance(
            location.latitude,
            location.longitude,
            a.location.latitude,
            a.location.longitude,
          );
          final distB = _calculateDistance(
            location.latitude,
            location.longitude,
            b.location.latitude,
            b.location.longitude,
          );
          return distA.compareTo(distB);
        });

      return facilities;
    }

    return [];
  }

// Ccalculate distance using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radius of the earth in kilometers
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}
