import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';
import 'car_detail_screen.dart';

class BuyerCarListingScreen extends StatelessWidget {
  final String userId; // User ID of the buyer

  const BuyerCarListingScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.directions_car,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              'Listed Cars',
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        centerTitle: false,
      ),
      body: Consumer<CarProvider>(
        builder: (context, carProvider, child) {
          // Fetch cars listed by the buyer (seller matches the buyer's user ID)
          final buyerCars = carProvider.cars
              .where((car) => car.seller.id == userId) // Filter by seller ID
              .toList();

          if (buyerCars.isEmpty) {
            return Center(
              child: Text(
                'You have not listed any cars yet.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[300] : Colors.black,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: buyerCars.length,
            itemBuilder: (context, index) {
              final car = buyerCars[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: car.image != null && car.image.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            car.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, size: 50);
                            },
                          ),
                        )
                      : const Icon(Icons.image, size: 50),
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