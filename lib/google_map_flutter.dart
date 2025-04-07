import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GoogleMapFlutter extends StatefulWidget {
  final void Function(double lat, double lon) onLocationFetched;

  const GoogleMapFlutter({super.key, required this.onLocationFetched});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  String _currentAddress = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      print(
          "Current Location: Lat: ${position.latitude}, Lng: ${position.longitude}");
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      widget.onLocationFetched(
          position.latitude, position.longitude); // ✅ Send location to parent

      _getAddressFromLatLng(position.latitude, position.longitude);

      // Move camera to current location when the map is created
      if (_mapController != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation!, 16),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      Placemark place = placemarks.first;
      setState(() {
        _currentAddress =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Address not found";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? const Center(
              child:
                  CircularProgressIndicator()) 
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  position: _currentLocation!,
                  infoWindow: InfoWindow(title: _currentAddress),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (_currentLocation != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_currentLocation!, 16),
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _getCurrentLocation();
          if (_currentLocation != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_currentLocation!, 16),
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
