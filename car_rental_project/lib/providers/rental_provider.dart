import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_project/models/rental_model.dart';

class RentalProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<RentalModel> _rentals = [];
  List<RentalModel> _rentalsForUser = [];
  bool _isLoading = false;
  Map<String, String> carNames = {};

  List<RentalModel> get rentals => _rentals;
  List<RentalModel> get rentalsForUser => _rentalsForUser;
  bool get isLoading => _isLoading;

  Future<void> fetchRentalsByUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Query rentals where buyerRef matches the user's document reference
      QuerySnapshot snapshot = await _firestore
          .collection('Rentals')
          .where('buyerRef', isEqualTo: _firestore.doc('Users/$userId'))
          .get();

      // Clear existing car names
      carNames.clear();

      // Convert documents to RentalModel and fetch car names
      _rentalsForUser = await Future.wait(
        snapshot.docs.map((doc) async {
          final rental = await RentalModel.fromDocumentSnapshot(doc);
          
          // Fetch car details and store the name
          if (rental.id != null) {
            final car = await rental.getCar();
            if (car != null) {
              carNames[rental.id!] = car.name;
              debugPrint('Stored car name: ${car.name} for rental ${rental.id}');
            }
          }
          
          return rental;
        })
      );

      debugPrint('Fetched ${_rentalsForUser.length} rentals for user');
      debugPrint('Car names map: $carNames');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching user rentals: $e');
      notifyListeners();
   
    }
  }

  Future<RentalModel> addRental(RentalModel rental) async {
  try {
    await _validateCarAvailability(rental);

    // Add rental to Firestore
    DocumentReference rentalRef =
        await _firestore.collection('Rentals').add(rental.toMap());

  

    // Update car's booked dates
    await _updateCarBookedDates(rental);

    // Add to the appropriate list based on the current user
    if (rental.buyerRef == _firestore.doc('Users/${rental.buyerRef.id}')) {
      _rentalsForUser.add(rental);
    }
    _rentals.add(rental);

    notifyListeners();
    return rental;
  } catch (e) {
    debugPrint('Error adding rental: $e');
    rethrow;
  }
}


  Future<void> _validateCarAvailability(RentalModel rental) async {
    DocumentSnapshot carDoc = await rental.car.get();
    if (!carDoc.exists) {
      throw Exception('Car not found');
    }

    List<dynamic> bookedDates = (carDoc['bookedDates'] ?? []) as List<dynamic>;
    
    for (int i = 0; i < bookedDates.length; i += 2) {
      DateTime existingStart = (bookedDates[i] as Timestamp).toDate();
      DateTime existingEnd = (bookedDates[i + 1] as Timestamp).toDate();
      if (_datesOverlap(
          rental.startDate, rental.endDate, existingStart, existingEnd)) {
        throw Exception('Car not available for selected dates');
      }
    }
  }

  bool _datesOverlap(
      DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  Future<void> _updateCarBookedDates(RentalModel rental) async {
    await rental.car.update({
      'bookedDates': FieldValue.arrayUnion([
        Timestamp.fromDate(rental.startDate),
        Timestamp.fromDate(rental.endDate),
      ])
    });
  }

  Future<void> fetchAllRentals() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore.collection('Rentals').get();
      
      // Clear existing car names
      carNames.clear();

      _rentals = await Future.wait(
          snapshot.docs.map((doc) async {
            final rental = await RentalModel.fromDocumentSnapshot(doc);
            
            // Fetch car details and store the name
            if (rental.id != null) {
              DocumentSnapshot carDoc = await rental.car.get();
              if (carDoc.exists) {
                carNames[rental.id!] = carDoc['name'] ?? 'Unknown Car';
              }
            }
            
            return rental;
          }));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching all rentals: $e');
      notifyListeners();
      rethrow;
    }
  }

  void clearRentals() {
    _rentals = [];
    carNames.clear();  // Also clear car names when clearing rentals
    notifyListeners();
  }
}