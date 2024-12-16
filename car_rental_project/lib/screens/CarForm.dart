import 'package:car_rental_project/providers/car_provider.dart';
import 'package:car_rental_project/providers/user_provider.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/car_model.dart';

class CarUploadScreen extends StatefulWidget {
  const CarUploadScreen({super.key});

  @override
  _CarUploadScreenState createState() => _CarUploadScreenState();
}

class _CarUploadScreenState extends State<CarUploadScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  BodyType? _selectedBodyType;
  TransmissionType? _selectedTransmissionType;
  Brand? _selectedBrand;
  List<Feature> _selectedFeatures = [];

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

  // Upload car to database
  void _uploadCarForRent(BuildContext context) {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        _selectedBodyType == null ||
        _selectedTransmissionType == null ||
        _selectedFeatures.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to upload a car for rent'), backgroundColor: Colors.red),
      );
      return;
    }

    // Preparing Car Data
    var uuid = Uuid();
    final uniqueCarId = uuid.v4();
    final sellerRef = FirebaseFirestore.instance.collection('Users').doc(user.id);

    final newCar = Car(
      id: uniqueCarId,
      name: nameController.text,
      brand: _selectedBrand ?? Brand.Toyota,
      price: double.tryParse(priceController.text) ?? 0.0,
      image: 'assets/images/mercedes_AMG_GT.png',
      rating: 0.0,
      description: descriptionController.text,
      bodyType: _selectedBodyType ?? BodyType.Sedan,
      transmissionType: _selectedTransmissionType ?? TransmissionType.Automatic,
      features: _selectedFeatures,
      seller: sellerRef,
    );

    final carProvider = Provider.of<CarProvider>(context, listen: false);
    carProvider.addCar(newCar).then((_) {
      // Clear input fields on success
      nameController.clear();
      priceController.clear();
      descriptionController.clear();
      setState(() {
        _selectedBodyType = null;
        _selectedTransmissionType = null;
        _selectedFeatures.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car uploaded successfully')),
      );
      Navigator.pop(context);
       Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading car: $error'), backgroundColor: Colors.red),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Car")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Upload a Car for Rent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              Expanded(
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Car name field
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Car Name"),
                      ),

                      // Price per day field
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: "Price per Day"),
                        keyboardType: TextInputType.number,
                      ),

                      // Car description field
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: "Description"),
                      ),

                      // Body Type Dropdown
                      Container(
                        width: double.infinity,
                        child: DropdownButton<BodyType>(
                          value: _selectedBodyType,
                          hint: Text(_selectedBodyType != null
                              ? _selectedBodyType.toString().split('.').last
                              : 'Select Body Type'),
                          onChanged: (BodyType? value) {
                            setState(() {
                              _selectedBodyType = value;
                            });
                          },
                          items: BodyType.values.map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value.toString().split('.').last),
                            );
                          }).toList(),
                        ),
                      ),

                      // Transmission Type Dropdown
                      Container(
                        width: double.infinity,
                        child: DropdownButton<TransmissionType>(
                          value: _selectedTransmissionType,
                          hint: Text(_selectedTransmissionType != null
                              ? _selectedTransmissionType.toString().split('.').last
                              : 'Select Transmission Type'),
                          onChanged: (TransmissionType? value) {
                            setState(() {
                              _selectedTransmissionType = value;
                            });
                          },
                          items: TransmissionType.values.map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value.toString().split('.').last),
                            );
                          }).toList(),
                        ),
                      ),

                      // Brand Dropdown
                      Container(
                        width: double.infinity,
                        child: DropdownButton<Brand>(
                          value: _selectedBrand,
                          hint: Text(_selectedBrand != null
                              ? _selectedBrand.toString().split('.').last
                              : 'Select Brand'),
                          onChanged: (Brand? value) {
                            setState(() {
                              _selectedBrand = value;
                            });
                          },
                          items: Brand.values.map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value.toString().split('.').last),
                            );
                          }).toList(),
                        ),
                      ),

                      // Multi-select Features with Checkboxes
                      const Text('Select Features:'),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: Feature.values.map((feature) {
                          return ChoiceChip(
                            label: Text(feature.toString().split('.').last),
                            selected: _selectedFeatures.contains(feature),
                            onSelected: (selected) {
                              _toggleFeature(feature);
                            },
                          );
                        }).toList(),
                      ),

                      // Upload Button
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            _uploadCarForRent(context);
                          },
                          child: const Text("Upload Car", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
