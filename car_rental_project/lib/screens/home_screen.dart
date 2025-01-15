import 'package:car_rental_project/screens/CarForm.dart';
import 'package:car_rental_project/screens/car_listing_screen.dart';
import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:car_rental_project/models/car_model.dart';
import 'package:car_rental_project/screens/car_detail_screen.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:car_rental_project/screens/settings_screen.dart';
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
    final carsProvider = Provider.of<CarProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(userProvider, isDarkMode),
              _buildFilters(isDarkMode),
              _buildFilteredCars(carsProvider), // Display filtered cars
              _buildSearchResults(carsProvider),
              _buildFeaturedCars(carsProvider),
              _buildPopularDeals(carsProvider),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(UserProvider userProvider, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Welcome Message
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${userProvider.currentUser?.name ?? 'Guest'}",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
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
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 25, left: 10, right: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isDarkMode ? Colors.grey[800] : const Color(0XFF97B3AE),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: isDarkMode ? Colors.grey[300] : Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSearchBar(isDarkMode),
      ],
    );
  }

  // Search Bar Widget
  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, left: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.grey[900]
              : const Color.fromARGB(255, 249, 248, 247),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.search,
                color: isDarkMode ? Colors.grey[400] : const Color(0XFF97B3AE)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  _showFilters = false;
                  Provider.of<CarProvider>(context, listen: false)
                      .filterCars(query);
                },
                style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey),
                decoration: InputDecoration(
                  hintText: 'Search for your dream car',
                  hintStyle: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.grey[600] : Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                Provider.of<CarProvider>(context, listen: false).filterCars('');
              },
              child: Icon(
                Icons.close,
                color: isDarkMode ? Colors.grey[400] : const Color(0XFF97B3AE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDarkMode) {
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
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.close : Icons.filter_list,
                  color: isDarkMode ? Colors.grey[400] : const Color(0XFF97B3AE),
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters; // Toggle filter visibility
                    _searchController.clear();
                    selectedBrand = null;
                    selectedBodyType = null;
                    selectedTransmission = null;
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
              [
                'All',
                ...Brand.values.map((b) => b.toString().split('.').last),
              ],
              (value) {
                setState(() {
                  selectedBrand = value == 'All' ? null : value;
                  print(selectedBrand);
                });
              },
              selectedBrand,
              isDarkMode,
            ),
            const SizedBox(height: 10),
            _buildDropdownFilter(
              'Body Type',
              [
                'All',
                ...BodyType.values.map((b) => b.toString().split('.').last),
              ],
              (value) {
                setState(() {
                  selectedBodyType = value == 'All' ? null : value;
                  print(selectedBodyType);
                });
              },
              selectedBodyType,
              isDarkMode,
            ),
            const SizedBox(height: 10),
            _buildDropdownFilter(
              'Transmission',
              [
                'All',
                ...TransmissionType.values
                    .map((t) => t.toString().split('.').last),
              ],
              (value) {
                setState(() {
                  selectedTransmission = value == 'All' ? null : value;
                  print(selectedTransmission);
                });
              },
              selectedTransmission,
              isDarkMode,
            ),
            const SizedBox(height: 10),
            _buildMultiSelectFilter(
                'Features',
                Feature.values
                    .map((f) => f.toString().split('.').last)
                    .toList(), (selected) {
              setState(() {
                selectedFeatures = selected;
                print(selectedFeatures);
              });
            }, isDarkMode),
          ]
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    List<String> options,
    Function(String?) onChanged,
    String? selectedValue,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDarkMode ? Colors.grey[300] : Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: DropdownButton<String>(
            value: selectedValue ?? 'All',
            isExpanded: true,
            dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMultiSelectFilter(
    String label,
    List<String> options,
    Function(List<String>) onSelectionChanged,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 10,
          children: options.map((option) {
            final isSelected = selectedFeatures.contains(option);
            return ChoiceChip(
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
              selectedColor: isDarkMode ? Colors.grey[600] : const Color(0XFF97B3AE),
              label: Text(
                option,
                style: GoogleFonts.poppins(
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.grey[300] : Colors.black),
                ),
              ),
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

  Widget _buildFilteredCars(CarProvider carsProvider) {
    if (!_showFilters) {
      return const SizedBox.shrink(); // Returns an empty widget
    }
    List<Car> filteredCars = carsProvider.cars.where((car) {
      // Brand filtering
      if (selectedBrand != null &&
          car.brand !=
              Brand.values.firstWhere(
                  (b) => b.toString().split('.').last == selectedBrand)) {
        return false;
      }

      // Body Type filtering
      if (selectedBodyType != null &&
          car.bodyType !=
              BodyType.values.firstWhere(
                  (b) => b.toString().split('.').last == selectedBodyType)) {
        return false;
      }

      // Transmission filtering
      if (selectedTransmission != null &&
          car.transmissionType !=
              TransmissionType.values.firstWhere(
                  (t) => t.toString().split('.').last == selectedTransmission)) {
        return false;
      }

      // Features filtering - check if ANY selected feature is present
      if (selectedFeatures.isNotEmpty &&
          !selectedFeatures.every((feature) => car.features.contains(Feature
              .values
              .firstWhere((f) => f.toString().split('.').last == feature)))) {
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
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
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
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.black,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // If no search query, return empty widget
    if (_searchController.text.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Search Results",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          cars.isEmpty
              ? Text(
                  'No cars found',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.black,
                  ),
                ) // Show message if no cars match
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
  Widget _buildFeaturedCars(CarProvider carsProvider) {
    final cars = carsProvider.cars;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    print(cars);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Featured Cars",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.black,
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
  Widget _buildPopularDeals(CarProvider carsProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Cars = carsProvider.cars
        .where((car) => car.rating >= 0) // Filter based on high ratings
        .toList();

    Cars.sort((a, b) =>
        b.rating.compareTo(a.rating)); // Sort by rating in descending order

    final popularCars = Cars.take(5).toList(); // Take the top 5 cars

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
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : const Color(0XFF97B3AE),
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
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CarListingScreen()),
                            );
                          },
                          child: Text(
                            'View All',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark? Colors.grey[300]: Colors.white,
                            ), // You can change this color if you want
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.grey[900]
              : const Color.fromARGB(255, 247, 245, 244),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Top side - Image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[900]
                    : const Color.fromARGB(255, 247, 245, 244),
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
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.grey[300] : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    car.name,
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.grey[300] : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        car.rating.toString(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey[300] : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${car.price}/day',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDarkMode ? Colors.grey[300] : Colors.black,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : const Color(0XFF97B3AE),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: GNav(
            color: isDarkMode ? Colors.grey[300] : Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.white.withOpacity(0.30),
            padding: const EdgeInsets.all(12),
            gap: 5,
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
              GButton(icon: Icons.home),
              GButton(icon: Icons.notifications),
              GButton(icon: Icons.person),
              GButton(icon: Icons.settings),
            ],
          ),
        ),
      ),
    );
  }
}
