import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class OpenStreetMapPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final bool isEditable;
  final Function(LatLng)? onLocationSelected;

  const OpenStreetMapPicker({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.isEditable = true,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  State<OpenStreetMapPicker> createState() => _OpenStreetMapPickerState();
}

class _OpenStreetMapPickerState extends State<OpenStreetMapPicker> {
  LatLng? selectedLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      isLoading = false;
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          selectedLocation = LatLng(position.latitude, position.longitude);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Set a default location (e.g., city center) if unable to get current location
          selectedLocation = const LatLng(25.2048, 55.2708); // Default to Dubai
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: widget.isEditable ? AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: selectedLocation != null
                ? () {
                    widget.onLocationSelected?.call(selectedLocation!);
                    Navigator.pop(context);
                  }
                : null,
          ),
        ],
      ) : null,
      body: FlutterMap(
        options: MapOptions(
          initialCenter: selectedLocation!,
          initialZoom: 15,
          onTap: widget.isEditable
              ? (tapPosition, point) {
                  setState(() {
                    selectedLocation = point;
                  });
                }
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          if (selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: selectedLocation!,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: widget.isEditable ? FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ) : null,
    );
  }
}