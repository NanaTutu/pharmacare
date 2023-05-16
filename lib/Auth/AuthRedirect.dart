import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pharmacare/Auth/AuthPage.dart';
import 'package:pharmacare/Screens/LandingPage.dart';
import 'package:pharmacare/Screens/HomePage.dart';
import 'package:pharmacare/Screens/PharmacyHomePage.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AuthRedirect extends StatefulWidget {
  const AuthRedirect({Key? key}) : super(key: key);

  @override
  State<AuthRedirect> createState() => _AuthRedirectState();
}

class _AuthRedirectState extends State<AuthRedirect> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return LandingPage();
          } else {
            print('no auth');
            return AuthPage();
          }
        },
      ),
    );
  }
}

// class AuthRedirect extends StatelessWidget {
//   const AuthRedirect({Key? key}) : super(key: key);
//
//   Future<String> getUserDetails() async{
//     String? email = FirebaseAuth.instance.currentUser?.email;
//     final  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
//     QuerySnapshot querySnapshot = await collectionReference.where('email', isEqualTo: email).get();
//     List<Object?> userData = querySnapshot.docs.map((e) => e.data()).toList();
//     String jsonData = jsonEncode(userData);
//
//     return jsonData;
//   }
//
//    role(){
//     return getUserDetails().then((value){
//       var data = jsonDecode(value);
//       return data[0]['role'];
//     });
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot){
//           if(snapshot.hasData){
//             print(role());
//             return Homepage();
//           }else{
//             return AuthPage();
//           }
//         },
//       ),
//     );
//   }
// }
