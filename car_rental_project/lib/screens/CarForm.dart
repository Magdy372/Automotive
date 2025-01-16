import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:io'; // For File import
import 'package:image_picker/image_picker.dart'; // For ImagePicker
import 'package:supabase_flutter/supabase_flutter.dart'; // For Supabase upload
import '../models/car_model.dart';
import '../providers/car_provider.dart';
import '../providers/user_provider.dart';
import '../screens/home_screen.dart';


class CarUploadScreen extends StatefulWidget {
  const CarUploadScreen({super.key});

  @override
  _CarUploadScreenState createState() => _CarUploadScreenState();
}

class _CarUploadScreenState extends State<CarUploadScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController horsepowerController = TextEditingController();
  final TextEditingController accelerationController = TextEditingController();
  final TextEditingController tankCapacityController = TextEditingController();
  final TextEditingController topspeedController = TextEditingController();
    final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  DateTime? _availableFrom;
  DateTime? _availableTo;

  BodyType? _selectedBodyType;
  TransmissionType? _selectedTransmissionType;
  Brand? _selectedBrand;
  final List<Feature> _selectedFeatures = [];
  File? _imageFile; // To store the picked image
  final ImagePicker _picker = ImagePicker(); // Image Picker instance

  // DatePicker functions to select availableFrom and availableTo
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _availableFrom = picked;
        } else {
          _availableTo = picked;
        }
      });
    }
  }

  // Function to toggle selected features
  void _toggleFeature(Feature feature) {
    setState(() {
      if (_selectedFeatures.contains(feature)) {
        _selectedFeatures.remove(feature);
      } else {
        _selectedFeatures.add(feature);
      }
    });
  }



Future<void> _detectLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error detecting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  // Pick an image from the gallery
  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Store the picked image
      });
    }
  }

  // Upload image to Supabase
  // Upload image to Supabase
  Future<String> uploadImage(File image) async {
    try {
      final supabaseClient = Supabase.instance.client;
      final fileName = 'car_image/${DateTime.now().millisecondsSinceEpoch}.jpg'; // Unique file name

      // Upload the image to Supabase
      final response = await supabaseClient.storage.from('cars').upload(fileName, image);


      // If successful, get the public URL for the image
      final imageUrl = supabaseClient.storage.from('cars').getPublicUrl(fileName);
      return imageUrl; // Return the image URL
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
  Future<String> uploadCarImage(File imageFile) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to upload');
    }

    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // Ensure the file is not too large
    if (imageFile.lengthSync() > 5 * 1024 * 1024) { // 5MB limit
      throw Exception('File size exceeds 5MB');
    }

    final response = await Supabase.instance.client.storage
        .from('car_images')
        .upload(
          fileName, 
          imageFile,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    final imageUrl = Supabase.instance.client.storage
        .from('car_images')
        .getPublicUrl(fileName);

    return imageUrl;
  } on StorageException catch (e) {
    print('Supabase Storage Error: ${e.message}');
    throw Exception('Failed to upload image: ${e.message}');
  } catch (e) {
    print('Unexpected upload error: $e');
    rethrow;
  }
}


  // Upload car to database (including image URL)
  void _uploadCarForRent(BuildContext context) async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        horsepowerController.text.isEmpty ||
        accelerationController.text.isEmpty ||
        tankCapacityController.text.isEmpty ||
        topspeedController.text.isEmpty ||
        _selectedBodyType == null ||
        _selectedTransmissionType == null ||
        _selectedFeatures.isEmpty ||
        descriptionController.text.isEmpty ||
        _availableFrom == null ||
         latitudeController.text.isEmpty ||
        longitudeController.text.isEmpty ||
        _availableTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload an image for the car'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You need to be logged in to upload a car for rent'),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Preparing Car Data
    var uuid = const Uuid();
    final uniqueCarId = uuid.v4();
    final sellerRef =
        FirebaseFirestore.instance.collection('Users').doc(user.id);

    try {
      // Upload the image and get the image URL
      final imageUrl = await uploadImage(_imageFile!);

      final newCar = Car(
        id: uniqueCarId,
        name: nameController.text,
        brand: _selectedBrand ?? Brand.Toyota,
        price: double.tryParse(priceController.text) ?? 0.0,
        image: imageUrl, // Use the uploaded image URL
        rating: 0.0,
        description: descriptionController.text,
        bodyType: _selectedBodyType ?? BodyType.Sedan,
        transmissionType:
            _selectedTransmissionType ?? TransmissionType.Automatic,
        features: _selectedFeatures,
        seller: sellerRef,
        availableFrom: _availableFrom,
        availableTo: _availableTo,
        horsepower: double.tryParse(horsepowerController.text) ?? 0.0,
        acceleration: double.tryParse(accelerationController.text) ?? 0.0,
        tankCapacity: double.tryParse(tankCapacityController.text) ?? 0.0,
        topSpeed: int.tryParse(topspeedController.text) ?? 0,
        latitude: double.tryParse(latitudeController.text) ?? 0.0,
        longitude: double.tryParse(longitudeController.text) ?? 0.0,
      );

      final carProvider = Provider.of<CarProvider>(context, listen: false);
      await carProvider.addCar(newCar);

      // Clear input fields on success
      nameController.clear();
      priceController.clear();
      descriptionController.clear();
      horsepowerController.clear();
      accelerationController.clear();
      tankCapacityController.clear();
      topspeedController.clear();
      setState(() {
        _selectedBodyType = null;
        _selectedTransmissionType = null;
        _selectedFeatures.clear();
        _availableFrom = null;
        _availableTo = null;
        _imageFile = null; // Clear image after upload
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car uploaded successfully')),
      );
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error uploading car: $error'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              const Text("Upload Car", style: TextStyle(color: Colors.white))),
      body: SafeArea(
        child: SingleChildScrollView(
          // Add this widget to make the page scrollable
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text('Upload a Car for Rent',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                // Form fields
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image container with modern styling
                    GestureDetector(
                      onTap: pickImage, // Trigger the image picker
                      child: _imageFile == null
                          ? Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Tap to select image",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageFile!,
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    // Car name field
                    TextField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: "Car Name")),
                    const SizedBox(height: 20),
                    // Price per day field
                    TextField(
                        controller: priceController,
                        decoration:
                            const InputDecoration(labelText: "Price per Day"),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    // Horsepower field
                    TextField(
                        controller: horsepowerController,
                        decoration:
                            const InputDecoration(labelText: "Horsepower (HP)"),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    // Acceleration field
                    TextField(
                        controller: accelerationController,
                        decoration: const InputDecoration(
                            labelText: "Acceleration (0-100 km/h in seconds)"),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    // Tank Capacity field
                    TextField(
                        controller: tankCapacityController,
                        decoration: const InputDecoration(
                            labelText: "Tank Capacity (liters)"),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    // TopSpeed field
                    TextField(
                        controller: topspeedController,
                        decoration: const InputDecoration(
                            labelText: "Top Speed (km/h)"),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    // Car description field
                    TextField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: "Description")),
                    const SizedBox(height: 20),
                    // Body Type Dropdown
                    DropdownButton<BodyType>(
                        value: _selectedBodyType,
                        hint: const Text('Select Body Type'),
                        onChanged: (BodyType? value) {
                          setState(() {
                            _selectedBodyType = value;
                          });
                        },
                        items: BodyType.values.map((BodyType value) {
                          return DropdownMenuItem<BodyType>(
                              value: value,
                              child: Text(value.toString().split('.').last));
                        }).toList()),
                    const SizedBox(height: 20),
                    // Transmission Type Dropdown
                    DropdownButton<TransmissionType>(
                        value: _selectedTransmissionType,
                        hint: const Text('Select Transmission Type'),
                        onChanged: (TransmissionType? value) {
                          setState(() {
                            _selectedTransmissionType = value;
                          });
                        },
                        items: TransmissionType.values
                            .map((TransmissionType value) {
                          return DropdownMenuItem<TransmissionType>(
                              value: value,
                              child: Text(value.toString().split('.').last));
                        }).toList()),
                    const SizedBox(height: 20),
                    // Brand Dropdown
                    DropdownButton<Brand>(
                        value: _selectedBrand,
                        hint: const Text('Select Brand'),
                        onChanged: (Brand? value) {
                          setState(() {
                            _selectedBrand = value;
                          });
                        },
                        items: Brand.values.map((Brand value) {
                          return DropdownMenuItem<Brand>(
                              value: value,
                              child: Text(value.toString().split('.').last));
                        }).toList()),
                    const SizedBox(height: 20),
                    // Select Features
                    const Text('Select Features:'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: Feature.values.map((Feature feature) {
                        return ChoiceChip(
                          label: Text(feature.toString().split('.').last),
                          selected: _selectedFeatures.contains(feature),
                          onSelected: (selected) {
                            _toggleFeature(feature);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Available from Date Picker
                    ListTile(
                        title: const Text('Available From:'),
                        subtitle: Text(_availableFrom != null
                            ? _availableFrom!.toLocal().toString().split(' ')[0]
                            : 'Not selected'),
                        onTap: () => _selectDate(context, true)),
                    const SizedBox(height: 20),
                    // Available to Date Picker
                    ListTile(
                        title: const Text('Available To:'),
                        subtitle: Text(_availableTo != null
                            ? _availableTo!.toLocal().toString().split(' ')[0]
                            : 'Not selected'),
                        onTap: () => _selectDate(context, false)),
                    const SizedBox(height: 20),

// Latitude field
                ListTile(
      title: const Text('Select Location'),
      subtitle: Text(latitudeController.text.isNotEmpty
          ? 'Latitude: ${latitudeController.text}, Longitude: ${longitudeController.text}'
          : 'Location not selected'),
      trailing: IconButton(
        icon: const Icon(Icons.location_on),
        onPressed: _detectLocation, // Trigger location detection
      ),
    ),



                    // Upload Button
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          _uploadCarForRent(context);
                        },
                        child: const Text("Upload Car",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: Column(
                    //     children: [
                    //       const SizedBox(height: 20),
                    //       // Enhanced Upload Button
                    //       ElevatedButton(
                    //         style: ElevatedButton.styleFrom(
                    //           padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //           backgroundColor: Colors.blueAccent,
                    //           foregroundColor: Colors.white,
                    //           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    //         ),
                    //         onPressed: pickImage,
                    //         child: const Text("Select Image"),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}