import 'package:car_rental_project/components/booking_card_component.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:car_rental_project/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('My Bookings',
            style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.grey[300] : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Tab Section: Upcoming and Previous
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Upcoming',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Divider(
                          thickness: 2,
                          color: isDarkMode
                              ? Colors.grey[300]
                              : const Color(0XFF97B3AE)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Previous',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400, fontSize: 16)),
                      const SizedBox(height: 5),
                      const Divider(thickness: 2, color: Colors.transparent),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Ticket Card
          const Expanded(
            child: SingleChildScrollView(
              child: BookingCard(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
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
            // tabBackgroundColor: Colors.white.withOpacity(0.30),
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
              GButton(icon: Icons.home),
              GButton(icon: Icons.notifications),
              GButton(icon: Icons.person),
              GButton(icon: Icons.settings),
            ],
          ),
        ),
      ),
    );
  }
}
