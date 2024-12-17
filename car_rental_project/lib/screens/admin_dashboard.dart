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
    } // Fetch the total number of cars
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
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('cars').get(); // Assuming 'cars' is the collection name
      setState(() {
        totalCars = snapshot.docs.length; // Get the total count of documents in the 'cars' collection
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
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarListingScreen(),
                        ),
                      );
                    },
                    child: StatsCard(
                      title: 'Total Cars',
                      count: totalCars.toString(), // Display the actual number of cars
                      icon: Icons.directions_car,
                      textColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
    const StatsCard(
      title: 'Rented Cars',
      count: '15',
      icon: Icons.car_repair,
      textColor: Colors.white,
      backgroundColor: Colors.grey,
    ),
    // Updated Total Users Card with tap functionality
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
                      backgroundColor: Colors.grey,
                    ),
                  ),
    const StatsCard(
      title: 'Clients',
      count: '75',
      icon: Icons.people,
      textColor: Colors.white,
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
    ),
  ],
),

              













const SizedBox(height: 20),
const Text(
  'App Growth Over Time',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 73, 72, 72),
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
          color: Colors.blue,  // Correct color usage
          barWidth: 4,
          belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)), // Correct color usage
        ),
      ],
    ),
  ),
),      
             const SizedBox(height: 10),
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
            angle: -0.1, // Adjust the rotation angle to curve the text
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
            angle: -1.1, // Adjust the rotation angle to curve the text
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
            angle: 0.2, // Adjust the rotation angle to curve the text
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
            angle: 1.1, // Adjust the rotation angle to curve the text
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
              const SizedBox(
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
    color: Colors.black, // Set the card color to black
    elevation: 6,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      title: Text(
        userName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Set text color to white
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email: $userEmail',
            style: const TextStyle(color: Colors.white), // Set text color to white
          ),
          Text(
            'Role: $userRole',
            style: const TextStyle(color: Colors.white), // Set text color to white
          ),
          /* Uncomment these lines if you want to include address and phone
          Text(
            'Address: $userAddress',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Phone: $userPhone',
            style: const TextStyle(color: Colors.white),
          ),
          */
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward,
        color: Colors.white, // Set the trailing icon color to white
      ),
      onTap: () {
        // Handle tap event (navigate to a detailed page if needed)
      },
    ),
  );
}

}
