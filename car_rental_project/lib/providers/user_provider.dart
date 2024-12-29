import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:car_rental_project/screens/admin_dashboard.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/login_screen.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  UserProvider() {
    _checkUserLoggedIn();
  }

  // Utility Functions
  Future<void> _setLoadingState(bool loading) async {
    _isLoading = loading;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  Future<void> _navigateToAppropriateScreen(BuildContext context) async {
    Widget targetScreen = (_currentUser?.role == 'admin')
        ? const AdminDashboardScreen()
        : const HomeScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  Future<void> _saveUserToFirestore(String uid, String name, String email, {String role = 'user'}) async {
    await _firestore.collection('users').doc(uid).set({
      'id': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Main Functions
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

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Validate email and password
    final emailError = UserModel.validateEmail(email);
    if (emailError != null) {
      _showError(context, emailError);
      return;
    }

    final passwordError = UserModel.validatePassword(password);
    if (passwordError != null) {
      _showError(context, passwordError);
      return;
    }

    await _setLoadingState(true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User data not found.");
      }

      _currentUser = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      notifyListeners();

      await _navigateToAppropriateScreen(context);
      _showSuccess(context, 'Login successful!');
    } on FirebaseAuthException catch (e) {
      _showError(context, e.code == 'user-not-found'
          ? 'No user found for this email.'
          : e.code == 'wrong-password'
              ? 'Incorrect password.'
              : 'An error occurred. Please try again.');
    } catch (e) {
      _showError(context, 'Error: $e');
    } finally {
      await _setLoadingState(false);
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    required BuildContext context,
  }) async {
    // Validate all fields
    final validationErrors = UserModel.validateAll(
      name: name,
      email: email,
      password: password,
      
    );

    // Check for any validation errors
    for (var entry in validationErrors.entries) {
      if (entry.value != null) {
        _showError(context, entry.value!);
        return;
      }
    }

    await _setLoadingState(true);
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _saveUserToFirestore(
        userCredential.user!.uid,
        name.trim(),
        email.trim(),
        role: role.trim(),
      );

      _currentUser = UserModel(
        id: userCredential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        role: role.trim(),
      );
      notifyListeners();

      _showSuccess(context, 'Signup successful!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError(context, 'This email is already registered.');
      } else {
        _showError(context, 'Error: ${e.message}');
      }
    } catch (e) {
      _showError(context, 'Error: $e');
    } finally {
      await _setLoadingState(false);
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

    // Validate all fields
    final validationErrors = UserModel.validateAll(
      name: name,
      email: email,
      address: address,
      phone: phone,
    );

    // Check for any validation errors
    for (var entry in validationErrors.entries) {
      if (entry.value != null) {
        _showError(context, entry.value!);
        return;
      }
    }

    await _setLoadingState(true);
    try {
      Map<String, dynamic> updateData = {
        'name': name.trim(),
        'email': email.trim(),
        if (role != null) 'role': role.trim(),
        if (address != null) 'address': address.trim(),
        if (phone != null) 'phone': phone.trim(),
      };

      await _firestore.collection('users').doc(_currentUser!.id).update(updateData);

      if (_auth.currentUser != null && _auth.currentUser!.email != email.trim()) {
        await _auth.currentUser!.updateEmail(email.trim());
      }

      _currentUser = _currentUser!.copyWith(
        name: name.trim(),
        email: email.trim(),
        role: role,
        address: address,
        phone: phone,
      );
      notifyListeners();

      _showSuccess(context, 'User information updated successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showError(context, 'Error: $e');
    } finally {
      await _setLoadingState(false);
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    final emailError = UserModel.validateEmail(email);
    if (emailError != null) {
      _showError(context, emailError);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _showSuccess(context, 'Password reset email sent. Check your inbox!');
      Navigator.pop(context);
    } catch (e) {
      _showError(context, 'Error: $e');
    }
  }
/*
  Future<void> signInWithGoogle(BuildContext context) async {
    await _setLoadingState(true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        await _setLoadingState(false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _saveUserToFirestore(
          userCredential.user!.uid,
          userCredential.user!.displayName ?? 'Unknown User',
          userCredential.user!.email ?? '',
        );
      }

      _currentUser = UserModel(
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? 'Unknown User',
        email: userCredential.user!.email ?? '',
        role: 'user',
      );
      notifyListeners();

      await _navigateToAppropriateScreen(context);
      _showSuccess(context, 'Login successful with Google!');
    } catch (e) {
      _showError(context, 'Google Sign-In failed: $e');
    } finally {
      await _setLoadingState(false);
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    await _setLoadingState(true);
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
          final AccessToken facebookAccessToken = loginResult.accessToken!;
        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(facebookAccessToken.tokenString);

        UserCredential userCredential = await _auth.signInWithCredential(facebookCredential);
        
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          await _saveUserToFirestore(
            userCredential.user!.uid,
            userCredential.user!.displayName ?? 'Unknown User',
            userCredential.user!.email ?? '',
          );
        }

        _currentUser = UserModel(
          id: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? 'Unknown User',
          email: userCredential.user!.email ?? '',
          role: 'user',
        );
        notifyListeners();

        await _navigateToAppropriateScreen(context);
        _showSuccess(context, 'Login successful with Facebook!');
      } else {
        _showError(context, 'Facebook Login cancelled or failed.');
      }
    } catch (e) {
      _showError(context, 'Facebook Login failed: $e');
    } finally {
      await _setLoadingState(false);
    }
  }
*/
  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/onboarding',
        (route) => false,
      );
    } catch (e) {
      _showError(context, 'Error during logout: $e');
    }
  }
  
}