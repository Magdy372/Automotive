import 'package:car_rental_project/constants.dart';
import 'package:car_rental_project/screens/CarForm.dart';
import 'package:car_rental_project/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_project/providers/user_provider.dart';
import 'package:car_rental_project/providers/car_provider.dart';
import 'package:car_rental_project/providers/rental_provider.dart'; 
import 'package:car_rental_project/screens/onboarding_screen.dart';
import 'package:car_rental_project/screens/admin_dashboard.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:car_rental_project/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


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

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,  // This will make notifications pop up
    enableVibration: true,
    playSound: true,
    enableLights: true,
    showBadge: true,
  );

  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get FCM token
      String? token = await messaging.getToken();
      print('FCM Token: $token');

      // Initialize local notifications
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _notificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
          print('Notification clicked: ${details.payload}');
        },
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _notificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
              ),
            ),
            payload: message.data.toString(),
          );
        }
      });
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');
  }
}

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
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(NotificationService._firebaseMessagingBackgroundHandler);
  
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
                surface: AppColors.backgroundColorLight,
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
                surface: AppColors.backgroundColorDark,
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
              '/CarUpload': (context) => const CarUploadScreen(),
            },
          );
        },
      ),
    );
  }
}
