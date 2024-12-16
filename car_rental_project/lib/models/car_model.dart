import 'package:cloud_firestore/cloud_firestore.dart';

// Enums for Car Attributes

enum Brand { BMW, Toyota, Honda, Tesla, MG, Mercedes, Ford, Audi, Hyundai }
enum BodyType {
  Sedan,
  Hatchback,
  Coupe,
  SUV,
  Crossover,
  Convertible,
  Wagon,
  Minivan,
  PickupTruck,
  SportsCar
}
enum TransmissionType { Manual, Automatic }
enum Feature { Bluetooth, Sensors, Navigation, Camera }

class Car {
  String id;
  final String name; // Car name or model
  final Brand brand; // Brand of the car
  final double price; // Price per day
  final String image; // URL to car image
  final double rating; // Average rating
  final String description; // Description of the car
  final BodyType bodyType; // Body type (e.g., Sedan, SUV, etc.)
  final TransmissionType transmissionType; // Transmission type (Manual/Automatic)
  final List<Feature> features; // Features list (Bluetooth, Camera, etc.)
  final DocumentReference seller; // Reference to seller's Firestore document
  bool isBooked; // Whether the car is currently booked

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.image,
    required this.rating,
    required this.description,
    required this.bodyType,
    required this.transmissionType,
    required this.features,
    required this.seller,
    this.isBooked = false,
  });

  // Convert Enum to String for Firestore Storage
  static String _enumToString(dynamic enumValue) => enumValue.toString().split('.').last;

  // Convert String to Enum for Firestore Retrieval
  static T _stringToEnum<T>(String enumString, List<T> enumValues) {
    return enumValues.firstWhere((e) => e.toString().split('.').last == enumString);
  }

  // Factory constructor to create a Car from Firestore data
  factory Car.fromMap(Map<String, dynamic> data, DocumentReference reference ){
    return Car(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      brand: _stringToEnum(data['brand'] ?? '', Brand.values),
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      bodyType: _stringToEnum(data['bodyType'] ?? '', BodyType.values),
      transmissionType: _stringToEnum(data['transmissionType'] ?? '', TransmissionType.values),
      features: (data['features'] ?? [])
          .map<Feature>((feature) => _stringToEnum(feature, Feature.values))
          .toList(),
      seller: reference,
      isBooked:true,
    );
  }

  // Converts the Car object to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': _enumToString(brand),
      'price': price,
      'image': image,
      'rating': rating,
      'description': description,
      'bodyType': _enumToString(bodyType),
      'transmissionType': _enumToString(transmissionType),
      'features': features.map((feature) => _enumToString(feature)).toList(),
      'seller': seller,
    };
  }

  // Checks if the car is booked based on the current date and rental collection
  static Future<bool> checkBookingStatus(String carId) async {
    final rentals = await FirebaseFirestore.instance
        .collection('Rentals')
        .where('carId', isEqualTo: carId)
        .get();

    final currentDate = DateTime.now();
    for (var doc in rentals.docs) {
      final rentalData = doc.data();
      final startDate = (rentalData['startDate'] as Timestamp).toDate();
      final endDate = (rentalData['endDate'] as Timestamp).toDate();

      if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
        return true; // Car is booked during this time
      }
    }
    return false; // Car is not booked
  }
}