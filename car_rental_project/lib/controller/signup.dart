import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_project/screens/login_screen.dart';

class Signup {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Signup Function
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {

     if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Name must contain only letters and spaces.')),
      );
      return;
    }
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update the display name
      await userCredential.user!.updateDisplayName(name.trim());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully!')),
      );

      // Navigate to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
