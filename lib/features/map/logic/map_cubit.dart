import 'package:bloodinsight/features/map/data/facility_model.dart';
import 'package:bloodinsight/shared/services/facility_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState {
  MapState({
    this.facilities = const [],
    this.isLoading = false,
    this.facilitiesUpdated = false,
    this.error,
    this.currentLocation,
  });

  final List<MedicalFacility> facilities;
  final bool isLoading;
  final bool facilitiesUpdated;
  final String? error;
  final LatLng? currentLocation;

  MapState copyWith({
    List<MedicalFacility>? facilities,
    bool? isLoading,
    bool? facilitiesUpdated,
    String? error,
    LatLng? currentLocation,
  }) {
    return MapState(
      facilities: facilities ?? this.facilities,
      isLoading: isLoading ?? this.isLoading,
      facilitiesUpdated: facilitiesUpdated ?? this.facilitiesUpdated,
      error: error,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}

class MapCubit extends Cubit<MapState> {
  MapCubit(this._facilityService) : super(MapState());
  final FacilityService _facilityService;

  Future<void> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      emit(
        state.copyWith(
          currentLocation: LatLng(position.latitude, position.longitude),
        ),
      );

      await searchNearbyFacilities();
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> searchNearbyFacilities() async {
    if (state.currentLocation == null) {
      return;
    }

    try {
      emit(state.copyWith(facilitiesUpdated: false, isLoading: true));

      final facilities = await _facilityService.searchNearbyFacilities(
        state.currentLocation!,
      );

      emit(
        state.copyWith(
          facilities: facilities,
          facilitiesUpdated: true,
          isLoading: false,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          error: err.toString(),
          facilitiesUpdated: false,
          isLoading: false,
        ),
      );
    }
  }

  Future<void> searchFacilities(String query) async {
    if (state.currentLocation == null) {
      return;
    }

    try {
      emit(state.copyWith(facilitiesUpdated: false, isLoading: true));

      final facilities = await _facilityService.searchFacilitiesByQuery(
        query,
        state.currentLocation!,
      );

      emit(
        state.copyWith(
          facilities: facilities,
          facilitiesUpdated: true,
          isLoading: false,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          error: err.toString(),
          facilitiesUpdated: false,
          isLoading: false,
        ),
      );
    }
  }
}
