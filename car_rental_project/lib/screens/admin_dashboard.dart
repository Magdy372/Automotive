import 'package:car_rental_project/screens/car_listing_screen.dart';
import 'package:car_rental_project/screens/login_screen.dart';
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
  int totalUsers = 0; // To store the real number of users
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
        isDataLoaded = true; // Ensure isDataLoaded is set after fetching data
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Fetch the total number of cars from Firestore
  Future<void> fetchTotalCars() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Cars').get();
      print("Total cars fetched: ${snapshot.docs.length}");
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
          .orderBy('createdAt', descending: true) // Assuming you have a 'createdAt' field
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
        totalUsers = snapshot.docs.length; // Get the total count of documents in the 'users' collection
      });
    } catch (e) {
      print("Error fetching total users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isDataLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A202C),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  LoginScreen()),
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
              const Text(
                'App data',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
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
  count: totalCars.toString(), // Display the actual number of cars
  icon: Icons.directions_car,
  textColor: Colors.white,
  backgroundColor: const Color(0xFF2D3748), // Updated background color
  iconColor: Colors.orange, 
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
                      count: totalUsers.toString(), // Dynamic user count
                      icon: Icons.group,
                      textColor: Colors.white,
                      backgroundColor: const Color(0xFF2D3748),
                      iconColor: Colors.blue, 
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
        width: double.infinity, // Full width of the page
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color:const Color(0xFF2D3748),
        ),
        child: DataTable(
          headingRowHeight: 48, // Consistent height for the heading row
          dataRowHeight: 48, // Consistent height for data rows
          horizontalMargin: 16, // Consistent padding
          columnSpacing: 24, // Space between columns
          columns: const [
            DataColumn(
              label: Text(
                'User',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
          rows: lastTwoUsers.map((user) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    user.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
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
              const SizedBox(height: 20),
              const Text(
                'App Growth Over Time',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(0), // Display as integer
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Jan');
                              case 1:
                                return const Text('Feb');
                              case 2:
                                return const Text('Mar');
                              case 3:
                                return const Text('Apr');
                              case 4:
                                return const Text('May');
                              case 5:
                                return const Text('Jun');
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d), width: 1),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 1),  // Jan
                          const FlSpot(1, 1.5), // Feb
                          const FlSpot(2, 1.8), // Mar
                          const FlSpot(3, 2),  // Apr
                          const FlSpot(4, 2.5), // May
                          const FlSpot(5, 3),  // Jun
                        ],
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 4,
                        belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Average Car Rent Duration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
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
                        title: '',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        radius: 50,
                        badgeWidget: Transform.rotate(
                          angle: -0.1,
                          child: const Text(
                            '1-3 Days',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      PieChartSectionData(
                        value: 30,
                        color: Colors.orange,
                        title: '',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        radius: 50,
                        badgeWidget: Transform.rotate(
                          angle: -1.1,
                          child: const Text(
                            '4-7 Days',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: Colors.blue,
                        title: '',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        radius: 50,
                        badgeWidget: Transform.rotate(
                          angle: 0.2,
                          child: const Text(
                            '8-14 Days',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      PieChartSectionData(
                        value: 10,
                        color: Colors.red,
                        title: '',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        radius: 50,
                        badgeWidget: Transform.rotate(
                          angle: 1.1,
                          child: const Text(
                            '15+ Days',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
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

  const StatsCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
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