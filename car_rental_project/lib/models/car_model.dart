import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  String id;
  final String name;
  final String brand;
  final double price;
  final String image;
  final double rating;
  DocumentReference seller; // Reference to the User document (seller)

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.image,
    required this.rating,
    required this.seller, // Reference to seller (User)
  });

  // Factory constructor to create a Car from Firestore data
  factory Car.fromMap(Map<String, dynamic> data, DocumentReference reference) {
    return Car(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      seller: reference, // Reference to the User document
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'image': image,
      'rating': rating,
      // Store just the reference to the user in Firestore
      'seller': seller,
    };
  }
}
