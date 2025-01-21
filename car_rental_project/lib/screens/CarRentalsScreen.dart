import 'package:car_rental_project/screens/BuyerCarListing.dart';
import 'package:car_rental_project/screens/UserCarListingScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/rental_model.dart';


class CarRentalsScreen extends StatelessWidget {
  final List<RentalModel> rentals;

  const CarRentalsScreen({super.key, required this.rentals});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode? Colors.black:Colors.white,
        title: Text(
          "Car rentals",
          style: GoogleFonts.poppins(
            color:isDarkMode? Colors.grey[300]:Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ), 
        ),
      centerTitle: true, 
     ),
      body: rentals.isEmpty
          ? Center(
              child: Text(
                'No rentals found for this car.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            )
          : ListView.builder(
              itemCount: rentals.length,
              itemBuilder: (context, index) {
                final rental = rentals[index];
                return FutureBuilder<Map<String, dynamic>?>(
                  future: rental.getBuyerDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading buyer details...'),
                      );
                    }
                    if (snapshot.hasError) {
                      return ListTile(
                        title: Text('Error loading buyer details'),
                        subtitle: Text(snapshot.error.toString()),
                      );
                    }
                    if (!snapshot.hasData) {
                      return ListTile(
                        title: Text('Buyer details not found'),
                        subtitle: Text('The buyer document does not exist in Firestore.'),
                      );
                    }
                    final buyerDetails = snapshot.data!;
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: GestureDetector(
                          onTap: () {
                            // Navigate to the UserCarListingScreen with the buyer's ID
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BuyerCarListingScreen(
                                  userId: rental.buyerRef.id, // Pass the buyer's ID
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Buyer: ${buyerDetails['name']}',
                            style: TextStyle(
                              color: Colors.blue, // Make the text look like a link
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone: ${buyerDetails['phone']}'),
                            Text('Start Date: ${rental.startDate.toLocal()}'),
                            Text('End Date: ${rental.endDate.toLocal()}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.call),
                          onPressed: () async {
                            final url = 'tel:${buyerDetails['phone']}';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Could not launch phone call')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}