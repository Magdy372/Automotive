import 'package:car_rental_project/models/user_model.dart';
import 'package:car_rental_project/screens/admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListingScreen extends StatelessWidget {
  const UserListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Listing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        cardColor: const Color(0xFF1F1F1F),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
          bodySmall: TextStyle(color: Colors.white54),
        ),
        fontFamily: 'Roboto',
      ),
      home: const UserListingScreenBody(),
    );
  }
}

class UserListingScreenBody extends StatefulWidget {
  const UserListingScreenBody({super.key});

  @override
  _UserListingScreenBodyState createState() => _UserListingScreenBodyState();
}

class _UserListingScreenBodyState extends State<UserListingScreenBody> {
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsersFromFirestore();
  }

  Future<void> fetchUsersFromFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        users = snapshot.docs.map((doc) {
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
        title: const Text('User Listing', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
           Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                    );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Users List',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 73, 72, 72),
                ),
              ),
              const SizedBox(height: 20),
              users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        UserModel user = users[index];
                        return UserCard(
                          userName: user.name,
                          userEmail: user.email,
                          userRole: user.role,
                          userAddress: user.address ?? 'Not provided',
                          userPhone: user.phone ?? 'Not provided',
                        );
                      },
                    ),
            ],
          ),
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
            Text('Address: $userAddress'),
            Text('Phone: $userPhone'),
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
