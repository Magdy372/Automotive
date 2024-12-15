import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_project/providers/user_provider.dart';
import 'package:car_rental_project/providers/car_provider.dart';
import 'package:car_rental_project/providers/rental_provider.dart';  // Added RentalProvider
import 'package:car_rental_project/screens/onboarding_screen.dart';
import 'package:car_rental_project/screens/admin_dashboard.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/login_screen.dart';

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
        ChangeNotifierProvider(create: (_) => RentalProvider()),  // Added RentalProvider
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
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
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



/* import 'package:car_rental_project/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:car_rental_project/screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Onboarding(),
    );
  }
} */



