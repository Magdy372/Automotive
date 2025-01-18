import 'package:car_rental_project/models/notificationItem_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    enableLights: true,
    showBadge: true,
  );

  static Database? _database;

  // Initialize the database
  static Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'notifications.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE notifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            body TEXT,
            data TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  // Save a notification to the database
  static Future<void> saveNotification(
      String? title, String? body, String data, DateTime date) async {
    if (_database == null) {
      await _initDatabase();
    }

    await _database?.insert(
      'notifications',
      {
        'title': title,
        'body': body,
        'data': data,
        'timestamp': date.toUtc().toIso8601String(), // Save in UTC
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all notifications from the database
  static Future<List<NotificationItem1>> getNotifications() async {
    if (_database == null) {
      await _initDatabase();
    }

    final List<Map<String, dynamic>> maps =
        await _database?.query('notifications', orderBy: 'timestamp DESC') ?? [];

    return maps.map((map) {
      return NotificationItem1(
        id: map['id'],
        title: map['title'] ?? 'No Title',
        body: map['body'] ?? 'No Content',
        data: map['data'] ?? '',
        date: DateTime.parse(map['timestamp']).toLocal(), // Convert to local time
      );
    }).toList();
  }

  // Delete a notification from the database
  static Future<void> deleteNotification(int id) async {
    if (_database == null) {
      await _initDatabase();
    }

    await _database?.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Initialize notifications
  static Future<void> initialize() async {
    await _initDatabase();

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

      String? token = await messaging.getToken();
      print('FCM Token: $token');

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _notificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (details) {
          print('Notification clicked: ${details.payload}');
        },
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          await saveNotification(
            notification.title,
            notification.body,
            message.data.toString(),
            DateTime.now(),
          );

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

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');
    await saveNotification(
      message.notification?.title,
      message.notification?.body,
      message.data.toString(),
      DateTime.now(),
    );
  }


   static Future<void> showImmediateNotification(carId) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch % 100000;
      
      // Check notification permission
      final plugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await plugin?.areNotificationsEnabled() ?? false;
      print('Notifications enabled: $granted');
      print('Immediate notification triggered with ID: $id');

      await _notificationsPlugin.show(
        id,
        'Rental Successfully Booked',
        'Thank you for choosing our service! Your rental for car "$carId" has been confirmed. The car is ready for pickup. Enjoy your ride!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
            //sound: const RawResourceAndroidNotificationSound('notification_sound'),
            playSound: true,
            enableVibration: true,
            showWhen: true,
          ),
        ),
        payload: 'test_payload_$id',
      );
      print('Immediate notification triggered with ID: $id');
      await saveNotification(
            'Rental Successfully Booked',
            'Thank you for choosing our service! Your rental for car $carId has been confirmed. The car is ready for pickup. Enjoy your ride!',
            "",
            DateTime.now(),
          );
    } catch (e) {
      print('Error showing immediate notification: $e');
    }
  }
}
