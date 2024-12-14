import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For graph plotting

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboardd',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        cardColor: const Color(0xFF1F1F1F),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
          bodySmall: TextStyle(color: Colors.white54),
        ),
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Make the entire content scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 73, 72, 72),
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  StatsCard(
                    title: 'Total Cars',
                    count: '50',
                    icon: Icons.directions_car,
                    textColor: Colors.white,
                    backgroundColor: Colors.teal,
                  ),
                  StatsCard(
                    title: 'Rented Cars',
                    count: '15',
                    icon: Icons.car_repair,
                    textColor: Colors.white,
                    backgroundColor: Colors.deepOrange,
                  ),
                  StatsCard(
                    title: 'Total Users',
                    count: '120',
                    icon: Icons.group,
                    textColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  StatsCard(
                    title: 'Clients',
                    count: '75',
                    icon: Icons.people,
                    textColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Cars Rented & Uploaded Per Month',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 73, 72, 72),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(toY: 15, color: Colors.grey, width: 10),
                          BarChartRodData(toY: 10, color: Colors.black, width: 10),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(toY: 20, color: Colors.grey, width: 10),
                          BarChartRodData(toY: 18, color: Colors.black, width: 10),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(toY: 12, color: Colors.grey, width: 10),
                          BarChartRodData(toY: 8, color: Colors.black, width: 10),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(toY: 18, color: Colors.grey, width: 10),
                          BarChartRodData(toY: 14, color: Colors.black, width: 10),
                        ],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [
                          BarChartRodData(toY: 25, color: Colors.grey, width: 10),
                          BarChartRodData(toY: 20, color: Colors.black, width: 10),
                        ],
                      ),
                      BarChartGroupData(
                        x: 5,
                        barRods: [
                          BarChartRodData(toY: 30, color: Colors.grey, width: 10),
                          BarChartRodData(toY: 22, color: Colors.black, width: 10),
                        ],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Jan');
                              case 1:
                                return const Text('Feb');
                              case 2:
                                return const Text('Mar');
                              case 3:
                                return const Text('Apr');
                              case 4:
                                return const Text('May');
                              case 5:
                                return const Text('Jun');
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Legend(color: Colors.grey, label: 'Cars Rented'),
                  SizedBox(width: 16),
                  Legend(color: Colors.black, label: 'Cars Uploaded'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Average Rental Duration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 73, 72, 72),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 40,
                        color: Colors.teal,
                        title: '1-3 Days',
                        titleStyle: const TextStyle(color: Colors.black),
                      ),
                      PieChartSectionData(
                        value: 30,
                        color: Colors.orange,
                        title: '4-7 Days',
                        titleStyle: const TextStyle(color: Colors.black),
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: Colors.blue,
                        title: '8-14 Days',
                        titleStyle: const TextStyle(color: Colors.black),
                      ),
                      PieChartSectionData(
                        value: 10,
                        color: Colors.red,
                        title: '15+ Days',
                        titleStyle: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Recent Rentals',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 73, 72, 72),
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const RentalCard(
                      carModel: 'Tesla Model 3',
                      renterName: 'John Doe',
                      rentalDate: '2024-12-01',
                      imageAsset: 'assets/images/tesla_model.png',
                      textColor: Colors.white,
                    );
                  } else {
                    return const RentalCard(
                      carModel: 'BMW M4',
                      renterName: 'Jane Smith',
                      rentalDate: '2024-12-05',
                      imageAsset: 'assets/images/BMW_M4.png',
                      textColor: Colors.white,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color textColor;
  final Color backgroundColor;

  const StatsCard({super.key, 
    required this.title,
    required this.count,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 40, color: textColor),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RentalCard extends StatelessWidget {
  final String carModel;
  final String renterName;
  final String rentalDate;
  final String imageAsset;
  final Color textColor;

  const RentalCard({super.key, 
    required this.carModel,
    required this.renterName,
    required this.rentalDate,
    required this.imageAsset,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipOval(
          child: Image.asset(
            imageAsset,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          carModel,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rented by: $renterName',
              style: TextStyle(color: textColor.withOpacity(0.7)),
            ),
            Text(
              'Rental Date: $rentalDate',
              style: TextStyle(color: textColor.withOpacity(0.7)),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward, color: textColor.withOpacity(0.7)),
        onTap: () {
          // Handle tap event
        },
      ),
    );
  }
}

class Legend extends StatelessWidget {
  final Color color;
  final String label;

  const Legend({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }
}