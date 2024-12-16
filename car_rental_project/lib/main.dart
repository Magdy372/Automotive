import 'package:car_rental_project/constants.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_project/providers/user_provider.dart';
import 'package:car_rental_project/providers/car_provider.dart';
import 'package:car_rental_project/providers/rental_provider.dart'; // Added RentalProvider
import 'package:car_rental_project/screens/onboarding_screen.dart';
import 'package:car_rental_project/screens/admin_dashboard.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/login_screen.dart';

class AppColors {
  // Light theme colors
  static const Color primaryColorLight = Color(0xFF738496);
  static const Color buttonBackLight = Color(0xFFEAEAED);
  static const Color activeButtonLight = Color.fromARGB(255, 237, 237, 240);
  static const Color navAndHeaderLight = Color(0xFF3A3B44);
  static const Color backgroundColorLight = Color(0xFFFAFAFC);
  static const Color textColorLight = Colors.black;
  // static const Color Categories =Color.fromARGB(255, 204, 201, 201)e;

  // Dark theme colors
  static const Color backgroundColorDark = Color.fromARGB(255, 219, 219, 226);
  static const Color navAndHeaderDark = Color.fromARGB(255, 0, 0, 0);
  static const Color textColorDark = Color.fromARGB(255, 0, 0, 0);
  static const Color buttonBackDark = Color.fromARGB(255, 230, 231, 236);
  static const Color primaryColorDark = Color.fromARGB(255, 76, 76, 77);
  static const Color activeButtonDark = Color.fromARGB(255, 237, 237, 241);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(
            create: (_) => RentalProvider()), // Added RentalProvider
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          // Determine the initial screen based on user state
          Widget initialScreen;

          if (userProvider.currentUser == null) {
            initialScreen = const Onboarding(); // No user logged in
          } else if (userProvider.currentUser?.role == 'admin') {
            initialScreen = const AdminDashboardScreen(); // Admin role
          } else {
            initialScreen = const HomeScreen(); // Regular user role
          }

          return MaterialApp(
            title: 'Car Rental App',
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: AppColors.primaryColorLight,
              scaffoldBackgroundColor: AppColors.backgroundColorLight,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.navAndHeaderLight,
                foregroundColor: AppColors.textColorLight,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.buttonBackLight, // Set button background color
                ),
              ),
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryColorLight,
                background: AppColors.backgroundColorLight,
                onPrimary: AppColors.textColorLight,
                secondary: AppColors.activeButtonLight,
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: AppColors.textColorLight),
                bodyMedium: TextStyle(color: AppColors.textColorLight),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: AppColors.primaryColorDark,
              scaffoldBackgroundColor: AppColors.backgroundColorDark,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.navAndHeaderDark,
                foregroundColor: AppColors.textColorDark,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.buttonBackDark, // Set button background color
                ),
              ),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryColorDark,
                background: AppColors.backgroundColorDark,
                onPrimary: AppColors.textColorDark,
                secondary: AppColors.activeButtonDark,
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: AppColors.textColorDark),
                bodyMedium: TextStyle(color: AppColors.textColorDark),
              ),
            ),
            themeMode: ThemeMode.system,
            home: initialScreen,
            debugShowCheckedModeBanner: false,
            routes: {
              '/onboarding': (context) => const Onboarding(),
              '/admin': (context) => const AdminDashboardScreen(),
              '/home': (context) => const HomeScreen(),
              '/login': (context) => LoginScreen(),
              '/profile': (context) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
