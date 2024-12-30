import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:car_rental_project/screens/settings_screen.dart';
import 'package:car_rental_project/services/NotificationService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:car_rental_project/models/notificationItem_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem1> notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
    _listenToIncomingNotifications();
  }

  // Load notifications from the database
  Future<void> loadNotifications() async {
    final fetchedNotifications = await NotificationService.getNotifications();
    setState(() {
      notifications = fetchedNotifications;
    });
  }


  // Listen for new notifications
  void _listenToIncomingNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        // Reload notifications dynamically
        final fetchedNotifications =
            await NotificationService.getNotifications();
        setState(() {
          notifications = fetchedNotifications;
        });
      }
    });
  }

  // Filter notifications based on the date
  List<NotificationItem1> filterNotifications(NotificationStatus status) {
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));

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
            notification.date.isBefore(yesterday) &&
            !(notification.date.year == yesterday.year &&
              notification.date.month == yesterday.month &&
              notification.date.day == yesterday.day)).toList();
      default:
        return [];
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 70),
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildSection("Today", NotificationStatus.newItem),
              _buildSection("Yesterday", NotificationStatus.yesterday),
              _buildSection("Older", NotificationStatus.older),
            ],
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),

    );
  }

  Widget _buildHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSection(String title, NotificationStatus status) {
    final filteredNotifications = filterNotifications(status);

    if (filteredNotifications.isEmpty) {
      return const SizedBox.shrink(); // Hide empty sections
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...filteredNotifications.map((notification) {
          return Dismissible(
            key: Key(notification.id.toString()),
            onDismissed: (direction) async {
              // Temporarily store the deleted notification
              final deletedNotification = notification;

              // Remove the notification from the database
              await NotificationService.deleteNotification(notification.id!);

              // Temporarily remove the notification from the list
              setState(() {
                notifications.remove(notification);
              });

              // Show a Snackbar with Undo action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notification deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () async {
                      // Re-insert the notification into the database
                      await NotificationService.saveNotification(
                        deletedNotification.title,
                        deletedNotification.body,
                        deletedNotification.data,
                        deletedNotification.date
                      );

                      // Reload the notifications list
                      loadNotifications();
                    },
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            background: Container(color: Colors.red),
            child: NotificationCard(notification: notification),
          );
        }).toList(),
      ],
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
          selectedIndex: 1,
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

class NotificationCard extends StatelessWidget {
  final NotificationItem1 notification;

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
                DateFormat('dd/MM/yyyy').format(notification.date),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                DateFormat('hh:mm a').format(notification.date),
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
              notification.body,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

enum NotificationStatus { newItem, yesterday, older }
