import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';
import '../models/user_model.dart';

class CarProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Car> _cars = [];
  List<Car> _filteredCars = [];

  List<Car> get cars => _cars;
  List<Car> get filtercars => _filteredCars;


  // Fetch cars from Firestore (with user reference)
  Future<void> fetchCars() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Cars').get();
      _cars = snapshot.docs.map((doc) {
        return Car.fromMap(doc.data() as Map<String, dynamic>, doc.reference);
      }).toList();
      _filteredCars = _cars;
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
  // void filterCars(String query) {
  //   _filteredCars = _cars.where((car) {
  //     return car.name.toLowerCase().contains(query.toLowerCase()) ||
  //         car.brand.toLowerCase().contains(query.toLowerCase());
  //   }).toList();
  //   notifyListeners();
  // }

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
