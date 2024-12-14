import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:car_rental_project/models/notificationItem_model.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:car_rental_project/screens/settings_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications = [
    NotificationItem(
        "New notification 1", DateTime.now(), NotificationStatus.newItem),
    NotificationItem(
        "Yesterday's notification",
        DateTime.now().subtract(const Duration(days: 1)),
        NotificationStatus.yesterday),
    NotificationItem(
        "Older notification",
        DateTime.now().subtract(const Duration(days: 3)),
        NotificationStatus.older),
    NotificationItem(
        "Another new notification", DateTime.now(), NotificationStatus.newItem),
    NotificationItem(
        "Some older notification",
        DateTime.now().subtract(const Duration(days: 5)),
        NotificationStatus.older),
  ];

  // Filter notifications based on the status
  List<NotificationItem> filterNotifications(NotificationStatus status) {
    DateTime today = DateTime.now();
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    switch (status) {
      case NotificationStatus.newItem:
        return notifications.where((notification) =>
            notification.date.year == today.year &&
            notification.date.month == today.month &&
            notification.date.day == today.day).toList();
      case NotificationStatus.yesterday:
        return notifications.where((notification) =>
            notification.date.year == yesterday.year &&
            notification.date.month == yesterday.month &&
            notification.date.day == yesterday.day).toList();
      case NotificationStatus.older:
        return notifications.where((notification) =>
            notification.date.isBefore(yesterday)).toList();
      default:
        return [];
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  // Header Section
  Widget _buildHeader() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 70), // Leave space for the bottom nav bar
            children: [
              _buildHeader(), // Display the header here
              const Padding(padding: EdgeInsets.all(8.0)),
              if (filterNotifications(NotificationStatus.newItem).isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Today", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ...filterNotifications(NotificationStatus.newItem).map((notification) {
                  return Dismissible(
                    key: Key(notification.message),
                    onDismissed: (direction) {
                      setState(() {
                        notifications.remove(notification);
                      });
                    },
                    background: Container(color: Colors.grey),
                    child: NotificationCard(notification: notification),
                  );
                }),
              ],
              if (filterNotifications(NotificationStatus.yesterday).isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Yesterday", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ...filterNotifications(NotificationStatus.yesterday).map((notification) {
                  return Dismissible(
                    key: Key(notification.message),
                    onDismissed: (direction) {
                      setState(() {
                        notifications.remove(notification);
                      });
                    },
                    background: Container(color: Colors.grey),
                    child: NotificationCard(notification: notification),
                  );
                }),
              ],
              if (filterNotifications(NotificationStatus.older).isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Older", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ...filterNotifications(NotificationStatus.older).map((notification) {
                  return Dismissible(
                    key: Key(notification.message),
                    onDismissed: (direction) {
                      setState(() {
                        notifications.remove(notification);
                      });
                    },
                    background: Container(color: Colors.grey),
                    child: NotificationCard(notification: notification),
                  );
                }),
              ],
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(50),
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
          selectedIndex: 1, // Set the default selected index to 1 (Notifications tab)
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

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDate(notification.date),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                formatTime(notification.date),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 24, 24, 24),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              notification.message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}
