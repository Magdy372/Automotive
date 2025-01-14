import 'package:car_rental_project/screens/CarForm.dart';
import 'package:car_rental_project/screens/car_listing_screen.dart';
import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:car_rental_project/models/car_model.dart';
import 'package:car_rental_project/screens/car_detail_screen.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:car_rental_project/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:car_rental_project/constants.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/car_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();


  bool _showFilters = false; // Toggle visibility of filters
  String? selectedBrand; 
  String? selectedBodyType; 
  String? selectedTransmission; 
  List<String> selectedFeatures = [];

  @override
  void initState() {
    super.initState();
    // Fetch the cars once when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final carsProvider = Provider.of<CarProvider>(context, listen: false);
      carsProvider.fetchCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme
        .appBarTheme.backgroundColor; // Use theme's AppBar background color
    final textColor = theme
        .colorScheme.onPrimary; // Text/icon color for active/inactive states
    final activeTabColor = theme.colorScheme.primary;
    final carsProvider = Provider.of<CarProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(userProvider, theme),
              _buildFilters(theme),
              _buildFilteredCars(carsProvider,theme), // Display filtered cars
              _buildSearchResults(carsProvider),
              _buildFeaturedCars(carsProvider, theme),
              _buildPopularDeals(carsProvider, theme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(UserProvider userProvider, ThemeData theme) {
    final backgroundColor = theme.appBarTheme.backgroundColor;
    final textColor = theme.colorScheme.onPrimary;
    final activeTabColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Welcome Message
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${userProvider.currentUser?.name ?? 'Guest'}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorLight,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Find your dream car",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textColorLight,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align icons at the end
                  children: [
                    // Notification Icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.ButtonBackLight.withOpacity(0.2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textColorLight,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Sell Your Car Icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CarUploadScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.ButtonBackLight.withOpacity(0.2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: AppColors.textColorLight,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
        ],
      ),
    );
  }

  // Search Bar Widget
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.ButtonBackLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.textColorLight.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.NavAndHeaderLight),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                _showFilters = false;
                Provider.of<CarProvider>(context, listen: false)
                    .filterCars(query);
              },
              style: const TextStyle(color: AppColors.primaryColorLight),
              decoration: const InputDecoration(
                hintText: 'Search for your dream car',
                hintStyle: TextStyle(color: AppColors.primaryColorLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _searchController.clear();
              Provider.of<CarProvider>(context, listen: false).filterCars('');
            },
            child: const Icon(
              Icons.close,
              color: AppColors.NavAndHeaderLight,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildFilters(ThemeData theme) {
  final textColor = theme.colorScheme.onPrimary;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            IconButton(
              icon: Icon(
                _showFilters ? Icons.close : Icons.filter_list,
                color: theme.colorScheme.onPrimary,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters; // Toggle filter visibility
                  _searchController.clear();
                  selectedBrand= null; 
                  selectedBodyType= null; 
                  selectedTransmission= null; 
                  selectedFeatures.clear();

                });
              },
            ),
          ],
        ),
        if (_showFilters) ...[
          const SizedBox(height: 15),
          _buildDropdownFilter(
          'Brand',
            ['All', ...Brand.values.map((b) => b.toString().split('.').last)],
            (value) {
              setState(() {
                selectedBrand = value == 'All' ? null : value;
                print(selectedBrand);
              });
            },
            selectedBrand,
          ),
          const SizedBox(height: 10),
          _buildDropdownFilter(
            'Body Type',
            ['All', ...BodyType.values.map((b) => b.toString().split('.').last)],
            (value) {
              setState(() {
                selectedBodyType = value == 'All' ? null : value;
                print(selectedBodyType);
              });
            },
            selectedBodyType,
          ),
          const SizedBox(height: 10),
          _buildDropdownFilter(
            'Transmission',
            ['All', ...TransmissionType.values.map((t) => t.toString().split('.').last)],
            (value) {
              setState(() {
                selectedTransmission = value == 'All' ? null : value;
                print(selectedTransmission);
              });
            },
            selectedTransmission,
          ),

          const SizedBox(height: 10),
          _buildMultiSelectFilter(
            'Features',
            Feature.values.map((f) => f.toString().split('.').last).toList(),
            (selected) {
              setState(() {
                selectedFeatures = selected;
                print(selectedFeatures);
              });
            },
          ),

        ]
      ],
    ),
  );
}

Widget _buildDropdownFilter(String label, List<String> options, Function(String?) onChanged, String? selectedValue) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      DropdownButton<String>(
        value: selectedValue ?? 'All',
        isExpanded: true,
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget _buildMultiSelectFilter(String label, List<String> options, Function(List<String>) onSelectionChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      Wrap(
        spacing: 10,
        children: options.map((option) {
          final isSelected = selectedFeatures.contains(option);
          return ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFeatures.add(option);
                } else {
                  selectedFeatures.remove(option);
                }
                onSelectionChanged(selectedFeatures);
              });
            },
          );
        }).toList(),
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget _buildFilteredCars(CarProvider carsProvider ,ThemeData theme ) {
    final backgroundColor = theme
        .appBarTheme.backgroundColor; // Use theme's AppBar background color
    final textColor = theme
        .colorScheme.onPrimary; // Text/icon color for active/inactive states
    final activeTabColor = theme.colorScheme.primary;
    final restButtonColor = theme.colorScheme.secondary;

  if (!_showFilters) {
    return const SizedBox.shrink(); // Returns an empty widget
  }
  List<Car> filteredCars = carsProvider.cars.where((car) {
    // Brand filtering
    if (selectedBrand != null && car.brand != Brand.values.firstWhere((b) => b.toString().split('.').last == selectedBrand)) return false;
    
    // Body Type filtering
    if (selectedBodyType != null && car.bodyType != BodyType.values.firstWhere((b) => b.toString().split('.').last == selectedBodyType)) return false;
    
    // Transmission filtering
    if (selectedTransmission != null && car.transmissionType != TransmissionType.values.firstWhere((t) => t.toString().split('.').last == selectedTransmission)) return false;
    
    // Features filtering - check if ANY selected feature is present
    if (selectedFeatures.isNotEmpty &&
        !selectedFeatures.every((feature) => car.features.contains(Feature.values.firstWhere((f) => f.toString().split('.').last == feature)))) {
      return false;
    }
    
    return true;
  }).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Only show "Filtered Cars" label if filters are applied and there are cars
      if (_showFilters && filteredCars.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Filtered Cars',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: textColor
            ),
          ),
        ),
      
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: filteredCars.isEmpty
            ? Text(
                _showFilters 
                  ? 'No cars match the selected filters.' 
                  : 'All Cars',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color
                ),
              )
            : SizedBox(
                  height: 350, // Match the height of Featured Cars
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredCars.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CarDetailScreen(car: filteredCars[index]),
                            ),
                          );
                        },
                        child: _buildCarCard(filteredCars[index], context),
                      );
                    },
                  ),
                ),
      ),
    ],
  );  
}


  Widget _buildSearchResults(CarProvider carsProvider) {
    final cars = carsProvider.filtercars;

    // If no search query, return empty widget
    if (_searchController.text.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Search Results",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.NavAndHeaderLight,
            ),
          ),
          const SizedBox(height: 15),
          cars.isEmpty
              ? const Text('No cars found') // Show message if no cars match
              : SizedBox(
                  height: 350, // Match the height of Featured Cars
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CarDetailScreen(car: cars[index]),
                            ),
                          );
                        },
                        child: _buildCarCard(cars[index], context),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // Featured Cars Section
  Widget _buildFeaturedCars(CarProvider carsProvider, ThemeData theme) {
    final backgroundColor = theme
        .appBarTheme.backgroundColor; // Use theme's AppBar background color
    final textColor = theme
        .colorScheme.onPrimary; // Text/icon color for active/inactive states
    final activeTabColor = theme.colorScheme.primary;
    final restButtonColor = theme.colorScheme.secondary;
    final cars = carsProvider.cars;
    print(
        "22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222");
    print(cars);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Featured Cars",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 15),
          cars.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarDetailScreen(
                              car: cars[index],
                            ),
                          ),
                        );
                      },
                      child: _buildCarCard(cars[index], context),
                    );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // Popular Deals Section
  Widget _buildPopularDeals(CarProvider carsProvider, ThemeData theme) {
    final backgroundColor = theme
        .appBarTheme.backgroundColor; // Use theme's AppBar background color
    final textColor = theme
        .colorScheme.onPrimary; // Text/icon color for active/inactive states
    final activeTabColor = theme.colorScheme.primary;
    final restButtonColor = theme.colorScheme.secondary;
    final Cars = carsProvider.cars
        .where((car) => car.rating >= 0) // Filter based on high ratings
        .toList();

    Cars.sort((a, b) =>
        b.rating.compareTo(a.rating)); // Sort by rating in descending order

    final popularCars = Cars.take(5).toList(); // Take the top 5 cars

    print(
        "111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111");
    print(popularCars);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Popular Deals",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  // You can implement the "View All" functionality here
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                     Align(
  alignment: Alignment.centerRight,
  child: GestureDetector(
    onTap: () {
      // Navigate to CarListingScreen when tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  const CarListingScreen()),
      );
    },
    child: const Text(
      'View All',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue, // You can change this color if you want
      ),
    ),
  ),
)

                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          popularCars.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: popularCars.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarDetailScreen(
                              car: popularCars[index],
                            ),
                          ),
                        );
                      },
                      child: _buildCarCard(popularCars[index], context),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // Car Card Widget
  Widget _buildCarCard(Car car, BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme
        .appBarTheme.backgroundColor; // Use theme's AppBar background color
    final textColor = theme
        .colorScheme.onPrimary; // Text/icon color for active/inactive states
    final activeTabColor = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    // final buttonColor = theme.elevatedButtonTheme.style?.backgroundColor?.resolve({MaterialState.selected}) ?? theme.primaryColor;
    return GestureDetector(
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: secondary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.textColorLight.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top side - Image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: secondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Image.network(
                  car.image,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Bottom side - Car details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.brand.toString().split('.').last,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    car.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.black,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        car.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${car.price}/day',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavBar(BuildContext context) {
    // Access the current theme's colors dynamically
    final theme = Theme.of(context);
    final backgroundColor = theme
        .appBarTheme.backgroundColor; // Use theme's AppBar background color
    final textColor = theme
        .colorScheme.onPrimary; // Text/icon color for active/inactive states
    final activeTabColor =
        theme.colorScheme.primary; // Active tab background color

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: GNav(
          backgroundColor: backgroundColor!,
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: activeTabColor.withOpacity(0.5),
          padding: const EdgeInsets.all(16),
          gap: 8,
          onTabChange: (index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationScreen()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
                break;
            }
          },
          tabs: const [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.notifications, text: 'Notifications'),
            GButton(icon: Icons.person, text: 'Profile'),
            GButton(icon: Icons.settings, text: 'Settings'),
          ],
        ),
      ),
    );
  }
}
