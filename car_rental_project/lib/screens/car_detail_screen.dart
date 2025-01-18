import 'package:car_rental_project/models/user_model.dart';
import 'package:car_rental_project/screens/FavoritesScreen.dart';
import 'package:car_rental_project/screens/edit_profile_screen.dart';
import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:car_rental_project/models/car_model.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:car_rental_project/screens/settings_screen.dart';
import 'package:car_rental_project/screens/booking_screen.dart'; // Import the BookingScreen
import 'package:car_rental_project/services/FavoritesService.dart'; // Import the FavoritesService
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CarDetailScreen extends StatefulWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  _CarDetailScreenState createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  bool _isFavorite = false;
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  // Check if the car is already favorited
  Future<void> _checkIfFavorite() async {
    final isFavorite = await _favoritesService.isFavorite(widget.car.id);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  // Toggle favorite status
  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoritesService.removeFavorite(widget.car.id);
    } else {
      await _favoritesService.addFavorite({
        'carId': widget.car.id,
        'name': widget.car.name,
        'brand': widget.car.brand.toString(),
        'price': widget.car.price,
        'image': widget.car.image,
      });
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final userProvider = Provider.of<UserProvider>(context);
      final user = userProvider.currentUser;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF7F7F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      widget.car.image, // Replace with your car image path
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
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
                  buildFooter(context)
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context), // Add the bottom navigation bar here
    );
  }

  Widget _buildCarInfo() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.car.name,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.speed, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${widget.car.topSpeed} km/h", style: GoogleFonts.poppins(color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.settings, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(widget.car.transmissionType.toString().split('.').last, style: GoogleFonts.poppins(color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.local_gas_station, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${widget.car.tankCapacity}L", style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "\$${widget.car.price}/day",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[300] : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecifications() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Specifications",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.grey[300] : Colors.black),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _specificationCard("${widget.car.horsepower} HP", "Power"),
            _specificationCard("${widget.car.acceleration}s", "0-100 mph"),
            _specificationCard("${widget.car.topSpeed} km/h", "Top Speed"),
          ],
        ),
      ],
    );
  }

  Widget _specificationCard(String title, String subtitle) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Card(
        color: isDarkMode ? Colors.grey[900] : const Color(0XFF97B3AE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(color: isDarkMode ? Colors.grey[300] : Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Features",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.grey[300] : Colors.black),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 10, // Adds vertical spacing
          children: widget.car.features.map((feature) {
            // Convert enum value to a user-friendly string
            final featureName = feature.toString().split('.').last;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                featureName,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.grey[300] : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.car.description,
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildFooter(BuildContext context) {
  return Consumer<UserProvider>(
    builder: (context, userProvider, child) {
      final user = userProvider.currentUser;

      // Ensure user is not null before building the footer
      if (user == null) {
        return Container(); // Return an empty container if the user is null
      }
      return _buildFooter(user, context); // Build the footer with the current user
    },
  );
}

Widget _buildFooter(UserModel user, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.grey[800] : const Color(0XFF97B3AE),
        padding: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {
        if (user.address == null ||
            user.phone == null ||
            user.address == "unknown" ||
            user.phone == "unknown") {
          // Show snackbar message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please enter your phone and address before booking a car.',
              ),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingScreen(car: widget.car),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "Book Now",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isDarkMode ? Colors.grey[300] : Colors.white,
          ),
        ),
      ),
    ),
  );
}

  // Bottom Navigation Bar
  Widget _buildBottomNavBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : const Color(0XFF97B3AE),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: GNav(
            color: isDarkMode ? Colors.grey[300] : Colors.white,
            activeColor: Colors.white,
            padding: const EdgeInsets.all(12),
            gap: 5,
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
                     case 4:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                  );
                  break;
              }
            },
            tabs: const [
              GButton(icon: Icons.home),
              GButton(icon: Icons.notifications),
              GButton(icon: Icons.person),
             
              GButton(icon: Icons.settings),
               GButton(icon: Icons.favorite),
            ],
          ),
        ),
      ),
    );
  }
}