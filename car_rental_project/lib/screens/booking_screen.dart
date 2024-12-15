import 'package:car_rental_project/models/car_model.dart';
import 'package:car_rental_project/models/rental_model.dart';
import 'package:car_rental_project/providers/rental_provider.dart';
import 'package:car_rental_project/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/car_provider.dart';

class BookingScreen extends StatefulWidget {
  final Car car; // Pass the selected car to this screen

  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalPrice = 0.0;
  final _formKey = GlobalKey<FormState>();

  // Date format (e.g. "May 01, 2024")
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
  }

  // Handle date selection and calculate the total price
  void _selectStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
        if (_endDate != null && _startDate != null) {
          _calculateTotalPrice();
        }
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date first.')),
      );
      return;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
        if (_startDate != null) {
          _calculateTotalPrice();
        }
      });
    }
  }

  // Calculate the total price based on car price per day, start date, and end date
  void _calculateTotalPrice() {
    if (_startDate != null && _endDate != null) {
      final duration = _endDate!.difference(_startDate!);
      if (duration.isNegative) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date cannot be before start date')),
        );
        _totalPrice = 0.0; // Reset total price
        return;
      }
      setState(() {
        _totalPrice = widget.car.price * duration.inDays;
      });
    }
  }

  // Submit booking form and create rental in Firestore
  void _submitBooking() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser; // Fetch current user
    final buyerRef = FirebaseFirestore.instance.collection('Users').doc(user?.id);
    var uuid = Uuid();
    final uniquRentId = uuid.v4();
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      final rentalProvider = Provider.of<RentalProvider>(context, listen: false);
      try {
        // Add new rental to Firestore
        await rentalProvider.addRental(
          RentalModel(
            id: uniquRentId, // Auto-generated in Firestore
            car: widget.car.seller, // Seller reference to User
            buyer: buyerRef, // Current logged-in user as buyer
            startDate: _startDate!,
            endDate: _endDate!,
            totalPrice: _totalPrice,
          ),
        );
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rental booked successfully!')),
        );
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to book rental!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form correctly.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Rental'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book: ${widget.car.name}',
              style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Start Date Picker
                  GestureDetector(
                    onTap: () => _selectStartDate(context),
                    child: TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        // Show selected start date
                        hintText: _startDate != null
                            ? _dateFormat.format(_startDate!)
                            : 'Select start date',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // End Date Picker
                  GestureDetector(
                    onTap: () => _selectEndDate(context),
                    child: TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        // Show selected end date
                        hintText: _endDate != null
                            ? _dateFormat.format(_endDate!)
                            : 'Select end date',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Total Price Display
                  TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Total Price',
                      // Show total price if calculated
                      hintText: _totalPrice > 0
                          ? '\$${_totalPrice.toStringAsFixed(2)}'
                          : 'Total price will appear here',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Submit Button to Confirm Booking
                  ElevatedButton(
                    onPressed: _submitBooking,
                    child: const Text('Confirm and Book'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
