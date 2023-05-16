import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'package:quickalert/quickalert.dart';

import 'package:pharmacare/Screens/ForgotPasswordPage.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isVisible = true;
  Icon _visiblityIcon = const Icon(Icons.visibility);
  Icon _visiblityOffIcon = const Icon(Icons.visibility_off);

  //sign in
  Future signIn() async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim()
      );
    }on FirebaseAuthException catch  (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Wrong email or password',
      );
    }
  }
  //dispose off controllers
  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_pharmacy,
                  size: 100,
                ),
                const SizedBox(height: 75),
                //hello again
                Text(
                  'PharmaCare',
                  style: GoogleFonts.lato(
                    fontSize: 52,
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hello there, Welcome',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 50),

                //email textfield
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(
                        color: Colors.white
                      ),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email'
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                //password textfield
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(
                            color: Colors.white
                        ),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _isVisible,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: _isVisible?_visiblityIcon:_visiblityOffIcon,
                            color: Colors.grey,
                            onPressed: () {
                              // print('i can see now');
                              if(_isVisible){
                                setState(() {
                                  _isVisible = false;
                                });
                              }else{
                                setState(() {
                                  _isVisible = true;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:[
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context){ return ForgotPasswordPage();})
                          );
                        },
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                //sign in button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25
                  ),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: const Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Not a member? ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: const Text(
                        'Register Now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      )
    );
  }
}
