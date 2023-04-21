import 'dart:io';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pharmacare/Util/UserModel.dart';

class UserDataUpdate extends StatefulWidget {
  const UserDataUpdate({Key? key}) : super(key: key);

  @override
  State<UserDataUpdate> createState() => _UserDataUpdateState();
}

class _UserDataUpdateState extends State<UserDataUpdate> {

  //controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();

  ImagePicker imagePicker = ImagePicker();
  String imageURL = '';
  UserModel? userModel;
  final CollectionReference _reference = FirebaseFirestore.instance.collection('users');

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  getImage(ImageSource source) async {
    // setState(() {
    //   _inProcess = true;
    // });
    XFile? image = await imagePicker.pickImage(source: source);
    print('aaaaaaaaaa');
    print('${image?.path}');

    if(image==null) return;
    //create unique name for file
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    // print(uniqueFileName);

    //upload to firebase storage

    //Get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    
    //Create a reference to the image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    //Handle errors/success
    try{

      //Store the file
      await referenceImageToUpload.putFile(File(image!.path));

      //Success: get the download URL
      imageURL = await referenceImageToUpload.getDownloadURL();
      print(imageURL.toString());

    }catch(error){
      //Some errors that occur
      print(error.toString());
    }


    // if (image != null) {
    //   File cropped = await ImageCropper.cropImage(
    //       sourcePath: image.path,
    //       aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    //       compressQuality: 100,
    //       maxWidth: 200,
    //       maxHeight: 200,
    //       compressFormat: ImageCompressFormat.png,
    //       androidUiSettings: AndroidUiSettings(
    //           toolbarColor: Colors.lightGreen,
    //           toolbarTitle: 'Crop Image',
    //           statusBarColor: Colors.green.shade900,
    //           backgroundColor: Colors.white));
    //
    //   setState(() {
    //     _image = cropped;
    //     _inProcess = false;
    //   });
    // } else {
    //   setState(() {
    //     _inProcess = false;
    //   });
    // }
  }

  Future<void> _updateData() async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return users.doc('Ug00SyjnghdUe6SAHqyY').set(
      {
        'first_name' : 'Nana',
        'last_name' : 'Tutu',
        'age' : '60',
        'email': 'bohene8@gmail.com',
        'image': 'asfdfasdfasdf'
      }
    )
        .then((value) => print('Data has been set!'))
        .catchError((error)=>print(error.toString()));
  }

  List<String> docIDs = [];

  Future getUserDetails() async{
    String? email = FirebaseAuth.instance.currentUser?.email;
    final snapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).single;
    return userData;
  }

  @override
  void initState() {
    // TODO: implement initState
    // getUserDetails();
    // getUserDetails().toString();
    super.initState();
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
                      'Update your details',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 50),

                    //Profile Pic
                    const CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 70,
                      backgroundImage: AssetImage('assets/img/profilepic.jpg'),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: (){
                            getImage(ImageSource.camera);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[200],
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: Text(
                              'Camera',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: (){
                            _updateData();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.deepPurple[200],
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Text(
                              'Gallery',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 30),

                    //firstname textfield
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
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'First Name'
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Last Name textfield
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
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Last Name'
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Age textfield
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
                            controller: _ageController,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Age'
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

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

                    //confirm password text field
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
                            obscureText: true,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password'
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //sign up button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25
                      ),
                      child: GestureDetector(
                        // onTap: signup,
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: const Center(
                            child: Text(
                              'Update Information',
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
                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Go Back',
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
