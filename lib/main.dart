
import 'dart:ui';

import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacare/Auth/AuthRedirect.dart';
import 'package:pharmacare/Util/notifyService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

int count = 0;
void callbackDispatcher(){
  Workmanager().executeTask((taskName, inputData) {
    var values = inputData?.values.toList();
    String date = '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}';
    if(values?[0] == date){
      Workmanager().cancelByUniqueName(values?[1]);
    }else{
      NotificationService().showNotification(
        title: 'PharmaCare Reminder',
        body: '${values?[1]} - ${values?[2]}',
      );
    }
    print('${values?[0]}, $date ,${values?[1]}, ${values?[2]}');
    // NotificationService().showNotification(
    //   title: '${count++}',
    //   body: '${taskName}--${count++}' ,
    // );
    return  Future.value(true);
  });
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AndroidAlarmManager.initialize();
  NotificationService().initNotification();

  await Workmanager().initialize(callbackDispatcher);

  final androidInfo = await DeviceInfoPlugin().androidInfo;
  late final Map<Permission, PermissionStatus> statuses;

  if(androidInfo.version.sdkInt<=32){
    statuses = await[
      Permission.storage
    ].request();
  }else{
    statuses = await[
      Permission.storage,
      Permission.notification
    ].request();
  }

  // var allAccepted = true;
  // statuses.forEach((permission, status) {
  //    if(status != PermissionStatus.granted){
  //      allAccepted = false;
  //    }
  // });

  // if(allAccepted){
  //   final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
  //   final path = result?.files.single.path;
  //
  //   if(path!=null){
  //
  //   }
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const AuthRedirect(),
    );
  }
}

