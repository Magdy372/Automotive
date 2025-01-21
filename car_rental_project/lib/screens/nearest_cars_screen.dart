import 'package:car_rental_project/screens/car_detail_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/car_model.dart';
import '../providers/car_provider.dart';
import '../services/location_service.dart';

class NearestCarsScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
     appBar: AppBar(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      title: Text(
        "Nearest cars",
        style: GoogleFonts.poppins(
          color: isDarkMode ? Colors.grey[300] : Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ), 
      centerTitle: true,
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
                  leading: car.image != null && car.image!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            car.image!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error, size: 50); // Fallback icon in case of error
                            },
                          ),
                        )
                      : Icon(Icons.image, size: 50),
                  title: Text(
                    '${car.brand.toString().split('.').last} ${car.name}',
                    style: GoogleFonts.poppins(), // Apply Google Fonts to title
                  ),
                  subtitle: Text(
                    '${car.price.toStringAsFixed(2)} per day',
                    style: GoogleFonts.poppins(), // Apply Google Fonts to subtitle
                  ),
                  trailing: Text(
                    '${car.distance!.toStringAsFixed(1)} km',
                    style: GoogleFonts.poppins(), // Apply Google Fonts to trailing text
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailScreen(car: car),
                      ),
                    );
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
