import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChildTrackingMap extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const ChildTrackingMap({
    super.key,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  @override
  State<ChildTrackingMap> createState() => _ChildTrackingMapState();
}

class _ChildTrackingMapState extends State<ChildTrackingMap> {
  GoogleMapController? _mapController;
  static const String _googleMapsApiKey = 'AIzaSyCh4YWxrSQumlOpsNxSsdha8kMYwE1Hc50';

  // Default location (can be set to hospital or home location)
  static const double _defaultLatitude = 24.7136; // Riyadh, Saudi Arabia
  static const double _defaultLongitude = 46.6753;

  @override
  Widget build(BuildContext context) {
    final latitude = widget.latitude ?? _defaultLatitude;
    final longitude = widget.longitude ?? _defaultLongitude;

    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 400,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(latitude, longitude),
                        zoom: 14.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('child_location'),
                          position: LatLng(latitude, longitude),
                          infoWindow: InfoWindow(
                            title: widget.locationName ?? 'Location',
                            snippet: 'Child tracking location',
                          ),
                        ),
                      },
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: true,
                    ),
                    if (widget.locationName != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 8,
                        child: Card(
                          color: Colors.white.withValues(alpha: 0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.locationName!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Map Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This map shows the location for tracking your child\'s health data. You can use this to mark important locations like hospitals, clinics, or home.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

