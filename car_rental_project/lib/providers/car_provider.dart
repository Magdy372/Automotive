import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';
import '../models/rental_model.dart';

class CarProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Car> _cars = [];
  List<Car> _filteredCars = [];

  List<Car> get cars => _cars;
  List<Car> get filtercars => _filteredCars;


  /// Fetch cars from Firestore and update their booking status
Future<void> fetchCars() async {
  try {
    QuerySnapshot snapshot = await _firestore.collection('Cars').get();
    
    if (snapshot.docs.isEmpty) {
      throw Exception('No cars found in Firestore');
    }

    _cars = await Future.wait(snapshot.docs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;

      // Debugging the doc data
      debugPrint('Fetched car data: $data');

      return Car.fromMap(data, doc.reference);
    }).toList());

    _filteredCars = []; // Clear filters after fetching
    notifyListeners();
  } catch (e) {
    debugPrint('Error fetching cars: $e');
    rethrow;  // Re-throw the exception to allow more investigation
  }
}


  /// Add a new car to Firestore and the local list
  Future<void> addCar(Car car) async {
    try {
      DocumentReference docRef = await _firestore.collection('Cars').add(car.toMap());
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

  /// Remove a car from Firestore and the local list
  Future<void> deleteCar(String carId) async {
    try {
      await _firestore.collection('Cars').doc(carId).delete();
      _cars.removeWhere((car) => car.id == carId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting car: $e');
    }
  }

  void filterCars(String query) {
    if (query.isEmpty) {
      _filteredCars = _cars; // Reset to show all cars
      notifyListeners();
    } else {
    _filteredCars = _cars.where((car) {
      final carName = car.name.toLowerCase();
      //final carBrand = car.brand.toLowerCase();
      final searchQuery = query.toLowerCase();
      //return carName.contains(searchQuery) || carBrand.contains(searchQuery);
      return carName.contains(searchQuery);
    }).toList();
    print("22333344444444444444444444477777777777777777777777777777777777777777777777777777777777777777");
    print(_filteredCars);
    notifyListeners();
    }
}


  // Clear filters
  void clearFilters() {
    _filteredCars = [];
    notifyListeners();
  }
}
