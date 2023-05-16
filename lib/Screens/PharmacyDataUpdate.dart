import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmacare/Screens/PharmacyProfilePage.dart';
import 'package:quickalert/quickalert.dart';

class PharmacyDataUpdate extends StatefulWidget {
  const PharmacyDataUpdate({Key? key}) : super(key: key);

  @override
  State<PharmacyDataUpdate> createState() => _PharmacyDataUpdateState();
}

class _PharmacyDataUpdateState extends State<PharmacyDataUpdate> {

  final _emailController = TextEditingController();
  final _pharmacyNameController = TextEditingController();
  final _phone_number = TextEditingController();
  final _location = TextEditingController();

  ImagePicker imagePicker = ImagePicker();
  String imageURL = '';
  String userDoc = '';
  String urlImage = '';
  String latitude = '';
  String longitude = '';
  XFile? profilePic;
  final CollectionReference _reference = FirebaseFirestore.instance.collection('users');

  getImage(ImageSource source) async {
    // setState(() {
    //   _inProcess = true;
    // });
    XFile? image = await imagePicker.pickImage(source: source);

    if(image==null) return;

    setState(() {
      profilePic = image;
    });
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

      return users.doc(userDoc).update(
          {
            'pharmacy_name' : _pharmacyNameController.text.trim(),
            'location' : _location.text.trim(),
            'phone_number' : _phone_number.text.trim(),
            'email': _emailController.text.trim(),
            'latitude': latitude,
            'longitude': longitude,
            'role': 'pharmacy'
          }
      )
          .whenComplete(() => QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Your data has been updated successfully',
          barrierDismissible: false,
          onConfirmBtnTap: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PharmacyProfilePage()));
          }
      ))
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

  Future updateDocument() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference documentReference = firestore.collection('users').doc(userDoc);
    try{
      await documentReference.update(
          {
            'pharmacy_name' : _pharmacyNameController.text.trim(),
            'location' : _location.text.trim(),
            'phone_number' : _phone_number.text.trim(),
            'email': _emailController.text.trim(),
            'latitude': latitude,
            'longitude': longitude,
            'role': 'pharmacy'
          }
      ).whenComplete(() {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Your data has been updated successfully',
          barrierDismissible: false,
          onConfirmBtnTap: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PharmacyProfilePage()));
          }
        );
      }).catchError((error){
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: error.toString(),
        );
      });

    }catch(error){
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: error.toString(),
      );
    }

  }

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
        _pharmacyNameController.text = data[0]['pharmacy_name'];
        _location.text = data[0]['location'];
        _emailController.text = data[0]['email'];
        _phone_number.text = data[0]['phone_number'];
        urlImage = data[0]['image'];
        latitude = data[0]['latitude'];
        longitude = data[0]['longtitude'];
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

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _pharmacyNameController.dispose();
    _location.dispose();
    _phone_number.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
                            controller: _pharmacyNameController,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'pharmacy_name'
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
                            controller: _location,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Location'
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
                        onTap: imageURL == ''?_updateData:updateDocument,
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
