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
          .where('buyerRef', isEqualTo: _firestore.doc('users/$userId'))
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
    if (rental.buyerRef == _firestore.doc('users/${rental.buyerRef.id}')) {
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
      
      throw Exception('Car not found : id ${rental.car.id}');
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
  Future<void> deleteRental(String rentalId) async {
  try {
    _isLoading = true;
    notifyListeners();

    // Fetch the rental document
    DocumentSnapshot rentalDoc = await _firestore.collection('Rentals').doc(rentalId).get();
    if (!rentalDoc.exists) {
      throw Exception('Rental not found');
    }

    // Convert the document to a RentalModel
    RentalModel rental = await RentalModel.fromDocumentSnapshot(rentalDoc);

    // Fetch the associated car document
    DocumentSnapshot carDoc = await rental.car.get();
    if (!carDoc.exists) {
      throw Exception('Car not found');
    }

    // Remove the booked dates from the car
    await _removeBookedDatesFromCar(rental);

    // Delete the rental document
    await _firestore.collection('Rentals').doc(rentalId).delete();

    // Remove the rental from the local lists
    _rentals.removeWhere((r) => r.id == rentalId);
    _rentalsForUser.removeWhere((r) => r.id == rentalId);

    // Clean up outdated booked dates in the car
    await _cleanUpOutdatedBookedDates(rental.car);

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    debugPrint('Error deleting rental: $e');
    notifyListeners();
    rethrow;
  }
}

  Future<void> _cleanUpOutdatedBookedDates(DocumentReference carRef) async {
    // Fetch the car document
    DocumentSnapshot carDoc = await carRef.get();
    if (!carDoc.exists) {
      throw Exception('Car not found');
    }

    // Get the current booked dates
    List<dynamic> bookedDates = (carDoc['bookedDates'] ?? []) as List<dynamic>;

    // Filter out outdated dates (dates before today)
    List<dynamic> updatedBookedDates = bookedDates.where((date) {
      DateTime bookedDate = (date as Timestamp).toDate();
      return bookedDate.isAfter(DateTime.now());
    }).toList();

    // Update the car document with the new booked dates
    await carRef.update({
      'bookedDates': updatedBookedDates,
    });
  }

Future<void> _removeBookedDatesFromCar(RentalModel rental) async {
  // Fetch the car document
  DocumentSnapshot carDoc = await rental.car.get();
  if (!carDoc.exists) {
    throw Exception('Car not found');
  }

  // Get the current booked dates
  List<dynamic> bookedDates = (carDoc['bookedDates'] ?? []) as List<dynamic>;

  // Convert the rental's start and end dates to Timestamps for comparison
  Timestamp rentalStartTimestamp = Timestamp.fromDate(rental.startDate);
  Timestamp rentalEndTimestamp = Timestamp.fromDate(rental.endDate);

  // Remove the rental's start and end dates from the bookedDates array
  List<dynamic> updatedBookedDates = bookedDates.where((date) {
    return date != rentalStartTimestamp && date != rentalEndTimestamp;
  }).toList();

  // Update the car document with the new booked dates
  await rental.car.update({
    'bookedDates': updatedBookedDates,
  });
}Future<void> fetchRentalsByCar(String carId) async {
  try {
    _isLoading = true;
    notifyListeners();

    debugPrint('Fetching rentals for car ID: $carId');

    // Create a DocumentReference for the car
    final carRef = FirebaseFirestore.instance.collection('Cars').doc(carId);

    // Query rentals where carRef matches the provided car reference
    QuerySnapshot snapshot = await _firestore
        .collection('Rentals')
        .where('carRef', isEqualTo: carRef) // Use DocumentReference
        .get();

    // Log query results
    debugPrint('Query results: ${snapshot.docs.length} documents found');
    for (var doc in snapshot.docs) {
      debugPrint('Document ID: ${doc.id}, Data: ${doc.data()}');
    }

    // Convert documents to RentalModel asynchronously
    _rentalsForCar = await Future.wait(
      snapshot.docs.map((doc) async {
        return await RentalModel.fromDocumentSnapshot(doc);
      }),
    );

    debugPrint('Fetched ${_rentalsForCar.length} rentals for car ID: $carId');

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    debugPrint('Error fetching rentals by car ID: $e');
    notifyListeners();
  }
}
List<RentalModel> _rentalsForCar = [];
List<RentalModel> get rentalsForCar => _rentalsForCar;
  void clearRentals() {
    _rentals = [];
    carNames.clear();  // Also clear car names when clearing rentals
    notifyListeners();
  }
}