import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Car Listings',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        centerTitle: true,
      ),
      body: Consumer<CarProvider>(
        builder: (context, carProvider, child) {
          final cars = carProvider.cars;

          if (cars.isEmpty) {
            return Center(
              child: Text(
                'No cars available for rent',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[300] : Colors.black,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
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
 // Placeholder for car image
                title: Text(
                  car.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${car.price.toStringAsFixed(2)} per day',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                trailing: Text(
                  car.brand.toString().split('.').last,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                  ),
                ),
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
