class Car {
  final String name;
  final String brand;
  final double price;
  final String image;
  final double rating;

  Car({
    required this.name,
    required this.brand,
    required this.price,
    required this.image,
    required this.rating,
  });

  // Convert Firestore data to Car object
  factory Car.fromMap(Map<String, dynamic> data) {
    return Car(
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
    );
  }

  // Convert Car object to Firestore format (optional)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'price': price,
      'image': image,
      'rating': rating,
    };
  }
}
