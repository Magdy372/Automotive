import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';
import '../models/user_model.dart';

class CarProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Car> _cars = [];
  List<Car> _filteredCars = [];

  List<Car> get cars => _filteredCars.isEmpty ? _cars : _filteredCars;

  // Fetch cars from Firestore (with user reference)
  Future<void> fetchCars() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Cars').get();
      _cars = snapshot.docs.map((doc) {
        return Car.fromMap(doc.data() as Map<String, dynamic>, doc.reference);
      }).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching cars: $e");
    }
  }

  // Add a new car with a seller reference
  Future<void> addCar(Car car) async {
    try {
      DocumentReference docRef = await _firestore.collection('Cars').add(car.toMap());
      car.id = docRef.id; // Assign Firestore document ID to the car
      _cars.add(car); // Add to local list
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding car: $e");
    }
  }

  // Get the seller data for a car
  Future<UserModel> getSellerData(DocumentReference sellerReference) async {
    try {
      DocumentSnapshot sellerSnapshot = await sellerReference.get();
      if (sellerSnapshot.exists) {
        return UserModel.fromJson(sellerSnapshot.data() as Map<String, dynamic>);
      }
      throw Exception('Seller not found');
    } catch (e) {
      throw Exception('Error fetching seller data: $e');
    }
  }

  // Update car details
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
