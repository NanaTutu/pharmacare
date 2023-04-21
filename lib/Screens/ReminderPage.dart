import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmacare/Util/notifyService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {

  final hourController = TextEditingController();
  final minuteController = TextEditingController();


  @override
  void initState(){
    super.initState();
    NotificationService().initNotification();
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Manager'),
      ),
      body: Center(
        child: Column(
          children: [
            OutlinedButton(
              onPressed: () async{
                // await Workmanager().registerOneOffTask('taskOne', 'BackUP', initialDelay: Duration(minutes: 20));
                await Workmanager().registerPeriodicTask('task Two', 'periodic', frequency: Duration(minutes: 20));
                Timer.periodic(Duration(minutes: 1), (Timer t) {
                  print(count++);
                });
              },
              child: Text('Alarm now'),
            ),
            const SizedBox(height: 15),
            OutlinedButton(
              onPressed: () async{
                NotificationService().showNotification(
                  title: 'Sample Title',
                  body: 'It works!',
                );
              },
              child: Text('Show Notification'),
            ),
          ],
        )
      ),
    );
  }
}
