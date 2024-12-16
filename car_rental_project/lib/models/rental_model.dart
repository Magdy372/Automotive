

import 'package:cloud_firestore/cloud_firestore.dart';

class RentalModel {
  String? id; // Firestore document ID
  final DocumentReference car; // Must be DocumentReference
  final DocumentReference buyer; // Must be DocumentReference
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;

  // Optional fields
  String? carName;
  String? carBodyType;
  String? carBrand;
  String? sellerName;

  RentalModel({
    this.id,
    required this.car,
    required this.buyer,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.carName,
    this.carBodyType,
    this.carBrand,
    this.sellerName,
  });

  // Convert RentalModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'car': car, // Stored as DocumentReference
      'buyer': buyer, // Stored as DocumentReference
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
    };
  }

  
  // Convert DocumentSnapshot to RentalModel
  static Future<RentalModel> fromDocumentSnapshot(DocumentSnapshot doc) async {
  var data = doc.data() as Map<String, dynamic>;

  // Create a base RentalModel from the document data
  var rental = RentalModel.fromMap(data);

  // Fetch related car details
  var carSnapshot = await rental.car.get();
  if (carSnapshot.exists) {
    rental.carName = carSnapshot['name'];  // Add car name
    rental.carBodyType = carSnapshot['bodyType'];  // Add car body type
    rental.carBrand = carSnapshot['brand'];  // Add car brand
    
    // Safely retrieve seller details
    var sellerRef = carSnapshot['seller'] as DocumentReference?;

    // Check if sellerRef is valid (non-null) and get the seller data
    if (sellerRef != null) {
      var sellerSnapshot = await sellerRef.get();
      
      // Ensure that the seller data exists
      if (sellerSnapshot.exists) {
        rental.sellerName = sellerSnapshot['name'] ?? 'Unknown Seller';  // Assign seller's name (or default)
      } else {
        rental.sellerName = 'Seller not found'; // Default if the seller doesn't exist
      }
    } else {
      rental.sellerName = 'Seller not referenced'; // If no seller reference is available
    }
  }

  return rental;
}

  // Factory method to create RentalModel from a Firestore map
  factory RentalModel.fromMap(Map<String, dynamic> data) {
    return RentalModel(
      car: data['car'] as DocumentReference, // Load as DocumentReference
      buyer: data['buyer'] as DocumentReference, // Load as DocumentReference
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
    );
  }
}
