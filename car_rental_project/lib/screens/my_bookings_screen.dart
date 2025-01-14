import 'package:car_rental_project/components/booking_card_component.dart';
import 'package:flutter/material.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Bookings', 
        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
      
        children: [
          const SizedBox(height: 10),
          // Tab Section: Upcoming and Previous
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Upcoming',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 5),
                      Divider(thickness: 2, color: Color.fromARGB(255, 0, 0, 0)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Previous',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16)),
                      SizedBox(height: 5),
                      Divider(thickness: 2, color: Colors.transparent),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Ticket Card
          const Expanded(
            child: SingleChildScrollView(
              child: BookingCard(),
            ),
          ),
        ],
      ),
    );
  }
}