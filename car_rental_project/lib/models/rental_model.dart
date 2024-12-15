import 'package:cloud_firestore/cloud_firestore.dart'; // For DocumentReference
import 'package:car_rental_project/models/car_model.dart';

class RentalModel {
  String id;
  DocumentReference car; // Reference to the Car document
  DocumentReference buyer; // Reference to the User document (buyer)
  DateTime startDate;
  DateTime endDate;
  double totalPrice;

  RentalModel({
    required this.id,
    required this.car,    // Reference to the Car document
    required this.buyer,  // Reference to the User document (buyer)
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  });

  // Factory method to create a RentalModel from Firestore data
  factory RentalModel.fromMap(Map<String, dynamic> data, DocumentReference reference) {
    return RentalModel(
      id: data['id'] ?? '',
      car: reference,  // DocumentReference to car from Firestore
      buyer: FirebaseFirestore.instance.doc(data['buyer']), // Reference to buyer
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
    );
  }

  // Convert RentalModel to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'car': car.path,  // Store just the path of the car's document reference
      'buyer': buyer.path, // Store just the path of the buyer's document reference
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
    };
  }
}
