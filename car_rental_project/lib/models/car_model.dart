// car_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';



class Car {
  String id;
  final String name;
  final Brand brand;
  final double price;
  final String image;
  final double rating;
  final double horsepower;
  final double acceleration;
  final double tankCapacity;
  final int topSpeed;
  final String description;
  final BodyType bodyType;
  final TransmissionType transmissionType;
  final List<Feature> features;
  final DocumentReference seller;
  bool isBooked;
  DateTime? availableFrom;
  DateTime? availableTo;
  List<DateTime> bookedDates;

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
    required this.horsepower,
    required this.acceleration,
    required this.tankCapacity,
    required this.topSpeed,
    required this.features,
    required this.seller,
    this.isBooked = false,
    this.availableFrom,
    this.availableTo,
    this.bookedDates = const [],
  });

  bool isDateBooked(DateTime date) {
    return bookedDates.any((bookedDate) => bookedDate.isAtSameMomentAs(date));
  }

  static String _enumToString(dynamic enumValue) =>
      enumValue.toString().split('.').last;

  static T _stringToEnum<T>(String enumString, List<T> enumValues) {
    return enumValues.firstWhere((e) => e.toString().split('.').last == enumString);
  }

  factory Car.fromMap(Map<String, dynamic> data, DocumentReference reference) {
    return Car(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      brand: _stringToEnum(data['brand'] ?? '', Brand.values),
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      bodyType: _stringToEnum(data['bodyType'] ?? '', BodyType.values),
      transmissionType:
          _stringToEnum(data['transmissionType'] ?? '', TransmissionType.values),
      horsepower: (data['horsepower'] ?? 0).toDouble(),
      acceleration: (data['acceleration'] ?? 0).toDouble(),
      tankCapacity: (data['tankCapacity'] ?? 0).toDouble(),
      topSpeed: (data['topSpeed'] ?? 0),
      features: (data['features'] ?? [])
          .map<Feature>((feature) => _stringToEnum(feature, Feature.values))
          .toList(),
      seller: reference,
      isBooked: data['isBooked'] ?? false,
      availableFrom: (data['availableFrom'] != null)
          ? (data['availableFrom'] as Timestamp).toDate()
          : null,
      availableTo: (data['availableTo'] != null)
          ? (data['availableTo'] as Timestamp).toDate()
          : null,
      bookedDates: (data['bookedDates'] as List?)
              ?.map<DateTime>((timestamp) => (timestamp as Timestamp).toDate())
              .toList() ??
          [],
    );
  }

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
      'horsepower': horsepower,
      'acceleration': acceleration,
      'tankCapacity': tankCapacity,
      'topSpeed': topSpeed,
      'features': features.map((feature) => _enumToString(feature)).toList(),
      'seller': seller,
      'isBooked': isBooked,
      'availableFrom':
          availableFrom != null ? Timestamp.fromDate(availableFrom!) : null,
      'availableTo': availableTo != null ? Timestamp.fromDate(availableTo!) : null,
      'bookedDates': bookedDates.map((date) => Timestamp.fromDate(date)).toList(),
    };
  }
}





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
enum Feature { Bluetooth, Sensors, Navigation, Camera, Autopilot, Sunroof }