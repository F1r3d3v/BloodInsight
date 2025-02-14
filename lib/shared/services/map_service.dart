import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  Set<Marker> createMarkers({
    required List<Map<String, dynamic>> facilities,
    required void Function(Map<String, dynamic>) onTap,
    LatLng? currentLocation,
  }) {
    final markers = <Marker>{};

    // Add current location marker if available
    if (currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add facility markers
    for (final facility in facilities) {
      markers.add(
        Marker(
          markerId: MarkerId(facility['id'].toString()),
          position: facility['position'] as LatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: facility['name'].toString(),
            snippet: '${facility['address']} • ${facility['rating']}⭐',
          ),
          onTap: () => onTap(facility),
        ),
      );
    }

    return markers;
  }

  Future<void> animateToLocation(
    GoogleMapController controller,
    LatLng location, {
    double zoom = 14,
  }) async {
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: zoom,
        ),
      ),
    );
  }

  LatLngBounds getBoundsForLocations(List<LatLng> locations) {
    double? minLat, maxLat, minLng, maxLng;

    for (final location in locations) {
      minLat =
          minLat == null ? location.latitude : min(minLat, location.latitude);
      maxLat =
          maxLat == null ? location.latitude : max(maxLat, location.latitude);
      minLng =
          minLng == null ? location.longitude : min(minLng, location.longitude);
      maxLng =
          maxLng == null ? location.longitude : max(maxLng, location.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }
}
