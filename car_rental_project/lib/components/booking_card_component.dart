import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Flight Details
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(15)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mercedes AMG GT',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Mercedes',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Date, Time, Number Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('1 MAY', style: TextStyle(fontSize: 16)),
                    Text('23 MAY', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          // Passenger & Booking Info
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: const [
                BookingDetails(
                    title1: 'Landlord',
                    subtitle1: 'Rana Mohamed',
                    title2: 'Car numbers',
                    subtitle2: 'RJ14578'),
                SizedBox(height: 10),
                BookingDetails(
                    title1: 'Rental Code',
                    subtitle1: 'B2SG28',
                    title2: '',
                    subtitle2: ''),
                SizedBox(height: 10),
                BookingDetails(
                    title1: 'VISA *** 2462',
                    subtitle1: 'Payment method',
                    title2: '\$249.99',
                    subtitle2: 'Price'),
              ],
            ),
          ),
          // Barcode
          Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/images/barcode.png',
             
            ),
          ),
        ],
      ),
    );
  }
}

class BookingDetails extends StatelessWidget {
  final String title1, subtitle1, title2, subtitle2;

  const BookingDetails({
    super.key,
    required this.title1,
    required this.subtitle1,
    required this.title2,
    required this.subtitle2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title1,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle1, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title2,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle2, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
