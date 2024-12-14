import 'package:car_rental_project/screens/my_bookings_screen.dart';
import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              label: 'Account',
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
            _buildListTile(icon: Icons.car_rental, label: 'My bookings',              
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
            _buildListTile(icon: Icons.notifications, label: 'Notifications',
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
            _buildListTile(icon: Icons.visibility, label: 'Appearance', onTap: () {}),
            const Divider(),
            _buildListTile(icon: Icons.lock, label: 'Privacy & Security', onTap: () {}),
            const Divider(),
            _buildListTile(icon: Icons.headphones, label: 'Help and Support', onTap: () {}),
            const Divider(),
            _buildListTile(icon: Icons.info, label: 'About', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      onTap: onTap,
    );
  }
}
