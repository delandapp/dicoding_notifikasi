import 'package:dicoding_notifikasi/main.dart';
import 'package:dicoding_notifikasi/pages/detail_page.dart';
import 'package:dicoding_notifikasi/utils/notification_helper.dart';
import 'package:dicoding_notifikasi/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/";
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificationHelper _notificationHelper = NotificationHelper();

  @override
  void initState() {
    super.initState();
    _notificationHelper.configureSelectNotificationSubject(
        context, DetailPage.routeName);
    _notificationHelper.configureDidReceiveLocalNotificationSubject(
        context, DetailPage.routeName);
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    didReceiveLocalNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Notification'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                CustomButton(
                  text: 'Show plain notification with payload',
                  onPressed: () async {
                    await _notificationHelper
                        .showNotification(flutterLocalNotificationsPlugin);
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Show plain notification that has no body with payload',
                  onPressed: () async {
                    await _notificationHelper.showNotificationWithNoBody(
                        flutterLocalNotificationsPlugin);
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Show grouped notifications [Android]',
                  onPressed: () async {
                    await _notificationHelper.showGroupedNotifications(
                        flutterLocalNotificationsPlugin);
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text:
                      'Show progress notification - updates every second [Android]',
                  onPressed: () async {
                    await _notificationHelper.showProgressNotification(
                        flutterLocalNotificationsPlugin);
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Show big picture notification [Android]',
                  onPressed: () async {
                    await _notificationHelper.showBigPictureNotification(
                        flutterLocalNotificationsPlugin);
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Show notification with attachment [iOS]',
                  onPressed: () async {
                    await _notificationHelper.showNotificationWithAttachment(
                        flutterLocalNotificationsPlugin);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Pertama kita lakukan pemanggilan fungsi configureSelectNotificationSubject dan configureDidReceiveLocalNotificationSubject di dalam metode initState. Tujuannya, agar fungsi tersebut hanya dijalankan satu kali saja ketika kelas ini dijalankan. Kemudian kita juga memanggil variabel selectNotificationSubject dan didReceiveLocalNotificationSubject di dalam metode dispose. Kenapa demikian? Untuk merespon notifikasi, kita membuka Stream yang berada di dalam fungsi configureSelectNotificationSubject dan configureDidReceiveLocalNotificationSubject. Karena itu, kita perlu menutup Stream tersebut di dalam metode dispose, agar aplikasi yang kita buat tidak menyebabkan kebocoran dari Stream.
