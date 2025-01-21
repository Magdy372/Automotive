import 'package:car_rental_project/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListingScreen extends StatelessWidget {
  const UserListingScreen({super.key}); // Constructor remains as-is

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:isDarkMode? Colors.black: Colors.white ,
        title: Text(
          "Users",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        
        ),
        centerTitle: true,
      ),
      body: const UserListingScreenBody(), // UserListingScreenBody extracted
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
  bool isLoading = true; // Track loading state
  String errorMessage = ''; // Track error message

  @override
  void initState() {
    super.initState();
    fetchUsersFromFirestore();
  }

  Future<void> fetchUsersFromFirestore() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        users = snapshot.docs.map((doc) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        isLoading = false; // Stop loading once data is fetched
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching users: $e'; // Display error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator()); // Loading state
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage)); // Error state
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDarkMode ? Colors.grey[900] : const Color(0XFF97B3AE),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          userName,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey[300] : Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: $userEmail',
              style: GoogleFonts.poppins(color: isDarkMode ? Colors.grey[300] : Colors.white,
),
            ),
            Text(
              'Role: $userRole',
              style: GoogleFonts.poppins(color: isDarkMode ? Colors.grey[300] : Colors.white),
            ),
            Text(
              'Address: $userAddress',
              style: GoogleFonts.poppins(color: isDarkMode ? Colors.grey[300] : Colors.white),
            ),
            Text(
              'Phone: $userPhone',
              style: GoogleFonts.poppins(color: isDarkMode ? Colors.grey[300] : Colors.white),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward,
          color:isDarkMode ? Colors.grey[300] : Colors.white,
        ),
        onTap: () {
          // Handle tap event (navigate to a detailed page if needed)
        },
      ),
    );
  }
}
