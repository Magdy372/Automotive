import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';

class CarProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Car> _cars = [];
  List<Car> _filteredCars = [];

  List<Car> get cars => _filteredCars.isEmpty ? _cars : _filteredCars;

  // Fetch cars from Firestore
  Future<void> fetchCars() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Cars').get();
      _cars = snapshot.docs
          .map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching cars: $e");
    }
  }

  // Add a new car
  Future<void> addCar(Car car) async {
  try {
    DocumentReference docRef =
        await _firestore.collection('Cars').add(car.toMap());
    car.id = docRef.id; // Assign the Firestore document ID to the car
    _cars.add(car);
    notifyListeners(); // Notify listeners about the change
  } catch (e) {
    debugPrint("Error adding car: $e");
  }
}


  // Update an existing car
  Future<void> updateCar(String carId, Car updatedCar) async {
    try {
      await _firestore.collection('Cars').doc(carId).update(updatedCar.toMap());
      int index = _cars.indexWhere((car) => car.id == carId);
      if (index != -1) {
        _cars[index] = updatedCar;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating car: $e");
    }
  }

  // Delete a car
  Future<void> deleteCar(String carId) async {
    try {
      await _firestore.collection('Cars').doc(carId).delete();
      _cars.removeWhere((car) => car.id == carId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting car: $e");
    }
  }

  // Filter cars by search query
  void filterCars(String query) {
    _filteredCars = _cars.where((car) {
      return car.name.toLowerCase().contains(query.toLowerCase()) ||
          car.brand.toLowerCase().contains(query.toLowerCase());
    }).toList();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _filteredCars = [];
    notifyListeners();
  }
}
