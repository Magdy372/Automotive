import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';

class CarListingScreen extends StatefulWidget {
  const CarListingScreen({super.key});

  @override
  _CarListingScreenState createState() => _CarListingScreenState();
}

class _CarListingScreenState extends State<CarListingScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the cars only once when the screen is initialized
    Provider.of<CarProvider>(context, listen: false).fetchCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Listings')),
      body: Consumer<CarProvider>(
        builder: (context, carProvider, child) {
          final cars = carProvider.cars;

          if (cars.isEmpty) {
            return const Center(
              child: Text('No cars available for rent'),
            );
          }

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return ListTile(
                leading: Image.asset(car.image,
                    width: 60, height: 60), // Placeholder for car image
                title: Text(car.name),
                subtitle: Text('${car.price.toStringAsFixed(2)} per day'),
                trailing: Text(car.brand.toString().split('.').last),
                onTap: () {
                  // Navigate to car details screen
                  // Navigator.push(...);
                },
              );
            },
          );
        },
      ),
    );
  }
}
