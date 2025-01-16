import 'package:car_rental_project/providers/user_provider.dart';
import 'package:car_rental_project/screens/login_screen.dart';
import 'package:car_rental_project/screens/my_bookings_screen.dart';
import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:car_rental_project/screens/onboarding_screens.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.grey[300] : Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.grey[300] : Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildListTile(
              icon: Icons.person,
              iconColor: isDarkMode ? Colors.grey[300]! : const Color(0xFF97B3AE),
              label: 'Account',
              labelColor: isDarkMode ? Colors.grey[300]! : Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }, isDarkMode: isDarkMode,
            ),
           Divider(
              color: isDarkMode ? Colors.grey[900]! : const Color(0xFF97B3AE),
            ),
            _buildListTile(
              icon: Icons.car_rental,
              iconColor: isDarkMode ? Colors.grey[300]! : const Color(0xFF97B3AE),
              label: 'My bookings',
              labelColor: isDarkMode ? Colors.grey[300]! : Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyBookingsScreen(),
                  ),
                );
              }, isDarkMode: isDarkMode,
            ),
           Divider(
              color: isDarkMode ? Colors.grey[900]! : const Color(0xFF97B3AE),
            ),
            _buildListTile(
              icon: Icons.notifications,
              iconColor: isDarkMode ? Colors.grey[300]! : const Color(0xFF97B3AE),
              label: 'Notifications',
              labelColor: isDarkMode ? Colors.grey[300]! : Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              }, isDarkMode: isDarkMode,
            ),
           Divider(
              color: isDarkMode ? Colors.grey[900]! : const Color(0xFF97B3AE),
            ),
            _buildListTile(
              icon: Icons.visibility,
              iconColor: isDarkMode ? Colors.grey[300]! : const Color(0xFF97B3AE),
              label: 'Appearance',
              labelColor: isDarkMode ? Colors.grey[300]! : Colors.black,
              onTap: () {}, isDarkMode: isDarkMode,
            ),
           Divider(
              color: isDarkMode ? Colors.grey[900]! : const Color(0xFF97B3AE),
            ),
            _buildListTile(
              icon: Icons.lock,
              iconColor: isDarkMode ? Colors.grey[300]! : const Color(0xFF97B3AE),
              label: 'Privacy & Security',
              labelColor: isDarkMode ? Colors.grey[300]! : Colors.black,
              onTap: () {}, isDarkMode: isDarkMode,
            ),
           Divider(
              color: isDarkMode ? Colors.grey[900]! : const Color(0xFF97B3AE),
            ),
            _buildListTile(
              icon: Icons.headphones,
              iconColor: isDarkMode ? Colors.grey[300]! : const Color(0xFF97B3AE),
              label: 'Help and Support',
              labelColor: isDarkMode ? Colors.grey[300]! : Colors.black,
              onTap: () {}, isDarkMode: isDarkMode,
            ),
           Divider(
              color: isDarkMode ? Colors.grey[900]! : const Color(0xFF97B3AE),
            ),
            _buildListTile(
              icon: Icons.info,
              iconColor: isDarkMode ? Colors.grey[300]! : const Color(0xFF97B3AE),
              label: 'About',
              labelColor: isDarkMode ? Colors.grey[300]! : Colors.black,
              onTap: () {}, isDarkMode: isDarkMode,
            ),
           Divider(
              color: isDarkMode ? Colors.grey[900]! : const Color(0xFF97B3AE),
            ),
            _buildListTile(
              icon: Icons.logout,
              iconColor: Colors.red,
              label: 'Logout',
              labelColor: Colors.red,
              onTap: () {
                // Show a confirmation dialog when the logout is tapped
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text("Logout"),
                      content: const Text("Do you really want to logout?"),
                      actions: <Widget>[
                        TextButton(
                          child:  Text("No", style: GoogleFonts.poppins(color: Colors.black)),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child:  Text("Yes", style: GoogleFonts.poppins(color: Colors.red)),
                          onPressed: () {
                            userProvider.logout(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              }, isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color labelColor,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 16, color: labelColor),
      ),
      trailing:  Icon(Icons.arrow_forward_ios, size: 16, color: isDarkMode? Colors.grey[300]:Color(0XFF97B3AE)),
      onTap: onTap,
    );
  }
}
