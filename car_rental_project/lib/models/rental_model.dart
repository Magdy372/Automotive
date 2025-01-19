import 'package:car_rental_project/models/car_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RentalModel {
  final String? id; 
  final DocumentReference car;
  final DocumentReference buyerRef; 
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  
  const RentalModel({
    this.id,
    required this.car,
    required this.buyerRef,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  });

  // Convert to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'carRef': car,
      'buyerRef': buyerRef,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
    };
  }

  // Create from Firestore document snapshot
  static Future<RentalModel> fromDocumentSnapshot(DocumentSnapshot doc) async {
    if (!doc.exists) {
      throw Exception('Rental document does not exist');
    }

    final data = doc.data() as Map<String, dynamic>;
    
    return RentalModel(
      id: doc.id,
        car: data['carRef'] is DocumentReference
        ? data['carRef'] as DocumentReference
        : FirebaseFirestore.instance.doc(data['carRef']),
    buyerRef: data['buyerRef'] is DocumentReference
        ? data['buyerRef'] as DocumentReference
        : FirebaseFirestore.instance.doc(data['buyerRef']),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
    );
  }

  // Helper method to fetch the associated Car document
  Future<Car?> getCar() async {
    try {
      final carDoc = await car.get();
      if (!carDoc.exists) return null;
      
      return Car.fromMap(
        carDoc.data() as Map<String, dynamic>,
        carDoc.reference,
      );
    } catch (e) {
      debugPrint('Error fetching car details: $e');
      return null;
    }
  }

  // Helper method to fetch the buyer's user document
Future<Map<String, dynamic>?> getBuyerDetails() async {
  try {
    debugPrint('Buyer Ref Path: ${buyerRef.path}'); // Log the buyerRef path
    final buyerDoc = await buyerRef.get();
    if (buyerDoc.exists) {
      debugPrint('Buyer Document Data: ${buyerDoc.data()}'); // Log buyer data
      return {
        'name': buyerDoc['name'] ?? 'Unknown',
        'phone': buyerDoc['phone'] ?? 'No Phone',
      };
    } else {
      debugPrint('Buyer document does not exist'); // Log if document doesn't exist
    }
    return null;
  } catch (e) {
    debugPrint('Error fetching buyer details: $e');
    return null;
  }
}
 
}