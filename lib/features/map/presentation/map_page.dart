import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/core/styles/style.dart';
import 'package:bloodinsight/features/map/data/facility_model.dart';
import 'package:bloodinsight/features/map/logic/map_cubit.dart';
import 'package:bloodinsight/shared/services/facility_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(
        context.read<FacilityService>(),
      ),
      child: const MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final GlobalKey<ScrollableState> scrollKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().getCurrentLocation();
    context.read<MapCubit>().searchFacilities('');
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<MapCubit, MapState>(
        listener: (context, state) {
          if (state.error != null) {
            context.showSnackBar(
              state.error!,
              isError: true,
              duration: const Duration(seconds: 5),
            );
          }
          if (state.facilities.isNotEmpty && state.facilitiesUpdated) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(
                state.facilities.first.location,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.currentLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: state.currentLocation!,
                  zoom: 14,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                markers: _createMarkers(state.facilities),
                onTap: (_) {
                  _hideSheet();
                },
              ),
              Positioned(
                right: 16,
                top: 120,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in',
                      onPressed: () {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      },
                      foregroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.8),
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out',
                      onPressed: () {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      },
                      foregroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.8),
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'my_location',
                      onPressed: () {
                        if (state.currentLocation != null) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLng(state.currentLocation!),
                          );
                        }
                      },
                      foregroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.8),
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SearchBar(
                      onSubmitted: (query) =>
                          context.read<MapCubit>().searchFacilities(query),
                      leading: const Icon(Icons.search),
                      hintText: 'Search for blood work facilities...',
                      backgroundColor: WidgetStateProperty.all(
                        Colors.white.withValues(alpha: 0.9),
                      ),
                      onTap: _hideSheet,
                      onTapOutside: (_) =>
                          FocusScope.of(context).requestFocus(FocusNode()),
                      enabled: !state.isLoading,
                    ),
                    if (state.isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.2,
                minChildSize: 0.2,
                maxChildSize: 0.6,
                snap: true,
                snapSizes: const [0.2, 0.6],
                controller: _sheetController,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: ListView.separated(
                            key: scrollKey,
                            controller: scrollController,
                            itemCount: state.facilities.length,
                            separatorBuilder: (context, index) => Sizes.kGap16,
                            itemBuilder: (context, index) {
                              final facility = state.facilities[index];
                              return _FacilityCard(
                                facility: facility,
                                onTap: () {
                                  _mapController?.animateCamera(
                                    CameraUpdate.newLatLng(facility.location),
                                  );
                                  _hideSheet();
                                },
                              );
                            },
                          ),
                        ),
                        IgnorePointer(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _hideSheet() {
    _sheetController.animateTo(
      0.2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    (scrollKey.currentWidget as ListView?)?.controller?.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
  }

  Set<Marker> _createMarkers(List<MedicalFacility> facilities) {
    return facilities.map((facility) {
      return Marker(
        markerId: MarkerId(facility.id),
        position: facility.location,
        infoWindow: InfoWindow(
          title: facility.name,
          snippet: facility.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          facility.type == 'hospital'
              ? BitmapDescriptor.hueRed
              : facility.type == 'clinic'
                  ? BitmapDescriptor.hueViolet
                  : facility.type == 'laboratory'
                      ? BitmapDescriptor.hueBlue
                      : BitmapDescriptor.hueOrange,
        ),
      );
    }).toSet();
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.facility,
    required this.onTap,
  });

  final MedicalFacility facility;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: Sizes.kPaddH16,
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      child: Theme(
        data: Theme.of(context).copyWith(
          highlightColor:
              Theme.of(context).highlightColor.withValues(alpha: 0.1),
        ),
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          borderRadius: Sizes.kRadius12,
          child: ListTile(
            onTap: onTap,
            leading: Icon(
              facility.type == 'hospital'
                  ? Icons.local_hospital
                  : facility.type == 'clinic'
                      ? Icons.medical_services
                      : facility.type == 'laboratory'
                          ? Icons.science
                          : Icons.location_pin,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              facility.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(facility.address),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    Text(' ${facility.rating}'),
                    const Spacer(),
                    Text(
                      facility.isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        color: facility.isOpen ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
