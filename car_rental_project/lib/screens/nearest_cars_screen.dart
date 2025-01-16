import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/car_model.dart';
import '../providers/car_provider.dart';
import '../services/location_service.dart';

class NearestCarsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Wrap with Scaffold to provide Material ancestor
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

    final userLocation = await locationService.getCurrentLocation();
    return carProvider.getNearestCars(userLocation);
  }
}