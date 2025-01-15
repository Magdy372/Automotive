import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode? Colors.black:Colors.white,
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
      bottomNavigationBar: _buildBottomNavBar(context),

    );
  }

  Widget _buildHeader() {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDarkMode? Colors.black:Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isDarkMode? Colors.grey[300]:Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Notifications',
        style: GoogleFonts.poppins(
          color: isDarkMode? Colors.grey[300]:Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSection(String title, NotificationStatus status) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
            style:  GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
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
            background: Container(color:isDarkMode? Colors.grey[300]:Color(0XFF97B3AE)),
            child: NotificationCard(notification: notification),
          );
        }),
      ],
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
            tabBackgroundColor: Colors.white.withOpacity(0.30),
            padding: const EdgeInsets.all(12),
            gap: 5,
            selectedIndex:
                1, // Set the default selected index to 1 (Notifications tab)
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

class NotificationCard extends StatelessWidget {
  final NotificationItem1 notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                style: GoogleFonts.poppins(color:isDarkMode? Colors.grey[300]:Color(0XFF97B3AE), fontSize: 12),
              ),
              Text(
                DateFormat('hh:mm a').format(notification.date),
                style: GoogleFonts.poppins(color:isDarkMode? Colors.grey[300]:Color(0XFF97B3AE), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode? Colors.grey[900]:Color(0XFF97B3AE),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              notification.body,
              style: GoogleFonts.poppins(color:isDarkMode? Colors.grey[300]:Colors.white,),
            ),
          ),
        ],
      ),
    );
  }
}

enum NotificationStatus { newItem, yesterday, older }
