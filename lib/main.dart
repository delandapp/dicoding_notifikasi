import 'package:dicoding_notifikasi/pages/detail_page.dart';
import 'package:dicoding_notifikasi/pages/home_page.dart';
import 'package:dicoding_notifikasi/utils/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final NotificationHelper notificationHelper = NotificationHelper();
  await notificationHelper.initNotification(flutterLocalNotificationsPlugin);
  notificationHelper.requestAndroidPermissions(flutterLocalNotificationsPlugin);
  notificationHelper.requestIOSPermissions(flutterLocalNotificationsPlugin);

  runApp(
    MaterialApp(
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        DetailPage.routeName: (context) => DetailPage(),
      },
    ),
  );
}

// Jika kita lihat pada fungsi main, terdapat fungsi WidgetsFlutterBinding.ensureInitialized(). Fungsi tersebut wajib kita gunakan ketika ingin menjalankan suatu proses di dalam fungsi main. Sebabnya, di dalam fungsi main kita menjalankan dua proses yaitu permission dan juga inisiasi dari notifikasi.
