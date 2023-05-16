import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmacare/Screens/PharmacyHomePage.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AddDrugPage extends StatefulWidget {
  const AddDrugPage({Key? key}) : super(key: key);

  @override
  State<AddDrugPage> createState() => _AddDrugPageState();
}

class _AddDrugPageState extends State<AddDrugPage> {

  final _description = TextEditingController();
  final _drug_name = TextEditingController();
  final _drug_price = TextEditingController();

  ImagePicker imagePicker = ImagePicker();
  String imageURL = '';
  XFile? drug_photo;
  File? drugPhoto;
  final CollectionReference _reference = FirebaseFirestore.instance.collection('users');

  getImage(ImageSource source) async {
    // setState(() {
    //   _inProcess = true;
    // });
    XFile? image = await imagePicker.pickImage(source: source);

    if(image==null) return;

    setState(() {
      drug_photo = image;
      drugPhoto = File(image.path);
    });

  }

  Future<void> _addDrugDetails() async{

    //create unique name for file
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    //upload to firebase storage

    //Get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images/med_images');

    //Create a reference to the image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    CollectionReference drugs = FirebaseFirestore.instance.collection('drugs');

    //Handle errors/success
    try{

      //Store the file
      await referenceImageToUpload.putFile(File(drug_photo!.path));

      //Success: get the download URL
      imageURL = await referenceImageToUpload.getDownloadURL();
      print('image url ${imageURL.toString()}');

      await FirebaseFirestore.instance.collection('drugs').add({
        'drug_name': _drug_name.text.trim(),
        'price': _drug_price.text.trim(),
        'description': _description.text.trim(),
        'image': imageURL,
        'latitude': pharmacy_latitude,
        'longitude':pharmacy_longitude,
        'pharmacy_location':pharmacy_location,
        'pharmacy_name': pharmacy_name,
        'pharmacy_phone': pharmacy_phone,
        'category': dropdownValue,
        'email': pharmacy_email
      }).whenComplete((){
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Drug Details Uploaded Successful',
          confirmBtnText: 'Ok',
          barrierDismissible: false,
          onConfirmBtnTap: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PharmacyHomePage()));
          }
        );
      });

    }catch(error){
      //Some errors that occur
      print(error.toString());
    }

  }

  var categories = [
    'Prescription Drugs',
    'Over-the-Counter',
    'Generic Medicines',
    'Brand-Name Medicine',
    'Herbal Medicines',
    'Homeopathic Medicines',
    'Vaccines',
    'Controlled Substances',
    'Nutritional Supplements',
    'Medical Equipments'
  ];

  String dropdownValue = 'Prescription Drugs';
  String pharmacy_latitude = '';
  String pharmacy_longitude = '';
  String pharmacy_location = '';
  String pharmacy_name = '';
  String pharmacy_phone = '';
  String pharmacy_email = '';


  Future<String> getUserDetails() async{
    String? email = FirebaseAuth.instance.currentUser?.email;
    final  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await collectionReference.where('email', isEqualTo: email).get();
    List<Object?> userData = querySnapshot.docs.map((e) => e.data()).toList();
    String jsonData = jsonEncode(userData);

    return jsonData;
  }


  @override
  void initState() {
    // TODO: implement initState
    getUserDetails().then((value) {
      var data = jsonDecode(value);
      print(data);
      setState(() {
        pharmacy_name = data[0]['pharmacy_name'];
        pharmacy_location = data[0]['location'];
        pharmacy_latitude = data[0]['latitude'].toString();
        pharmacy_longitude = data[0]['longitude'].toString();
        pharmacy_phone = data[0]['phone_number'];
        pharmacy_email = data[0]['email'];
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _description.dispose();
    _drug_name.dispose();
    _drug_price.dispose();
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
                      'Add a drug o your database',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 50),

                    //Profile Pic
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 70,
                      backgroundImage: drugPhoto == null?const AssetImage('assets/img/drug_placeholder.png'):Image.file(drugPhoto!).image,
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
                            controller: _drug_name,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Name'
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
                            controller: _description,
                            maxLines: 5,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Description'
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
                            controller: _drug_price,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Price'
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
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: dropdownValue,
                              items: categories.map((String categories){
                                return DropdownMenuItem(
                                  value: categories,
                                  child: Text(
                                    categories,
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue){
                                setState(() {
                                  dropdownValue = newValue!;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                            )
                          )
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
                        onTap: _addDrugDetails,
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: const Center(
                            child: Text(
                              'Upload Drug Details',
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
