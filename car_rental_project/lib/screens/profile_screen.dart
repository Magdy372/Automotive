import 'package:car_rental_project/providers/rental_provider.dart';
import 'package:car_rental_project/screens/edit_profile_screen.dart';
import 'package:car_rental_project/screens/settings_screen.dart';
import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/car_provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: UserProfilePage(),
    );
  }
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    // Delay the data fetching to happen after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
  }

  void _fetchUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.id ?? '';

    if (userId.isNotEmpty) {
      final rentalProvider = Provider.of<RentalProvider>(context, listen: false);
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      
      // Fetch data
      rentalProvider.fetchRentalsByUser(userId);
      carProvider.getUserCars(userId);
    }
  }

  // Rest of your existing code remains the same
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(child: Text("User not logged in")),
      );
    }
    return Scaffold(
      appBar: AppBar(
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
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
          _buildProfileHeader(user.name, user.email),
          const SizedBox(height: 20),
          _buildUserInfo(user.phone ?? "", user.address ?? ""),
          const SizedBox(height: 20),
          _buildUserCars(),
          const SizedBox(height: 20),
          _buildRecentRentals(),
          const SizedBox(height: 20),

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
      bottomNavigationBar: _buildBottomNavBar(),

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

  Widget _buildUserCars() {
    return Consumer<CarProvider>(
      builder: (context, carProvider, child) {
        final userCars = carProvider.carsbysuser;

        if (userCars.isEmpty) {
          return const Center(child: Text("You have no cars uploaded."));
        }

        return Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Cars",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 10),
                // Display cars owned by the user
                for (var car in userCars)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Car brand and name
                        Text(
                          "${car.brand.toString().split('.').last} - ${car.name}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                        // Car availability status
                        Text(
                          car.isBooked ? "Booked" : "Available",
                          style: TextStyle(
                            color: car.isBooked ? Colors.red : Colors.green,
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
      },
    );
  }

// Recent Rentals Display
Widget _buildRecentRentals() {
  return Consumer<RentalProvider>(builder: (context, rentalProvider, child) {
    final recentRentals = rentalProvider.rentalsForUser;

    if (recentRentals.isEmpty) {
      return const Center(child: Text("No recent rentals found."));
    }

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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            for (var rental in recentRentals)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Car Name',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final carName = rental.id != null 
                              ? rentalProvider.carNames[rental.id] 
                              : null;
                            debugPrint('Rental ${rental.id}: Car name: $carName'); // Debug print
                            return Text(
                              carName ?? 'Unknown Car',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                    // Label and rental duration
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Number of Days', // Label for the number of days
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "${rental.endDate.difference(rental.startDate).inDays} days", // Display the number of days
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  });
}

  // Helper function to create settings options
  Widget _buildSettingsOption(
      String title, IconData icon, BuildContext context) {
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
          title: const Text('Payment Methods',
              style: TextStyle(color: Colors.black)),
          onTap: () {
            // Handle payment methods navigation
          },
        ),
      ),
    );
  }

  // Card Widget for the new Cards Section
  Widget _buildCard(
      {required IconData icon,
      required String title,
      required String subtitle,
      double progress = 0.0}) {
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
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
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
  // Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    // Access the current theme's colors dynamically
    // final theme = Theme.of(context);
    // final backgroundColor = theme
    //     .appBarTheme.backgroundColor; // Use theme's AppBar background color
    // final textColor = theme
    //     .colorScheme.onPrimary; // Text/icon color for active/inactive states
    // final activeTabColor =
    //     theme.colorScheme.primary; // Active tab background color

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
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
          selectedIndex: 2,
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
                  MaterialPageRoute(
                      builder: (context) => const NotificationScreen()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
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
