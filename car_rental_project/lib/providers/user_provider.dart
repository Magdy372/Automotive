import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:car_rental_project/screens/admin_dashboard.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/login_screen.dart';


class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Constructor: Check if a user is already logged in
  UserProvider() {
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        _currentUser =
            UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    }
  }
// Login Function
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Fetch user data
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User data not found.");
      }

      // Parse user data and update state
      _currentUser = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      notifyListeners();

      // Navigate based on role
      String role = _currentUser!.role;
      Widget targetScreen = (role == 'admin')
          ? const AdminDashboardScreen()
          : const HomeScreen();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );

      // Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
    } on FirebaseAuthException catch (e) {
      _showError(context, e.code == 'user-not-found'
          ? 'No user found for this email.'
          : e.code == 'wrong-password'
              ? 'Incorrect password.'
              : 'An error occurred. Please try again.');
    } catch (e) {
      _showError(context, 'Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Signup Function
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      _showError(context, 'Name must contain only letters and spaces.');
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save user to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update state with new user
      _currentUser = UserModel(
        id: userCredential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        role: role.trim(),
      );
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful!')),
      );

      // Navigate to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      _showError(context, 'Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();

      Navigator.of(context).pushNamedAndRemoveUntil(
      '/onboarding', // Route name
      (route) => false, // Remove all previous routes
    );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }



  Future<void> editUserInfo({
  required String name,
  required String email,
  String? role,
  String? address,
  String? phone,
  required BuildContext context,
}) async {
  if (_currentUser == null) {
    _showError(context, 'No user is logged in.');
    return;
  }

  _isLoading = true;
  notifyListeners();

  // Validate phone (example validation)
  if (phone != null && !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone)) {
    _showError(context, 'Invalid phone number format.');
    _isLoading = false;
    notifyListeners();
    return;
  }

  try {
    await _firestore.collection('users').doc(_currentUser!.id).update({
      'name': name.trim(),
      'email': email.trim(),
      if (role != null) 'role': role.trim(),
      if (address != null) 'address': address.trim(),
      if (phone != null) 'phone': phone.trim(),
    });

    if (_auth.currentUser != null && _auth.currentUser!.email != email.trim()) {
      await _auth.currentUser!.updateEmail(email.trim());
    }

    _currentUser = UserModel(
      id: _currentUser!.id,
      name: name.trim(),
      email: email.trim(),
      role: role ?? _currentUser!.role,
      address: address ?? _currentUser!.address,
      phone: phone ?? _currentUser!.phone,
    );
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User information updated successfully!')),
    );

    Navigator.pop(context);
  } catch (e) {
    _showError(context, 'Error: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}






  // Helper: Show Error Messages
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    print(UserProvider()._currentUser);
    print('333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333');
    print(message);
  }
}
