import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/car_model.dart';
import '../providers/car_provider.dart';
import '../services/location_service.dart';

class NearestCarsScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearest Cars'),
      ),
      body: FutureBuilder(
        future: _loadNearestCars(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final nearestCars = snapshot.data as List<Car>;
            return ListView.builder(
              itemCount: nearestCars.length,
              itemBuilder: (context, index) {
                final car = nearestCars[index];
                return ListTile(
                  title: Text(car.name),
                  subtitle: Text('${car.price.toStringAsFixed(2)} per day'),
                  trailing: Text('${car.distance!.toStringAsFixed(1)} km'),
                  onTap: () {
                    // Navigate to car details
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Car>> _loadNearestCars(BuildContext context) async {
    final locationService = LocationService();
    final carProvider = Provider.of<CarProvider>(context, listen: false);

    // Get the user's current location
    final userLocation = await locationService.getCurrentLocation();

    // Get the list of cars from the provider
    final cars = carProvider.cars;

    // Calculate distance from user to each car
    for (var car in cars) {
      // Ensure that the car has valid latitude and longitude
      if (car.latitude != null && car.longitude != null) {
        double distanceInMeters = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          car.latitude!,
          car.longitude!,
        );
        double distanceInKilometers = distanceInMeters / 1000;  // Convert meters to kilometers
        car.distance = distanceInKilometers;  // Store the calculated distance
      } else {
        car.distance = double.infinity;  // Set distance as infinity if no valid coordinates
      }
    }

    // Sort the cars by distance (optional)
    cars.sort((a, b) => a.distance!.compareTo(b.distance!));

    return cars;
  }
}
