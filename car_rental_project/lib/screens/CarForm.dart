import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
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

  DateTime? _availableFrom;
  DateTime? _availableTo;

  BodyType? _selectedBodyType;
  TransmissionType? _selectedTransmissionType;
  Brand? _selectedBrand;
  final List<Feature> _selectedFeatures = [];

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

  // Upload car to database
  void _uploadCarForRent(BuildContext context) {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        _selectedBodyType == null ||
        _selectedTransmissionType == null ||
        _selectedFeatures.isEmpty ||
        descriptionController.text.isEmpty ||
        _availableFrom == null ||
        _availableTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields'),
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
      availableFrom: _availableFrom,
      availableTo: _availableTo,
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
        _availableFrom = null;
        _availableTo = null;
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
        SnackBar(
            content: Text('Error uploading car: $error'),
            backgroundColor: Colors.red),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Car",style: TextStyle(color: Colors.white),)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Upload a Car for Rent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Car name field
                      TextField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: "Car Name"),
                      ),

                      // Price per day field
                      TextField(
                        controller: priceController,
                        decoration:
                            const InputDecoration(labelText: "Price per Day"),
                        keyboardType: TextInputType.number,
                      ),

                      // Car description field
                      TextField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: "Description"),
                      ),

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
                            child: Text(value.toString().split('.').last),
                          );
                        }).toList(),
                      ),

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
                            child: Text(value.toString().split('.').last),
                          );
                        }).toList(),
                      ),

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
                            child: Text(value.toString().split('.').last),
                          );
                        }).toList(),
                      ),

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

                      // Available from Date Picker
                      ListTile(
                        title: const Text('Available From:'),
                        subtitle: Text(_availableFrom != null
                            ? _availableFrom!.toLocal().toString().split(' ')[0]
                            : 'Not selected'),
                        onTap: () => _selectDate(context, true),
                      ),

                      // Available to Date Picker
                      ListTile(
                        title: const Text('Available To:'),
                        subtitle: Text(_availableTo != null
                            ? _availableTo!.toLocal().toString().split(' ')[0]
                            : 'Not selected'),
                        onTap: () => _selectDate(context, false),
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
