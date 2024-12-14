import 'package:flutter/material.dart';
import 'package:car_rental_project/screens/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Rental System',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 0, 0, 0),
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
          displayLarge: TextStyle(color: Colors.black),
          displayMedium: TextStyle(color: Colors.black87),
        ),
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 0, 0, 0),
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        cardColor: Colors.white,
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromARGB(255, 0, 0, 0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white).copyWith(surface: Colors.white),
      ),
      home: UserProfilePage(),
    );
  }
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // Sample recent rental data
  final List<String> recentRentals = [
    "Toyota Camry - Rented forr 3 days",
    "Honda Civic - Rented for 5 days",
    "Ford Mustang - Rented for 2 days",
  ];

  // List of cars owned by the user
  List<Map<String, String>> userCars = [
    {"make": "Tesla Model S", "status": "Available"},
    {"make": "BMW X5", "status": "Rented"},
    {"make": "Audi Q7", "status": "Available"},
  ];

  // Controllers for the car upload form
  final TextEditingController makeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();



  // Function to handle the car upload process
  void _uploadCarForRent() {
    if (makeController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty) {
      // Show error if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Add the new car to the list of user cars
    setState(() {
      userCars.add({
        "make": makeController.text,
        "status": "Available",
      });
    });

    // Clear the text fields
    makeController.clear();
    descriptionController.clear();
    priceController.clear();

    // Close the dialog
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Car uploaded successfully'),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: () {
              // Handle edit action, e.g., navigate to edit profile page
              Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfileScreen()),
                  );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(user!.name , user!.email ),
          const SizedBox(height: 20),
          _buildUserInfo(user.phone ?? "", user.address ?? ""),
          const SizedBox(height: 20),
          _buildUserCars(),
          const SizedBox(height: 20),
          _buildRecentRentals(),
          const SizedBox(height: 20),
          _buildUploadCarForRentButton(context),
          
          const SizedBox(height: 20),
          // Cards Section
          _buildCard(
            icon: Icons.discount_outlined,
            title: '100% off 1st Ride',
            subtitle: 'Discover luxury rides - Terms apply',
          ),
          _buildCard(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Invite Friends',
            subtitle: 'Each of you gets 30% off your next ride',
          ),
          _buildCard(
            icon: Icons.security_outlined,
            title: 'Safety Checkup',
            subtitle: 'Boost your safety profile',
            progress: 0.5,
          ),
          const SizedBox(height: 20), // Added spacing before the payment method
          _buildPaymentMethodOption(context),
        ],
      ),
    );
  }

  // Profile header with user photo, name, and email
 Widget _buildProfileHeader(String name, String email) {
  return Center(
    child: Column(
      children: [
        const Icon(
          Icons.account_circle, // Profile icon
          size: 120, // Icon size
          color: Colors.grey, // Icon color
        ),
        const SizedBox(height: 10),
        Text(
          name, // Use the passed name
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          email, // Use the passed email
          style: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    ),
  );
}


Widget _buildUserInfo(String phone, String address) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "User Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Phone Number",
                style: TextStyle(color: Colors.black54),
              ),
              Text(
                phone.isNotEmpty ? phone : "N/A",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.black26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Address",
                style: TextStyle(color: Colors.black54),
              ),
              Flexible(
                child: Text(
                  address.isNotEmpty ? address : "N/A",
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


  // Display the list of cars owned by the user
  Widget _buildUserCars() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Cars",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            for (var car in userCars)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(car["make"]!, style: const TextStyle(fontSize: 16, color: Colors.black)),
                    Text(
                      car["status"]!,
                      style: TextStyle(
                        color: car["status"] == "Available" ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Display recent rentals history
  Widget _buildRecentRentals() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Rentals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            for (var rental in recentRentals)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text(rental, style: const TextStyle(fontSize: 16, color: Colors.black)),
              ),
          ],
        ),
      ),
    );
  }

  // Button to trigger car upload form
  Widget _buildUploadCarForRentButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _showUploadCarDialog(context);
      },
      child: const Text(
        "Upload Car for Rent",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  // Show dialog to upload a car for rent
  void _showUploadCarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Upload Car for Rent", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: makeController,
                decoration: const InputDecoration(labelText: "Car Make & Model", labelStyle: TextStyle(color: Colors.black)),
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Car Description", labelStyle: TextStyle(color: Colors.black)),
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price per Day", labelStyle: TextStyle(color: Colors.black)),
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadCarForRent,
                child: const Text("Upload"),
              ),
            ],
          ),
        );
      },
    );
  }



  // Helper function to create settings options
  Widget _buildSettingsOption(String title, IconData icon, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      onTap: () {
        // Handle navigation or actions
      },
    );
  }

  // Payment method option at the end
  Widget _buildPaymentMethodOption(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          leading: const Icon(Icons.payment, color: Colors.black),
          title: const Text('Payment Methods', style: TextStyle(color: Colors.black)),
          onTap: () {
            // Handle payment methods navigation
          },
        ),
      ),
    );
  }

  // Card Widget for the new Cards Section
  Widget _buildCard({required IconData icon, required String title, required String subtitle, double progress = 0.0}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[800], size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
            if (progress > 0.0) const SizedBox(height: 10),
            if (progress > 0.0) LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}
