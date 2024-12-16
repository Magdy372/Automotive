

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_project/models/rental_model.dart';

class RentalProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<RentalModel> _rentals = [];
  bool _isLoading = false;

  List<RentalModel> get rentals => _rentals;
  bool get isLoading => _isLoading;

  // Fetch rentals from Firestore for a specific user
Future<void> fetchRentalsByUser(String userId) async {
  try {
    // Query Firestore for rentals where the buyer matches the userId (buyer is stored as DocumentReference)
    QuerySnapshot snapshot = await _firestore
        .collection('Rentals')
        .where('buyer', isEqualTo: _firestore.doc('Users/$userId')) // Ensure buyer is stored as DocumentReference
        .get();

    // Handle the case of empty results
    if (snapshot.docs.isEmpty) {
      debugPrint('No rentals found for user: $userId');
      _rentals = []; // Set an empty list if no results
    } else {
      // Map documents to RentalModel objects, ensuring references are fetched properly
      _rentals = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;

        // Debugging fetched rental data to inspect structure
        debugPrint('Fetched rental data: $data');

        // Convert the DocumentSnapshot into a RentalModel
        return await RentalModel.fromDocumentSnapshot(doc);
      }).toList());
    }

    // Notify listeners to update the UI after fetching rentals
    notifyListeners();
  } catch (e) {
    debugPrint('Error fetching rentals for user: $e');
    rethrow; // Rethrow the exception for further handling if needed
  }
}


 // Add a new rental to Firestore
 Future<void> addRental(RentalModel rental) async {
  try {
    // Add the rental to Firestore
   
        await _firestore.collection('Rentals').add(rental.toMap());

    // Add the rental to the local list
    _rentals.add(rental);

    // Notify listeners to update the UI
    notifyListeners();
    debugPrint('Rental added successfully ');
  } catch (e) {
    debugPrint('Error adding rental: $e');
  }
}

  // Optionally, fetch all rentals (if no user is specified or for admins)
  Future<void> fetchAllRentals() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore.collection('Rentals').get();

      _rentals = await Future.wait(snapshot.docs.map((doc) async {
        return await RentalModel.fromDocumentSnapshot(doc);
      }));

    } catch (e) {
      debugPrint('Error fetching all rentals: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Ensure UI is updated
    }
  }

  // Clear rentals or reset after filter
  void clearFilters() {
    _rentals = [];
    notifyListeners();
  }
}

