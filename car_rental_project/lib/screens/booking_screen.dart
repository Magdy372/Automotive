import 'package:car_rental_project/models/car_model.dart';
import 'package:car_rental_project/models/rental_model.dart';
import 'package:car_rental_project/providers/rental_provider.dart';
import 'package:car_rental_project/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  final Car car;

  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalPrice = 0.0;
  final _formKey = GlobalKey<FormState>();

  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  late List<DateTime> _bookedDates;
  @override
  void initState() {
    super.initState();
    // Ensure booked dates are properly paired
    _bookedDates = widget.car.bookedDates ?? [];

    // Remove any incomplete pairs
    if (_bookedDates.length % 2 != 0) {
      _bookedDates.removeLast();
    }

    debugPrint('Booked dates for this car: $_bookedDates');
  }

  /// Helper method to display the TableCalendar dialog
  Future<DateTime?> _showDatePickerDialog({
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? focusedDay,
  }) async {
    try {
      // Ensure focusedDay is within the valid range
      if (focusedDay == null || focusedDay.isBefore(firstDate)) {
        focusedDay = firstDate;
      } else if (focusedDay.isAfter(lastDate)) {
        focusedDay = lastDate;
      }

      return await showDialog<DateTime>(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: TableCalendar(
              firstDay: firstDate,
              lastDay: lastDate,
              focusedDay: focusedDay!,
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              calendarStyle: CalendarStyle(
                // Today's date styling
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  shape: BoxShape.circle,
                ),
                // Available dates styling
                defaultDecoration: BoxDecoration(
                   color: Colors.green.shade300, 
                  shape: BoxShape.circle,
                ),
                // Weekend dates styling
                weekendDecoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                // Disabled dates styling
                disabledDecoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              selectedDayPredicate: (day) {
                // Highlight available and booked dates differently
                if (_isBooked(day)) {
                  return false; // Booked dates won't be selectable
                }
                return true;
              },
              // Custom day builder to show booked and available dates
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (_isBooked(day)) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color:Color.fromARGB(255, 210, 48, 48),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return null; // Use default styling
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!_isBooked(selectedDay)) {
                  Navigator.pop(context, selectedDay);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("This date is already booked!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error in showing date picker dialog: $e');
      return null;
    }
  }

  bool _isBooked(DateTime day) {
    // Optimization: Early return for days outside the overall booking range
    if (_bookedDates.isEmpty ||
        day.isBefore(widget.car.availableFrom!) ||
        day.isAfter(widget.car.availableTo!)) {
      return false;
    }

    // More efficient iteration through booked dates
    for (int i = 0; i < _bookedDates.length; i += 2) {
      try {
        DateTime start = _bookedDates[i];
        DateTime end = _bookedDates[i + 1];

        // Check if the day is within the booked range
        if (day.isAtSameMomentAs(start) ||
            day.isAtSameMomentAs(end) ||
            (day.isAfter(start) && day.isBefore(end))) {
          return true;
        }
      } catch (e) {
        debugPrint('Error checking booked dates: $e');
        // Silently handle any potential index out of bounds
        break;
      }
    }

    return false;
  }

  void _selectStartDate() async {
    debugPrint(
        'Selecting start date...'); // Log the start date selection process
    DateTime? pickedDate = await _showDatePickerDialog(
      firstDate: widget.car.availableFrom!,
      lastDate: widget.car.availableTo!,
      focusedDay: _startDate,
    );

    if (pickedDate != null && pickedDate != _startDate) {
      debugPrint('Picked start date: $pickedDate'); // Log the picked start date
      setState(() {
        _startDate = pickedDate;
        _endDate = null;
        _calculateTotalPrice();
      });
    }
  }

  void _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date first.')),
      );
      return;
    }

    debugPrint(
        'Selecting end date, start date: $_startDate'); // Log when selecting end date
    DateTime? pickedDate = await _showDatePickerDialog(
      firstDate: _startDate!,
      lastDate: widget.car.availableTo!,
      focusedDay: _endDate,
    );

    if (pickedDate != null && pickedDate.isAfter(_startDate!)) {
      debugPrint('Picked end date: $pickedDate'); // Log the picked end date
      setState(() {
        _endDate = pickedDate;
        _calculateTotalPrice();
      });
    }
  }

  void _calculateTotalPrice() {
    debugPrint('Calculating total price'); // Log when calculating price
    if (_startDate != null && _endDate != null) {
      final duration = _endDate!.difference(_startDate!).inDays + 1;
      debugPrint('Rental duration: $duration days'); // Log duration
      setState(() {
        _totalPrice = widget.car.price * duration;
        debugPrint('Total price: $_totalPrice'); // Log price calculation result
      });
    }
  }

  Future<void> _submitBooking() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book a car.')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates.')),
      );
      return;
    }

    debugPrint('Car Details:');
    debugPrint('ID: ${widget.car.id}');
    debugPrint('Name: ${widget.car.name}');
    debugPrint(
        'Booking Details: Start Date = $_startDate, End Date = $_endDate, Total Price = $_totalPrice');

    try {
      final carSnapshot = await FirebaseFirestore.instance
          .collection('Cars')
          .doc(widget.car.id)
          .get();
      debugPrint('Car snapshot exists: ${carSnapshot.exists}');
      if (!carSnapshot.exists) {
        debugPrint('Car not found in Firestore, trying alternative query...');
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Cars')
            .where('id', isEqualTo: widget.car.id)
            .get();

        if (querySnapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Car not found. ID: ${widget.car.id}')),
          );
          return;
        } else {
          var doc = querySnapshot.docs.first;
          widget.car.id = doc.id;
          debugPrint('Car found via query: ${widget.car.id}');
        }
      }

      final buyerRef =
          FirebaseFirestore.instance.collection('Users').doc(user.id);
      final carRef =
          FirebaseFirestore.instance.collection('Cars').doc(widget.car.id);

      final rentalProvider =
          Provider.of<RentalProvider>(context, listen: false);

      try {
        await rentalProvider.addRental(
          RentalModel(
            car: carRef,
            buyer: buyerRef,
            startDate: _startDate!,
            endDate: _endDate!,
            totalPrice: _totalPrice,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rental booked successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        debugPrint('Booking error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${e.toString()}')),
        );
      }
    } catch (queryError) {
      debugPrint('Query Error: $queryError');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error querying car: $queryError')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Your Rental'),
        backgroundColor: Colors.black, // Changed from deepPurple to black
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car details card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book: ${widget.car.name}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Changed from deepPurple
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.car_rental,
                              color: Colors.black), // Changed from deepPurple
                          SizedBox(width: 10),
                          Text(
                            '\$${widget.car.price}/day',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Color legend
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(Colors.blue.shade200, 'Today'),
                      _buildLegendItem(const Color.fromARGB(255, 210, 48, 48), 'Booked'),
                      _buildLegendItem(const Color.fromARGB(255, 101, 24, 128), 'Available'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Date selection and pricing
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Start Date Selection
                    GestureDetector(
                      onTap: _selectStartDate,
                      child: _buildReadOnlyInputField('Start Date', _startDate,
                          icon: Icons.calendar_today),
                    ),
                    SizedBox(height: 20),
                    // End Date Selection
                    GestureDetector(
                      onTap: _selectEndDate,
                      child: _buildReadOnlyInputField('End Date', _endDate,
                          icon: Icons.calendar_today),
                    ),
                    SizedBox(height: 20),
                    // Total Price Display
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _totalPrice > 0
                                  ? '\$${_totalPrice.toStringAsFixed(2)}'
                                  : 'Select dates',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Changed from deepPurple
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Confirm and Book Button
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black,
                            Colors.grey.shade800,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: Text(
                          'Confirm and Book',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }

// Modified input field with icon support and always showing selected date
  Widget _buildReadOnlyInputField(String label, DateTime? date,
      {IconData? icon}) {
    return TextFormField(
      enabled: false,
      decoration: InputDecoration(
        // When a date is selected, show it as the label
        labelText:
            date != null ? '${label}: ${_dateFormat.format(date)}' : label,
        // If no date is selected, show hint
        hintText: date == null ? 'Select date' : null,
        prefixIcon: icon != null ? Icon(icon, color: Colors.black) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black),
        ),
        // Change label style when a date is selected
        labelStyle: TextStyle(
          color: date != null ? Colors.black : Colors.grey,
          fontSize: 16,
          fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}


