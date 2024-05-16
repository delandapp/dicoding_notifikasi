import 'package:dicoding_notifikasi/utils/received_notification.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  static const routeName = '/detail_page';

  @override
  Widget build(BuildContext context) {
    final ReceivedNotification arg =
        ModalRoute.of(context)?.settings.arguments as ReceivedNotification;
    return Scaffold(
      appBar: AppBar(
        title: Text('Title: ${arg.payload}'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}

// Di sini kita akan menampilkan payload yang bertipe String dari notifikasi dan akan ditampilkan di halaman detail pada AppBar.
