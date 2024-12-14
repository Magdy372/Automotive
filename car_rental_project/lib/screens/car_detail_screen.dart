import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:car_rental_project/models/car_model.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:car_rental_project/screens/settings_screen.dart';

class CarDetailScreen extends StatefulWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  _CarDetailScreenState createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final Map<String, bool> _selectedFeatures = {
    "Bluetooth": false,
    "Apple CarPlay": false,
    "Android Auto": false,
    "360 Camera": false,
    "Parking Sensors": false,
    "Navigation": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      widget.car.image, // Replace with your car image path
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCarInfo(),
                  const SizedBox(height: 20),
                  _buildSpecifications(),
                  const SizedBox(height: 20),
                  _buildFeatures(),
                  const SizedBox(height: 20),
                  _buildDescription(),
                  const SizedBox(height: 20),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomavBar(context), // Add the bottom navigation bar here
    );
  }

  Widget _buildCarInfo() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.car.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.speed, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text("300 km/h", style: TextStyle(color: Colors.grey)),
                SizedBox(width: 16),
                Icon(Icons.settings, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text("Automatic", style: TextStyle(color: Colors.grey)),
                SizedBox(width: 16),
                Icon(Icons.local_gas_station, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text("50L", style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "\$${widget.car.price}/day",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Specifications",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _specificationCard("350 HP", "Power"),
            _specificationCard("4.5", "0-60 mph"),
            _specificationCard("300 km/h", "Top Speed"),
          ],
        ),
      ],
    );
  }

  Widget _specificationCard(String title, String subtitle) {
    return Expanded(
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Features",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 10, // Adds vertical spacing
          children: _selectedFeatures.keys.map((feature) {
            return GestureDetector(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      _selectedFeatures[feature]! ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  feature,
                  style: TextStyle(
                    color: _selectedFeatures[feature]!
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          "Experience luxury and performance with the Mercedes AMG GT. This stunning vehicle combines cutting-edge technology with elegant design to deliver an unforgettable driving experience.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      // onPressed: () => {
      //  Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => const CreditCardScreen()),
      //  )
      // },
      onPressed: () {  },
      child: const Padding(
        padding: EdgeInsets.all(12), 
        child: Text(
          "Book Now",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    ),
  );
}

  Widget _bottomavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(50), // Apply border radius here
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: GNav(
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: const Color.fromARGB(255, 66, 66, 66),
          padding: const EdgeInsets.all(16),
          gap: 8,
 onTabChange: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              break;
          }
        },
          tabs: const [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.notifications, text: 'Notifications'),
            GButton(icon: Icons.person, text: 'Profile'),
            GButton(icon: Icons.settings, text: 'Settings'),
          ],
        ),
      ),
    );
  }
}
