import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RentalModel {
  String? id; // Firestore document ID
  final DocumentReference car;
  final DocumentReference buyer;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;

  // Optional additional details
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

  // Convert to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'car': car.path,
      'buyer': buyer.path,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
    };
  }

  // Create from Firestore document snapshot
  static Future<RentalModel> fromDocumentSnapshot(DocumentSnapshot doc) async {
    // Ensure the document exists and has data
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }

    var data = doc.data() as Map<String, dynamic>;
    
    // Create base rental model
    var rental = RentalModel(
      id: doc.id,
      car: FirebaseFirestore.instance.doc(data['car']),
      buyer: FirebaseFirestore.instance.doc(data['buyer']),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
    );

    // Fetch additional details
    try {
      // Fetch car details
      var carSnapshot = await rental.car.get();
      if (carSnapshot.exists) {
        rental.carName = carSnapshot['name'];
        rental.carBodyType = carSnapshot['bodyType'];
        rental.carBrand = carSnapshot['brand'];

        // Fetch seller details if available
        var sellerRef = carSnapshot['seller'] as DocumentReference?;
        if (sellerRef != null) {
          var sellerSnapshot = await sellerRef.get();
          rental.sellerName = sellerSnapshot.exists 
            ? (sellerSnapshot['name'] ?? 'Unknown Seller')
            : 'Seller Not Found';
        }
      }
    } catch (e) {
      // Log any errors while fetching additional details
      debugPrint('Error fetching additional rental details: $e');
    }

    return rental;
  }
}
