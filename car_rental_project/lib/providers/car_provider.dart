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
      QuerySnapshot snapshot = await _firestore.collection('cars').get();
      _cars = snapshot.docs
          .map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching cars: $e");
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
