import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/Auth/AuthPage.dart';
import 'package:pharmacare/Auth/AuthRedirect.dart';
import 'package:pharmacare/Screens/ReminderPage.dart';
import 'package:pharmacare/Screens/UpdateUserData.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  String firstname = '';
  String lastname = '';
  String imageUrl = '';
  String phone_number = '';

  Future<String> getUserDetails() async{
    String? email = FirebaseAuth.instance.currentUser?.email;
    final  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await collectionReference.where('email', isEqualTo: email).get();
    List<Object?> userData = querySnapshot.docs.map((e) => e.data()).toList();
    String jsonData = jsonEncode(userData);

    return jsonData;
  }
  Future<void> logout() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    // print('User logged out successfully.');
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserDetails().then((value) {
      var data = jsonDecode(value);
      print(data);
      setState(() {
        firstname = data[0]['first_name'];
        lastname = data[0]['last_name'];
        phone_number = data[0]['phone_number'];
        imageUrl = data[0]['image'];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  // header
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //hamburger icon for drawer
                        IconButton(
                            onPressed: () {}, icon: const Icon(Icons.menu)),

                        //title
                        Text('PharmaCare',
                            style: GoogleFonts.lato(
                                fontSize: 25, fontWeight: FontWeight.bold)),

                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfilePage()));
                            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewScreen()));
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            backgroundImage: NetworkImage(imageUrl)
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  //profile picture
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 70,
                          backgroundImage: NetworkImage(imageUrl)
                        ),
                        const SizedBox(height: 10),

                        //user's name
                        Text(
                          "$firstname $lastname",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                          ),
                        ),
                        //user's phone number
                        Text(
                          phone_number,
                          style:GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.grey[500]
                          )
                        ),
                        const SizedBox(height: 15,),

                        // cards
                        Expanded(
                          child: Column(
                            children: [
                              //set pills reminder
                              GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 25
                                  ),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Text(
                                    'Set Pills Reminder',
                                      style:GoogleFonts.poppins(
                                          fontSize: 20,
                                          color: Colors.grey[500]
                                      )
                                  ),
                                ),
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ReminderPage()));
                                },
                              ),
                              SizedBox(height: 15,),

                              GestureDetector(
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserDataUpdate()));
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Text(
                                    'Update Your Information',
                                      style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          color: Colors.white
                                      ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height*0.02,
                              ),
                              GestureDetector(
                                onTap: (){
                                  FirebaseAuth.instance.signOut().whenComplete((){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AuthRedirect()));
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Text(
                                    'Log out',
                                    style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        color: Colors.white
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          )
                        ),
                      ],
                    )
                  ),
                ],
              )),
        ),
    );
  }
}
