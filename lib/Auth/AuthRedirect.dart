import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharmacare/Auth/AuthPage.dart';
import 'package:pharmacare/Screens/HomePage.dart';


class AuthRedirect extends StatelessWidget {
  const AuthRedirect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return Homepage();
          }else{
            return AuthPage();
          }
        },
      ),
    );
  }
}
