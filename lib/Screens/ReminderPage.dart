import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/Util/notifyService.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
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
  final _title = TextEditingController();
  final _dosage = TextEditingController();
  final _interval = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();

  final DateTime dateTime = DateTime.now();
  static String? user_email = '';

  String dropdownValue = 'Min(s)';
  var time = ['Min(s)', 'Hour(s)', 'Day(s)'];

  @override
  void initState() {
    super.initState();
    setState(() {
      _startDate.text = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
      _endDate.text = '${dateTime.day}-${dateTime.month}-${dateTime.year}';

      user_email = FirebaseAuth.instance.currentUser?.email;
      print(user_email);
    });
    NotificationService().initNotification();
  }

  int count = 0;
  Future addMedicationtoFirebase() async {
    await FirebaseFirestore.instance.collection('medications').add({
      'medication': _title.text,
      'dosage': _dosage.text,
      'interval': '${_interval.text} $dropdownValue',
      'start_date': _startDate.text,
      'end_date': _endDate.text,
      'email': user_email
    });
  }
  
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserMedications(){
    return FirebaseFirestore.instance.collection('medications').where('email', isEqualTo: user_email).snapshots();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    hourController.dispose();
    minuteController.dispose();
    _title.dispose();
    _dosage.dispose();
    _interval.dispose();
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Text('Medication Reminder and History'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              //header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Set Medication Reminder',
                  style: GoogleFonts.poppins(
                      fontSize: 25, fontWeight: FontWeight.w500),
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    //Medication Textfield
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: _title,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: 'Medication'),
                      ),
                    ),

                    const SizedBox(height: 15),

                    //dosage and interval textfields
                    Row(
                      children: [
                        //dosage
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _dosage,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Dosage'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),

                        //choose interval unit
                        Flexible(
                            child: Row(
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    value: dropdownValue,
                                    items: time.map((String time) {
                                      return DropdownMenuItem(
                                          value: time,
                                          child: Text(
                                            time,
                                            style: GoogleFonts.poppins(
                                              fontSize: 17,
                                            ),
                                          ));
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownValue = newValue!;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                )),
                            const SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: TextField(
                                    controller: _interval,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Interval'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    //start date and end date
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _startDate,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Start Date',
                                    suffixIcon:
                                        Icon(Icons.date_range_outlined)),
                                onTap: () async {
                                  final date = await pickDate();
                                  if (date == null) return;

                                  setState(() {
                                    _startDate.text =
                                        '${date.day}-${date.month}-${date.year}';
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _endDate,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'End Date',
                                    suffixIcon:
                                        Icon(Icons.date_range_outlined)),
                                onTap: () async {
                                  final date = await pickDate();
                                  if (date == null) return;

                                  setState(() {
                                    _endDate.text =
                                        '${date.day}-${date.month}-${date.year}';
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    //set reminder button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: GestureDetector(
                        onTap: () async {
                          int _doseInterval = int.parse(_interval.text);
                          Duration duration = const Duration();
                          switch (dropdownValue) {
                            case 'Min(s)':
                              setState(() {
                                duration = Duration(minutes: _doseInterval);
                              });
                              break;
                            case 'Hour(s)':
                              setState(() {
                                duration = Duration(hours: _doseInterval);
                              });
                              break;
                            case 'Day(s)':
                              setState(() {
                                duration = Duration(days: _doseInterval);
                              });
                          }

                          try {
                            addMedicationtoFirebase().whenComplete(() async {
                              await Workmanager().registerPeriodicTask(
                                  _title.text, _title.text + _startDate.text,
                                  frequency: duration,
                                  inputData: {
                                    'endDate': _endDate.text,
                                    'title': _title.text,
                                    'dosage': _dosage.text
                                  }).whenComplete(() {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  title: 'Success',
                                  text: 'Medication reminder is set',
                                );
                              });
                            });
                          } on FirebaseException catch (e) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: 'Oops...',
                              text: 'Something went wrong',
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                            child: Text(
                              'Set Reminder',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text('Medication History',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),

                    //Medication History
                    Expanded(
                      child: Container(
                        child: StreamBuilder(
                          stream: getUserMedications(),
                          builder: (context, snapshot){
                            switch (snapshot.connectionState){
                              //if data is loading
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return const Center(child: CircularProgressIndicator(),);
                                
                              //if some or all data is loaded then show it
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                return ListView.builder(
                                  itemCount: data?.length,
                                  itemBuilder: (context, index){
                                    final medData = data?[index];
                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple[500],
                                        borderRadius: BorderRadius.circular(15)
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                medData?['medication'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white
                                                ),
                                              ),
                                              Text(
                                                '${medData?['dosage']}, every ${medData?['interval']}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.grey[300]
                                                ),
                                              ),
                                              Text(
                                                '${medData?['start_date']} - ${medData?['end_date']}',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey[200]
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      )
                                    );
                                  },
                                );
                            }
                          },
                        )
                      ),
                    )

                  ],
                ),
              ),

              // Container(
              //   alignment: Alignment.centerLeft,
              //   child: Text('Medication History',
              //     style: GoogleFonts.poppins(
              //         fontSize: 20,
              //         fontWeight: FontWeight.w500
              //     ),
              //   ),
              // ),

              // Container(
              //   child: SingleChildScrollView(
              //     child: ListView.builder(
              //             scrollDirection: Axis.vertical,
              //             shrinkWrap: true,
              //             itemCount: 7,
              //             itemBuilder: (context, index){
              //               return Container(
              //                 height: 100,
              //                 width: 100,
              //                 color: Colors.red,
              //                 margin: EdgeInsets.symmetric(vertical: 5),
              //               );
              //             },
              //           ),
              //   )
              // )
            ],
          ),
        ));
  }

  Future<DateTime?> pickDate() => showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(3000));
}

// OutlinedButton(
//   onPressed: () async{
//     // await Workmanager().registerOneOffTask('taskOne', 'BackUP', initialDelay: Duration(minutes: 20));
//     await Workmanager().registerPeriodicTask('task Two', 'periodic', frequency: Duration(minutes: 20));
//     Timer.periodic(Duration(minutes: 1), (Timer t) {
//       print(count++);
//     });
//   },
//   child: Text('Alarm now'),
// ),
// const SizedBox(height: 15),
// OutlinedButton(
//   onPressed: () async{
//     NotificationService().showNotification(
//       title: 'Sample Title',
//       body: 'It works!',
//     );
//   },
//   child: Text('Show Notification'),
// ),
