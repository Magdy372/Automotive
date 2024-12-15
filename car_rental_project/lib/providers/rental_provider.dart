import 'package:car_rental_project/models/rental_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RentalProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to store rental data locally
  List<RentalModel> _rentals = [];

  // Getter to get the rentals
  List<RentalModel> get rentals => _rentals;

  // Fetch rentals from Firestore
  Future<void> fetchRentals() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Rentals').get();
      _rentals = snapshot.docs.map((doc) {
        return RentalModel.fromMap(doc.data() as Map<String, dynamic>, doc.reference);
      }).toList();
      notifyListeners();  // Notify listeners that rentals have been updated
    } catch (e) {
      print("Error fetching rentals: $e");
    }
  }

  // Add a new rental to Firestore
  Future<void> addRental(RentalModel rental) async {
    try {
      // Add rental document to Firestore
      DocumentReference docRef = await _firestore.collection('Rentals').add(rental.toMap());
      rental.id = docRef.id;  // Set the document ID from Firestore to rental
      _rentals.add(rental);  // Add the rental to local list
      notifyListeners();  // Notify listeners that a new rental has been added
    } catch (e) {
      debugPrint("Error adding rental: $e");
    }
  }

  // Update an existing rental in Firestore
  Future<void> updateRental(String rentalId, RentalModel updatedRental) async {
    try {
      await _firestore.collection('Rentals').doc(rentalId).update(updatedRental.toMap());
      int index = _rentals.indexWhere((rental) => rental.id == rentalId);
      if (index != -1) {
        _rentals[index] = updatedRental;  // Update the local rental data
        notifyListeners();  // Notify listeners about the update
      }
    } catch (e) {
      debugPrint("Error updating rental: $e");
    }
  }

  // Delete a rental from Firestore
  Future<void> deleteRental(String rentalId) async {
    try {
      await _firestore.collection('Rentals').doc(rentalId).delete();
      _rentals.removeWhere((rental) => rental.id == rentalId);  // Remove rental locally
      notifyListeners();  // Notify listeners about the change
    } catch (e) {
      debugPrint("Error deleting rental: $e");
    }
  }



  // Clear filters
  void clearFilters() {
    fetchRentals();  // Fetch rentals again to show the unfiltered list
    notifyListeners();  // Notify listeners after clearing filters
  }
}
