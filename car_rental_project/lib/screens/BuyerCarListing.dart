import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';
import 'car_detail_screen.dart';

class BuyerCarListingScreen extends StatelessWidget {
  final String userId; // User ID to fetch cars for

  const BuyerCarListingScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Icon from Flutter's Icons library
            Icon(
              Icons.directions_car, // Use a car icon or any other icon
              color: isDarkMode ? Colors.white : Colors.black,
              size: 30,
            ),
            const SizedBox(width: 10), // Add spacing between icon and title
            Text(
              'Cars',
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        centerTitle: false, // Set to false to align the title with the icon
      ),
      body: Consumer<CarProvider>(
        builder: (context, carProvider, child) {
          final userCars = carProvider.carsbysuser; // Use the user-specific cars list

          if (userCars.isEmpty) {
            return Center(
              child: Text(
                'No cars found for this user.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[300] : Colors.black,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: userCars.length,
            itemBuilder: (context, index) {
              final car = userCars[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
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
                      : Icon(Icons.image, size: 50), // Placeholder for car image
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
                    // Navigate to the car detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailScreen(car: car),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}