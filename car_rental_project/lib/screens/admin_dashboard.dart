import 'package:car_rental_project/screens/car_listing_screen.dart';
import 'package:car_rental_project/screens/login_screen.dart';
import 'package:car_rental_project/screens/user_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart'; // Import the UserModel
import '../models/car_model.dart'; // Import CarModel

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<UserModel> lastTwoUsers = [];
  int totalUsers = 0;
  int totalCars = 0;
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!isDataLoaded) {
      fetchData();
    }
  }

  // Function to fetch all data
  Future<void> fetchData() async {
    try {
      await Future.wait([
        fetchLastTwoUsers(),
        fetchTotalUsers(),
        fetchTotalCars(),
      ]);
      setState(() {
        isDataLoaded = true;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Fetch the total number of cars from Firestore
  Future<void> fetchTotalCars() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Cars').get();
      setState(() {
        totalCars = snapshot.docs.length;
      });
    } catch (e) {
      print("Error fetching total cars: $e");
    }
  }

  // Fetch last two users from Firestore
  Future<void> fetchLastTwoUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(6)
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

  // Fetch the total number of users
  Future<void> fetchTotalUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        totalUsers = snapshot.docs.length;
      });
    } catch (e) {
      print("Error fetching total users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (!isDataLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      
      backgroundColor: isDarkMode? Colors.black:Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title:  Text('Admin Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold,color: isDarkMode? Colors.grey[300]:Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
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
               Text(
                'App data',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode? Colors.grey[300]:Colors.black,
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
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CarListingScreen(),
                        ),
                      );
                    },
                    child: StatsCard(
                      title: 'Total Cars',
                      count: totalCars.toString(),
                      icon: Icons.directions_car,
                      textColor: Colors.white,
                   backgroundColor: isDarkMode
              ? const Color(0xFF333333) // Example dark mode background color
           : const Color(0xFF97B3AE), // Light mode background color
            back2: isDarkMode
      ? const Color(0xFF222222) // Example dark mode back2 color
      : const Color(0xFF97B3AE),                      
      iconColor: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserListingScreen(),
                        ),
                      );
                    },
                    child: StatsCard(
                      title: 'Total Users',
                      count: totalUsers.toString(),
                      icon: Icons.group,
                      textColor: Colors.white,
                     backgroundColor: isDarkMode
              ? const Color(0xFF333333) // Example dark mode background color
      : const Color(0xFF97B3AE), // Light mode background color
  back2: isDarkMode
      ? const Color(0xFF222222) // Example dark mode back2 color
      : const Color(0xFF97B3AE), // Light mode back2 color
                      iconColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Recent Users',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
             
              const SizedBox(height: 10),
              lastTwoUsers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDarkMode? Colors.grey[900]:Color(0XFF97B3AE),
                      ),
                      child: DataTable(
                        headingRowHeight: 48,
                        dataRowHeight: 48,
                        horizontalMargin: 16,
                        columnSpacing: 24,
                        columns:  [
                          DataColumn(
                            label: Text(
                              'User',
                              style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode? Colors.grey[300]:Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode? Colors.grey[300]:Colors.white),
                            ),
                          ),
                        ],
                        rows: lastTwoUsers.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(Text(user.name, style:  TextStyle(color:isDarkMode? Colors.grey[300]:Colors.white))),
                              DataCell(Text(user.email, style:  TextStyle(color: isDarkMode? Colors.grey[300]:Colors.white))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                      Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserListingScreen()),
                    );
                  },
                  child:  Text(
                    'View All',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:isDarkMode? Colors.grey[300]:Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
               Text(
                'All Cars',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode? Colors.grey[300]:Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              // StreamBuilder for Cars
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Cars').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final cars = snapshot.data!.docs.map((doc) {
                    return Car.fromMap(doc.data() as Map<String, dynamic>, doc.reference);
                  }).toList();

                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                        color: isDarkMode? Colors.grey[900]:Color(0XFF97B3AE),
                    ),
                    child: DataTable(
                      headingRowHeight: 48,
                      dataRowHeight: 48,
                      horizontalMargin: 16,
                      columnSpacing: 24,
                      columns: [
                        DataColumn(
                          label: Text(
                            'Car Name',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDarkMode? Colors.grey[300]:Colors.white),
                          ),
                        ),
                         DataColumn(
                          label: Text(
                            'Brand',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDarkMode? Colors.grey[300]:Colors.white),
                          ),
                        ),
                      ],
                      rows: cars.map((car) {
                        return DataRow(
                          cells: [
                            DataCell(Text(car.name, style:  GoogleFonts.poppins(color: isDarkMode? Colors.grey[300]:Colors.white))),
                            DataCell(Text(car.brand.toString().split('.').last, style:  GoogleFonts.poppins(color: isDarkMode? Colors.grey[300]:Colors.white))),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CarListingScreen()),
                    );
                  },
                  child:  Text(
                    'View All',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode? Colors.grey[300]:Colors.black),
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
  final Color iconColor;
  
  final Color back2;

  const StatsCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
    required this.back2,
    required this.iconColor,
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
            Icon(icon, size: 40, color: iconColor),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 15,
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
