import 'dart:io';
import 'dart:typed_data';

import 'package:dicoding_notifikasi/utils/received_notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

// Jika dilihat, di luar kelas tersebut terdapat dua inisiasi variabel seperti selectNotificationSubject dan didReceiveLocalNotificationSubject. Variabel tersebut memang diinisiasikan di luar kelas karena kita akan memanggilnya pada top level dari aplikasi. Dua variabel tersebut juga mengandung Stream berasal dari BehaviourSubject yang dibuat agar aplikasi dapat merespon dari notifikasi ketika inisiasi sudah dilakukan pada fungsi main nantinya.

final selectNotificationSubject = BehaviorSubject<String?>();
final didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

// Jika kita lihat di dalam kelas NotificationHelper kita menambahkan channel seperti _channelId, _channelName, dan _channelDesc. Hal ini diperlukan ketika akan menjalankan notifikasi pada platform Android versi 8.0 ke atas atau mulai dari Android versi Oreo. Selain itu, kita juga membuat fungsi factory yang berguna untuk mengembalikan instance dari kelas NotificationHelper dengan menggunakan konsep  singleton.

class NotificationHelper {
  static const _channelId = '01';
  static const _channelName = 'channel_01';
  static const _channelDesc = 'dicoding_notifikasi channel';
  static NotificationHelper? _instance;

  NotificationHelper._internal() {
    _instance = this;
  }

  factory NotificationHelper() => _instance ?? NotificationHelper._internal();

  //! Kita akan membuat beberapa fungsi jenis notifikasi di kelas ini

  Future<void> initNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    // TODO Implementasi fungsi ini
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) async {
      final payload = details.payload;
      if (payload != null) {
        print('notification payload: $payload');
      }
      selectNotificationSubject.add(payload);
    });
  }

  void requestAndroidPermissions(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void requestIOSPermissions(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Pada versi iOS lebih lama kita perlu menambahkan callback yang dipicu saat notifikasi ditampilkan ketika aplikasi berada di foreground. Berikut adalah fungsi tersebut:
  void configureDidReceiveLocalNotificationSubject(
      BuildContext context, String route) {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.pushNamed(context, route,
                    arguments: receivedNotification);
              },
            )
          ],
        ),
      );
    });
  }

  Future<void> showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        _channelId, _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'plain title',
      'plain body',
      platformChannelSpecifics,
      payload: 'plain notification',
    );
  }

  Future<void> showNotificationWithNoBody(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        _channelId, _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'plain title',
      null,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> scheduleNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var dateTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      icon: 'secondary_icon',
      sound: const RawResourceAndroidNotificationSound('slow_spring_board'),
      largeIcon: const DrawableResourceAndroidBitmap('sample_large_icon'),
      vibrationPattern: vibrationPattern,
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    var iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails(sound: 'slow_spring_board.aiff');

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'scheduled title',
      'scheduled body',
      dateTime,
      platformChannelSpecifics,
      payload: 'scheduled notification',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> showGroupedNotifications(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var groupKey = 'com.android.example.WORK_EMAIL';

    var firstNotificationAndroidSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
    );

    var firstNotificationPlatformSpecifics =
        NotificationDetails(android: firstNotificationAndroidSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      'Alex Faarborg',
      'You will not believe...',
      firstNotificationPlatformSpecifics,
    );

    var secondNotificationAndroidSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
    );

    var secondNotificationPlatformSpecifics =
        NotificationDetails(android: secondNotificationAndroidSpecifics);

    await flutterLocalNotificationsPlugin.show(
      2,
      'Jeff Chang',
      'Please join us to celebrate the...',
      secondNotificationPlatformSpecifics,
    );

    var lines = <String>[];
    lines.add('Alex Faarborg  Check this out');
    lines.add('Jeff Chang    Launch Party');

    var inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: '2 messages',
      summaryText: 'janedoe@example.com',
    );

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      styleInformation: inboxStyleInformation,
      groupKey: groupKey,
      setAsGroupSummary: true,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      3,
      'Attention',
      'Two messages',
      platformChannelSpecifics,
    );
  }

  Future<void> showProgressNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var maxProgress = 5;
    for (var i = 0; i <= maxProgress; i++) {
      await Future.delayed(const Duration(seconds: 1), () async {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          channelShowBadge: false,
          importance: Importance.max,
          priority: Priority.high,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: maxProgress,
          progress: i,
        );

        var platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.show(
          0,
          'progress notification title',
          'progress notification body',
          platformChannelSpecifics,
          payload: 'item x',
        );
      });
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(Uri.parse(url));
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> showBigPictureNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var largeIconPath = await _downloadAndSaveFile(
        'http://via.placeholder.com/48x48', 'largeIcon');
    var bigPicturePath = await _downloadAndSaveFile(
        'http://via.placeholder.com/400x800', 'bigPicture');

    var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      contentTitle: 'overridden <b>big</b> content title',
      htmlFormatContentTitle: true,
      summaryText: 'summary <i>text</i>',
      htmlFormatSummaryText: true,
    );

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      styleInformation: bigPictureStyleInformation,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'big text title',
      'silent body',
      platformChannelSpecifics,
    );
  }

  Future<void> showNotificationWithAttachment(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var bigPicturePath = await _downloadAndSaveFile(
        'http://via.placeholder.com/600x200', 'bigPicture.jpg');

    var bigPictureAndroidStyle =
        BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPictureAndroidStyle,
    );

    var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        attachments: [DarwinNotificationAttachment(bigPicturePath)]);

    var notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'notification with attachment title',
      'notification with attachment body',
      notificationDetails,
    );
  }

  void configureSelectNotificationSubject(BuildContext context, String route) {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.pushNamed(context, route,
          arguments: ReceivedNotification(payload: payload));
    });
  }
}

// Di dalam fungsi factory kita melakukan pengecekan. Jika kita belum membuat sebuah objek (instance bernilai null), maka fungsi ini akan mengembalikan instance objek NotificationHelper._internal(). Tetapi jika sudah, kita tidak akan membuatnya lagi dan akan langsung mengembalikan instance sebelumnya.

// Bisa kita lihat bahwa pada fungsi initNotifications terdapat beberapa inisiasi variabel seperti initializationSettingsAndroid, initializationSettingsIOS, dan initializationSettings. Fungsi ini bertugas sebagai penginisiasi notifikasi agar dapat berjalan pada Android dan iOS. Variabel initializationSettingsAndroid berfungsi untuk mendefinisikan pengaturan pada aplikasi Android seperti menampilkan ikon notifikasi yang bernama ‘app_icon’ yang sebelumnya sudah kita tambahkan pada direktori drawable. Kemudian variabel initializationSettingsIOS berfungsi untuk mendefinisikan pengaturan pada aplikasi iOS. Pada variabel ini juga terdapat parameter seperti onDidReceiveLocalNotification yang akan mengirimkan data seperti id, title, body, dan payload ketika menjalankan pada device iOS versi lama.
