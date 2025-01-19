import 'package:car_rental_project/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/car_model.dart';

class CarProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Car> _cars = [];
  List<Car> _filteredCars = [];

  List<Car> get cars => _cars;
  List<Car> get filtercars => _filteredCars;

  List<Car> _carsbysuser = [];
  List<Car> get carsbysuser => _carsbysuser;

  Car? _recentlyDeletedCar; // Store the recently deleted car



Future<List<Car>> getNearestCars(Position userLocation) async {
    // Calculate distances
    for (var car in _cars) {
      if (car.latitude != null && car.longitude != null) {
        car.distance = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          car.latitude!,
          car.longitude!,
        ) /
            1000; // Convert meters to kilometers
      } else {
        car.distance = double.infinity; // No location data
      }
    }

    // Sort cars by distance
    _cars.sort((a, b) => (a.distance ?? double.infinity)
        .compareTo(b.distance ?? double.infinity));

    return _cars;
  }



  /// Fetch cars from Firestore and update their booking status
  Future<void> fetchCars() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Cars').get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No cars found in Firestore');
      }

      _cars = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        return Car.fromMap(data, doc.reference);
      }).toList());

      _filteredCars = []; // Clear filters after fetching
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching cars: $e');
    }
  }

  /// Add a new car to Firestore and the local list
  Future<void> addCar(Car car) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('Cars').add(car.toMap());
      car.id = docRef.id; // Assign Firestore document ID to the car
      _cars.add(car); // Update the local list
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding car: $e');
    }
  }

  /// Update a car's details in Firestore and the local list
  Future<void> updateCar(String carId, Car updatedCar) async {
    try {
      await _firestore.collection('Cars').doc(carId).update(updatedCar.toMap());
      int index = _cars.indexWhere((car) => car.id == carId);
      if (index != -1) {
        _cars[index] = updatedCar;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating car: $e');
    }
  }

  // /// Remove a car from Firestore and the local list
  // Future<void> deleteCar(String carId) async {
  //   print("deleted car id: $carId");
  //   try {
  //     // Store the deleted car before removing it
  //     _recentlyDeletedCar = _cars.firstWhere((car) => car.id == carId);

  //     await _firestore.collection('Cars').doc(carId).delete();
  //     _cars.removeWhere((car) => car.id == carId);
  //     notifyListeners();
  //   } catch (e) {
  //     debugPrint('Error deleting car: $e');
  //   }
  // }

  Future<void> deleteCar(String carId) async {
    print("Deleted car id: $carId");
    try {
      // Query Firestore to check if a car with the given ID exists
      final carQuery = await _firestore
          .collection('Cars')
          .where('id', isEqualTo: carId) // Check if the 'id' field matches carId
          .get();

      // If no car with the given ID exists, throw an error
      if (carQuery.docs.isEmpty) {
        throw "Car with ID $carId does not exist in the database.";
      }

      // Get the first document from the query result (assuming 'id' is unique)
      final carDoc = carQuery.docs.first;

      // Store the deleted car before removing it
      _recentlyDeletedCar = _cars.firstWhere((car) => car.id == carId);

      // Delete the car from Firestore using the document reference from the query
      await carDoc.reference.delete();

      // Remove the car from the local list
      _cars.removeWhere((car) => car.id == carId);
      _carsbysuser.removeWhere((car) => car.id == carId);


      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting car: $e');
      rethrow; // Rethrow the error to handle it in the UI
    }
  }

  Future<void> restoreCar(UserModel user) async {
    if (_recentlyDeletedCar != null) {
      try {
        // Restore the car to Firestore
        final sellerRef =  FirebaseFirestore.instance.collection('Users').doc(user.id);
        _recentlyDeletedCar?.seller = sellerRef;
        addCar(_recentlyDeletedCar!);
        _carsbysuser.add(_recentlyDeletedCar!);
        _recentlyDeletedCar = null; // Clear the stored car
        
        notifyListeners();
      } catch (e) {
        debugPrint('Error restoring car: $e');
      }
    }
  }

  /// Fetch the cars uploaded by a specific user
  Future<void> getUserCars(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Cars')
          .where('seller', isEqualTo: _firestore.doc('users/$userId'))
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No cars found for this user');
      }

      _carsbysuser = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        return Car.fromMap(data, doc.reference);
      }).toList());

      _filteredCars = []; // Clear the filtered cars after fetching user cars
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user cars: $e');
    }
  }

  /// Add a rating to a car
Future<void> rateCar(String carId, double rating) async {
  try {
    final carDoc = _firestore.collection('Cars').doc(carId);

    // Fetch the current ratings array
    final docSnapshot = await carDoc.get();
    if (!docSnapshot.exists) {
      throw Exception('Car document not found in Firestore');
    }

    final currentRatings = (docSnapshot['ratings'] as List<dynamic>?)?.cast<double>() ?? [];
    final updatedRatings = [...currentRatings, rating]; // Add the new rating

    // Calculate the average rating
    final averageRating = updatedRatings.reduce((a, b) => a + b) / updatedRatings.length;

    // Update Firestore with the new ratings array and average rating
    await carDoc.update({
      'ratings': updatedRatings, // Update the ratings array
      'rating': averageRating,   // Save the average rating
    });

    // Update the local car list
    final carIndex = _cars.indexWhere((car) => car.id == carId);
    if (carIndex != -1) {
      _cars[carIndex].ratings = updatedRatings; // Update the local ratings array
      _cars[carIndex].rating = averageRating;   // Update the local average rating
      notifyListeners(); // Notify listeners to update the UI
    }
  } catch (e) {
    debugPrint('Error rating car: $e');
    rethrow;
  }
}

  void filterCars(String query) {
  if (query.isEmpty) {
    _filteredCars = _cars;
    notifyListeners();
    return;
  }

  _filteredCars = _cars.where((car) {
    final carName = car.name.toLowerCase();
    final carBrand = car.brand.toString().split('.').last.toLowerCase(); // Convert enum to string
    final searchQuery = query.toLowerCase();
    
    return carName.contains(searchQuery) || carBrand.contains(searchQuery);
  }).toList();
  
  notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _filteredCars = [];
    notifyListeners();
  }
}