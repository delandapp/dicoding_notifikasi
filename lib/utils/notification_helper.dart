import 'package:dicoding_notifikasi/utils/received_notification.dart';
import 'package:rxdart/rxdart.dart';

final selectNotificationSubject = BehaviorSubject<String?>();
final didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

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
}