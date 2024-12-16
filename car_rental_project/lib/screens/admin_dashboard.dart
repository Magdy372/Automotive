import 'package:car_rental_project/screens/user_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Import the UserModel
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<UserModel> lastTwoUsers = [];

  @override
  void initState() {
    super.initState();
    fetchLastTwoUsers();
  }

  // Fetch last two users from Firestore
  Future<void> fetchLastTwoUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true) // Assuming you have a 'createdAt' field
          .limit(2)
          .get();

      setState(() {
        lastTwoUsers = snapshot.docs.map((doc) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 73, 72, 72),
                ),
              ),
              
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  StatsCard(
                    title: 'Total Cars',
                    count: '50',
                    icon: Icons.directions_car,
                    textColor: Colors.white,
                    backgroundColor: Colors.teal,
                  ),
                  StatsCard(
                    title: 'Rented Cars',
                    count: '15',
                    icon: Icons.car_repair,
                    textColor: Colors.white,
                    backgroundColor: Colors.deepOrange,
                  ),
                  StatsCard(
                    title: 'Total Users',
                    count: '120',
                    icon: Icons.group,
                    textColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  StatsCard(
                    title: 'Clients',
                    count: '75',
                    icon: Icons.people,
                    textColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Average Rental Duration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 73, 72, 72),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 40,
                        color: Colors.teal,
                        title: '1-3 Days',
                        titleStyle: const TextStyle(color: Colors.black),
                      ),
                      PieChartSectionData(
                        value: 30,
                        color: Colors.orange,
                        title: '4-7 Days',
                        titleStyle: const TextStyle(color: Colors.black),
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: Colors.blue,
                        title: '8-14 Days',
                        titleStyle: const TextStyle(color: Colors.black),
                      ),
                      PieChartSectionData(
                        value: 10,
                        color: Colors.red,
                        title: '15+ Days',
                        titleStyle: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
             
              const SizedBox(height: 10),
              SizedBox(
                height: 3,
              ),
              // Users List Button (kept at the bottom as well)
             /* Container(
                width: double.infinity, // Makes the button full width
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Adds margin to give some space around the button
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserListingScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Pill shape for the button
                    ),
                    elevation: 6, // Adds a shadow for a lifted effect
                    shadowColor: const Color.fromARGB(255, 0, 0, 0), // Custom shadow color
                    textStyle: const TextStyle(
                      fontSize: 18, // Larger font size
                      fontWeight: FontWeight.bold, // Bold text for emphasis
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centers the content horizontally
                    children: const [
                      Icon(
                        Icons.arrow_forward, // Arrow icon
                        color: Colors.white,
                      ),
                      SizedBox(width: 15), // Space between the icon and the text
                      Text(
                        'View Users List',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),*/
              const SizedBox(height: 20),
              // Display last two users at the bottom
              const Text(
                'Recent Users',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 73, 72, 72),
                ),
              ),
              const SizedBox(height: 10),
              lastTwoUsers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lastTwoUsers.length,
                      itemBuilder: (context, index) {
                        UserModel user = lastTwoUsers[index];
                        return UserCard(
                          userName: user.name,
                          userEmail: user.email,
                          userRole: user.role,
                          userAddress: user.address ?? 'Not provided',
                          userPhone: user.phone ?? 'Not provided',
                        );
                      },
                    ),
              // View All button behind recent users
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserListingScreen()),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color textColor;
  final Color backgroundColor;

  const StatsCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 40, color: textColor),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final String userAddress;
  final String userPhone;

  const UserCard({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.userAddress,
    required this.userPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          userName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $userEmail'),
            Text('Role: $userRole'),
            /*Text('Address: $userAddress'),
            Text('Phone: $userPhone'),*/
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Handle tap event (navigate to a detailed page if needed)
        },
      ),
    );
  }
}
