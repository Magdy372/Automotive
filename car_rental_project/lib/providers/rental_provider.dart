import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_project/models/rental_model.dart';

class RentalProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<RentalModel> _rentals = [];
  bool _isLoading = false;

  List<RentalModel> get rentals => _rentals;
  bool get isLoading => _isLoading;

  // Fetch rentals for a specific user
  Future<void> fetchRentalsByUser(String userId) async {
    try {
      // Query rentals where the buyer matches the user ID
      QuerySnapshot snapshot = await _firestore
          .collection('Rentals')
          .where('buyer', isEqualTo: 'Users/$userId')
          .get();

      // Convert documents to RentalModel
      _rentals = await Future.wait(
          snapshot.docs.map((doc) => RentalModel.fromDocumentSnapshot(doc)));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching user rentals: $e');
      notifyListeners();
      rethrow;
    }
  }

  // Add a new rental
  Future<RentalModel> addRental(RentalModel rental) async {
    try {
      // Validate car availability
      await _validateCarAvailability(rental);

      // Add rental to Firestore
      DocumentReference rentalRef =
          await _firestore.collection('Rentals').add(rental.toMap());

      // Update the rental with its new ID
      rental.id = rentalRef.id;

      // Update car's booked dates
      await _updateCarBookedDates(rental);

      // Add to local list
      _rentals.add(rental);
      notifyListeners();

      return rental;
    } catch (e) {
      debugPrint('Error adding rental: $e');
      rethrow;
    }
  }

  // Validate car availability for specific dates
  Future<void> _validateCarAvailability(RentalModel rental) async {
    // Get car document
    DocumentSnapshot carDoc = await rental.car.get();
    if (!carDoc.exists) {
      throw Exception('Car not found');
    }

    // Get existing booked dates
    List<dynamic> bookedDates = (carDoc['bookedDates'] ?? []) as List<dynamic>;

    // Check for date overlaps
    for (int i = 0; i < bookedDates.length; i += 2) {
      DateTime existingStart = (bookedDates[i] as Timestamp).toDate();
      DateTime existingEnd = (bookedDates[i + 1] as Timestamp).toDate();

      if (_datesOverlap(
          rental.startDate, rental.endDate, existingStart, existingEnd)) {
        throw Exception('Car not available for selected dates');
      }
    }
  }

  // Check if two date ranges overlap
  bool _datesOverlap(
      DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  // Update car's booked dates
  Future<void> _updateCarBookedDates(RentalModel rental) async {
    await rental.car.update({
      'bookedDates': FieldValue.arrayUnion([
        Timestamp.fromDate(rental.startDate),
        Timestamp.fromDate(rental.endDate),
      ])
      
      
    });
    notifyListeners();
  }

  // Fetch all rentals (for admin use)
  Future<void> fetchAllRentals() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore.collection('Rentals').get();

      _rentals = await Future.wait(
          snapshot.docs.map((doc) => RentalModel.fromDocumentSnapshot(doc)));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching all rentals: $e');
      notifyListeners();
      rethrow;
    }
  }

  // Clear rentals
  void clearRentals() {
    _rentals = [];
    notifyListeners();
  }
}
