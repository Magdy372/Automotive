import 'package:car_rental_project/providers/user_provider.dart';
import 'package:car_rental_project/screens/login_screen.dart';
import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:car_rental_project/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);

    // Get screen size using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;

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
              fontSize: screenWidth * 0.06, // Responsive font size
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              children: [
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
                  },
                  isDarkMode: isDarkMode,
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
                  },
                  isDarkMode: isDarkMode,
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
                          title: Text(
                            "Logout",
                          style: GoogleFonts.poppins(
                          color: Colors.black),
                          ),
                          content: Text("Do you really want to logout?",
                          style: GoogleFonts.poppins(
                          color: Colors.black),
                          ),
                          
                          actions: <Widget>[
                            TextButton(
                              child: Text("No", style: GoogleFonts.poppins(color: Colors.black)),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                            TextButton(
                              child: Text("Yes", style: GoogleFonts.poppins(color: Colors.red)),
                              onPressed: () {
                                userProvider.logout(context);
                                //SystemNavigator.pop();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ],
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
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDarkMode ? Colors.grey[300] : const Color(0XFF97B3AE)),
      onTap: onTap,
    );
  }
}