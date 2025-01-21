import 'package:flutter/material.dart';
import 'package:car_rental_project/services/FavoritesService.dart';
import 'package:car_rental_project/models/car_model.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Load favorites from the database
  Future<void> _loadFavorites() async {
    final favorites = await _favoritesService.getFavorites();
    setState(() {
      _favorites = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
   appBar: AppBar(
    backgroundColor: isDarkMode? Colors.black:Colors.white,
    title: Text(
      "Favorites",
      style: GoogleFonts.poppins(
        color:isDarkMode? Colors.grey[300]:Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ), 
    ),
    centerTitle: true, 
  ),

      body: _favorites.isEmpty
          ? Center(
              child: Text(
                'No favorites yet.',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final car = _favorites[index];
                return _buildFavoriteCard(car, isDarkMode);
              },
            ),
    );
  }

  // Build a card for each favorite car
  Widget _buildFavoriteCard(Map<String, dynamic> car, bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Car Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                car['image'],
                width: 100,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Car Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.grey[300] : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Brand: ${car['brand']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: \$${car['price']}/day',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Remove from Favorites Button
            IconButton(
              icon: Icon(
                Icons.delete,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
              onPressed: () async {
                await _favoritesService.removeFavorite(car['carId']);
                _loadFavorites(); // Refresh the list after removal
              },
            ),
          ],
        ),
      ),
    );
  }
}