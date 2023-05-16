import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pharmacare/Screens/HomePage.dart';
import 'package:pharmacare/Screens/PharmacyHomePage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  String userRole = '';

  Future<String> getUserDetails() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    // print('email: $email');
    print('aaaaabbbbcccc');
    final CollectionReference collectionReference =
    FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
    await collectionReference.where('email', isEqualTo: email).get();
    List<Object?> userData = querySnapshot.docs.map((e) => e.data()).toList();
    print('lier $userData');
    String jsonData = jsonEncode(userData);

    return jsonData;
  }

  redirection() {
    getUserDetails().then((value) {
      var data = jsonDecode(value);
      print('DATA: $data');
      print('one: $userRole');
      print('role :${data[0]['role']}');
      setState(() {
        userRole = data[0]['role'];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    redirection();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if(userRole == 'member'){
      return Homepage();
    }else if(userRole == 'pharmacy'){
      return PharmacyHomePage();
    }else{
      return Scaffold(
        body: Center(
          child: LoadingAnimationWidget.inkDrop(
            color: Colors.deepPurple,
            size: height*0.05
          )
        ),
      );
    }
  }
}
