import 'package:car_rental_project/screens/CarForm.dart';
import 'package:car_rental_project/screens/onboarding_screens.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:car_rental_project/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_project/providers/user_provider.dart';
import 'package:car_rental_project/providers/car_provider.dart';
import 'package:car_rental_project/providers/rental_provider.dart';
import 'package:car_rental_project/screens/admin_dashboard.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:car_rental_project/services/NotificationService.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();

  try {
    await Supabase.initialize(
      url: 'https://mrwbinussxmgdlcyeztb.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yd2JpbnVzc3htZ2RsY3llenRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ0OTU1MDEsImV4cCI6MjA1MDA3MTUwMX0.OD8MDRSiqx63U_N7RXgANOYqtT38Xc_8GcodjZbi4RA',
    );
  } catch (e) {
    print('Supabase initialization error: $e');
  }

  FirebaseMessaging.onBackgroundMessage(
      NotificationService.firebaseMessagingBackgroundHandler);

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
        ChangeNotifierProvider(create: (_) => RentalProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            title: 'Automotive',
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
              // Light theme colors
              colorScheme: const ColorScheme.light(
                primary: Color(0XFF97B3AE),
                secondary: Color(0XFF97B3AE),
                surface: Colors.white,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Colors.black,
              ),
              // Card theme for light mode
              cardTheme: const CardTheme(
                color: Color.fromARGB(255, 247, 245, 244),
                elevation: 0,
              ),
              // Text theme for light mode
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black),
                bodyMedium: TextStyle(color: Colors.black87),
                titleLarge: TextStyle(color: Colors.black),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.black,
              // Dark theme colors
              colorScheme: ColorScheme.dark(
                primary: Colors.grey[800]!,
                secondary: Colors.grey[700]!,
                surface: Colors.grey[900]!,
                onPrimary: Colors.white,
                onSecondary: Colors.grey[300]!,
                onSurface: Colors.white,
              ),
              // Card theme for dark mode
              cardTheme: CardTheme(
                color: Colors.grey[900],
                elevation: 0,
              ),
              // Text theme for dark mode
              textTheme: TextTheme(
                bodyLarge: const TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.grey[300]),
                titleLarge: const TextStyle(color: Colors.white),
              ),
              // Bottom navigation bar theme
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.grey[850],
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey[400],
              ),
              // Input decoration theme
              inputDecorationTheme: InputDecorationTheme(
                fillColor: Colors.grey[900],
                filled: true,
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
            themeMode: ThemeMode.system, // This will follow the system theme
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/onboarding': (context) => const OnboardingScreens(),
              '/admin': (context) => const AdminDashboardScreen(),
              '/home': (context) => const HomeScreen(),
              '/login': (context) => LoginScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/CarUpload': (context) => const CarUploadScreen(),
            },
          );
        },
      ),
    );
  }
}