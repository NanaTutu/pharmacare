import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pharmacare/Util/UserModel.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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
  final _phone_number = TextEditingController();

  ImagePicker imagePicker = ImagePicker();
  String imageURL = '';
  String userDoc = '';
  String urlImage = '';
  XFile? profilePic;
  final CollectionReference _reference = FirebaseFirestore.instance.collection('users');

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _phone_number.dispose();
    super.dispose();
  }

  getImage(ImageSource source) async {
    // setState(() {
    //   _inProcess = true;
    // });
    XFile? image = await imagePicker.pickImage(source: source);

    if(image==null) return;

    setState(() {
      profilePic = image;
    });




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

    //create unique name for file
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    //upload to firebase storage

    //Get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images/profile pics');

    //Create a reference to the image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    //Handle errors/success
    try{

      //Store the file
      await referenceImageToUpload.putFile(File(profilePic!.path));

      //Success: get the download URL
      imageURL = await referenceImageToUpload.getDownloadURL();
      print('image url ${imageURL.toString()}');

      return users.doc(userDoc).set(
          {
            'first_name' : _firstNameController.text.trim(),
            'last_name' : _lastNameController.text.trim(),
            'age' : _ageController.text.trim(),
            'email': _emailController.text.trim(),
            'image': imageURL,
            'phone_number': _phone_number.text.trim(),
            'role': 'member'
          }
      )
          .whenComplete(() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>UserDataUpdate())))
          .catchError((error)=>QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: error.toString(),
      ));

    }catch(error){
      //Some errors that occur
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: error.toString(),
      );
    }


  }

  List<String> docIDs = [];

  Future<String> getUserDetails() async{
    String? email = FirebaseAuth.instance.currentUser?.email;
    final  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await collectionReference.where('email', isEqualTo: email).get();
    List<Object?> userData = querySnapshot.docs.map((e) => e.data()).toList();
    String jsonData = jsonEncode(userData);

    return jsonData;
  }

  Future<CollectionReference> getDocument() async{
      String? email = FirebaseAuth.instance.currentUser?.email;
      final  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');

      return collectionReference;
    }

  @override
  void initState() {
    // TODO: implement initState
    // getUserDetails();
    // getUserDetails().toString();
    getUserDetails().then((value) {
      var data = jsonDecode(value);
      print(data);
      setState(() {
        _firstNameController.text = data[0]['first_name'];
        _lastNameController.text = data[0]['last_name'];
        _ageController.text = data[0]['age'].toString();
        _emailController.text = data[0]['email'];
        _phone_number.text = data[0]['phone_number'];
        urlImage = data[0]['image'];
      });
      getDocument().then((value){
        value.where('email', isEqualTo: data[0]['email']).get().then((value) => value.docs.forEach((element) {setState(() {
          userDoc = element.id;
        });
        }));
      });
    });
    super.initState();
  }

  // Future<CollectionReference> getUserDetails() async{
  //     String? email = FirebaseAuth.instance.currentUser?.email;
  //     final  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
  //     // QuerySnapshot querySnapshot = await collectionReference.where('email', isEqualTo: email).get();
  //     // List<Object?> userData = querySnapshot.docs.map((e) => e.data()).toList();
  //     // String jsonData = jsonEncode(userData);
  //
  //     // collectionReference.where('email', isEqualTo: _emailController.text.trim()).get().then((value) => value.docs.forEach((element) {setState(() {
  //     //   _firstNameController.text = element.id;
  //     // });}));
  //
  //     return collectionReference;
  //   }

  // getUserDetails().then((value){
  //   value.where('email', isEqualTo: 'bohene8@gmail.com').get().then((value) => value.docs.forEach((element) {print(element.id);}));
  // });

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
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 70,
                      backgroundImage: NetworkImage(urlImage),
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
                            getImage(ImageSource.gallery);
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
                            controller: _phone_number,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Phone Number'
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
                        onTap: _updateData,
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
