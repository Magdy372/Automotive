import 'package:car_rental_project/providers/user_provider.dart';
import 'package:car_rental_project/screens/login_screen.dart';
import 'package:car_rental_project/screens/my_bookings_screen.dart';
import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:car_rental_project/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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
              iconColor: Colors.black,
              label: 'Account',
              labelColor: Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            _buildListTile(
              icon: Icons.car_rental, 
              iconColor: Colors.black,
              label: 'My bookings', 
              labelColor: Colors.black,             
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyBookingsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            _buildListTile(
              icon: Icons.notifications,
              iconColor: Colors.black,
              label: 'Notifications',
              labelColor: Colors.black,
            onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            _buildListTile(icon: Icons.visibility, iconColor: Colors.black, label: 'Appearance',labelColor: Colors.black, onTap: () {}),
            const Divider(),
            _buildListTile(icon: Icons.lock, iconColor: Colors.black, label: 'Privacy & Security',labelColor: Colors.black, onTap: () {}),
            const Divider(),
            _buildListTile(icon: Icons.headphones, iconColor: Colors.black, label: 'Help and Support',labelColor: Colors.black, onTap: () {}),
            const Divider(),
            _buildListTile(icon: Icons.info, iconColor: Colors.black, label: 'About',labelColor: Colors.black, onTap: () {}),
            const Divider(),
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
                          child: const Text(
                            "No",
                            style: TextStyle(
                            color: Colors.black
                            )),
                          onPressed: () {
                            Navigator.of(context).pop();  // Close the dialog
                          },
                        ),
                        TextButton(
                          child: const Text(
                            "Yes",
                            style: TextStyle(
                            color: Colors.red
                            )),
                          onPressed: () {
                            userProvider.logout(context);
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                              ),
                            );
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            )        ],
        ),
      ),
    );
  }   

  Widget _buildListTile({required IconData icon,required Color iconColor, required String label,required Color labelColor, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(fontSize: 16, color: labelColor),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      onTap: onTap,
    );
  }
}
