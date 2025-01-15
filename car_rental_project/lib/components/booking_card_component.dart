import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isDarkMode?Colors.grey[900]: const Color.fromARGB(255, 249, 248, 247),
      ),
      child: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              color: isDarkMode?Colors.grey[900]: const Color.fromARGB(255, 249, 248, 247),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mercedes AMG GT',
                            style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode?Colors.grey[300]: Colors.black)),
                         Text('Mercedes',
                            style: GoogleFonts.poppins(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Date, Time, Number Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1 MAY', style: GoogleFonts.poppins(fontSize: 16, color: isDarkMode?Colors.grey[300]: Colors.black)),
                    Text('23 MAY', style: GoogleFonts.poppins(fontSize: 16, color: isDarkMode?Colors.grey[300]: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
          Divider(thickness: 1, color: isDarkMode?Colors.grey[500]:Color(0XFF97B3AE),),
    
          Container(
            padding: const EdgeInsets.all(15),
            child: const Column(
              children: [
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
                style:  GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle1, style:  GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title2,
                style:  GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle2, style:  GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
