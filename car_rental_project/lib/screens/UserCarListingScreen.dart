import 'package:car_rental_project/screens/CarForm.dart';
import 'package:car_rental_project/screens/CarRentalsScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';
import '../providers/rental_provider.dart'; // Import RentalProvider
import 'car_detail_screen.dart';


class UserCarListingScreen extends StatefulWidget {
  final String userId; // User ID to fetch cars for

  const UserCarListingScreen({super.key, required this.userId});

  @override
  _UserCarListingScreenState createState() => _UserCarListingScreenState();
}

class _UserCarListingScreenState extends State<UserCarListingScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch cars uploaded by the specific user when the screen is initialized
    Provider.of<CarProvider>(context, listen: false).getUserCars(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
      title: Row(
        children: [
          const SizedBox(width: 10), // Add spacing between icon and title
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                ' My Cars',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        actions: [
          // Add Car Button
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // Navigate to the CarForm screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarUploadScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CarProvider>(
        builder: (context, carProvider, child) {
          final userCars = carProvider.carsbysuser; // Use the user-specific cars list

          if (userCars.isEmpty) {
            return Center(
              child: Text(
                'No cars uploaded by you',
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        car.brand.toString().split('.').last,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.list, color: isDarkMode?Colors.grey[300]:Color(0XFF97B3AE)),
                        onPressed: () async {
                          // Fetch rentals for this car
                          final rentalProvider = Provider.of<RentalProvider>(context, listen: false);
                          await rentalProvider.fetchRentalsByCar(car.id);

                          // Navigate to the CarRentalsScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarRentalsScreen(
                                rentals: rentalProvider.rentalsForCar,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
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