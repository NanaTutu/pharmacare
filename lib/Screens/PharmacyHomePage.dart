import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pharmacare/Screens/CategoriesPage.dart';
import 'package:pharmacare/Screens/PharmacyProfilePage.dart';
import 'package:pharmacare/Screens/ProfilePage.dart';
import 'package:pharmacare/Screens/SearchScreen.dart';
import 'package:pharmacare/Screens/AddDrug.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PharmacyHomePage extends StatefulWidget {
  const PharmacyHomePage({Key? key}) : super(key: key);

  @override
  State<PharmacyHomePage> createState() => _PharmacyHomePageState();
}

class _PharmacyHomePageState extends State<PharmacyHomePage> {

  final user = FirebaseAuth.instance.currentUser!;

  //controller
  final _searchbarController = TextEditingController();
  String? currentLocation = 'Location not loaded';

  getCurrentPosition() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // print(position);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks.first;
    setState(() {
      currentLocation = placemark.street;
    });
    // print(Geolocator.distanceBetween(position.latitude, position.longitude, 5.5798, -0.2470));
  }

  String pharmacy_name = '';
  String imageUrl = '';
  String phone_number = '';

  Future<String> getUserDetails() async{
    String? email = FirebaseAuth.instance.currentUser?.email;
    // print(email);
    final  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await collectionReference.where('email', isEqualTo: email).get();
    List<Object?> userData = querySnapshot.docs.map((e) => e.data()).toList();
    String jsonData = jsonEncode(userData);
    // print(jsonData);

    return jsonData;
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

  var colors = [
    Colors.indigoAccent,
    Colors.deepOrangeAccent,
    Colors.brown,
    Colors.pinkAccent,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.deepPurpleAccent,
    Colors.greenAccent,
    Colors.lightBlueAccent
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>> getPharmacyDrugs(){
    return FirebaseFirestore.instance.collection('drugs')
      .where('pharmacy_name', isEqualTo: pharmacy_name)
      .limit(10)
      .snapshots();
  }

  // Future deleteDrug() async{
  //   await FirebaseFirestore.instance.collection('medications').
  // }

  confirmDeletion(){
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: 'Are you sure?',
      text: 'Deletion cannot be undone',
      cancelBtnText: 'Cancel',
      showCancelBtn: true,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    getCurrentPosition();
    getUserDetails().then((value) {
      var data = jsonDecode(value);
      // print(data);
      // print('aaaaa ${data}');
      setState(() {
        pharmacy_name= data[0]['pharmacy_name'];
        phone_number = data[0]['phone_number'];
        imageUrl = data[0]['image'];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body:SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width*0.05
            ),
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //hamburger icon for drawer
                      IconButton(
                          onPressed: () {

                          }, icon: const Icon(Icons.menu)),

                      //title
                      Text(pharmacy_name,
                          style: GoogleFonts.lato(
                              fontSize: 25, fontWeight: FontWeight.bold)),

                      Row(
                        children: [
                          // IconButton(
                          //     onPressed: (){
                          //       showSearch(
                          //           context: context,
                          //           delegate: CustomSearchDelegate()
                          //       );
                          //     },
                          //     icon: const Icon(
                          //       Icons.search,
                          //       size: 30,
                          //     )
                          // ),
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PharmacyProfilePage()));
                              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewScreen()));
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              backgroundImage: NetworkImage(imageUrl),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: height*0.01,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 22,
                    ),
                    Text('$currentLocation',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                        )
                    )
                  ],
                ),
                SizedBox(height: height*0.05,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categories',
                        style: GoogleFonts.poppins(
                          fontSize: height*0.03,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: height*0.015,),
                      SizedBox(
                        width: width,
                        height: height*0.2,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index){
                            return GestureDetector(
                              onTap: (){},
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CategoriesPage(category: categories[index])));
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      height: height*0.2,
                                      width: width*0.35,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: width*0.03
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage('assets/img/bolcks.png')
                                          )
                                      ),
                                    ),
                                    Container(
                                      height: height*0.2,
                                      width: width*0.35,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width*0.02,
                                          vertical: height*0.01
                                      ),
                                      margin: EdgeInsets.symmetric(
                                        horizontal: width*0.03
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors[index].withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(categories[index],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: height*0.02
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: height*0.05,),
                      Expanded(
                        child: Container(
                          child: StreamBuilder(
                            stream: getPharmacyDrugs(),
                            builder: (context, snapshot){
                              switch (snapshot.connectionState){
                                //if data is loading
                                case ConnectionState.waiting:
                                case ConnectionState.none:
                                  return Center(
                                      child: LoadingAnimationWidget.inkDrop(
                                          color: Colors.deepPurple,
                                          size: height*0.05
                                      )
                                  );

                                //if some or all data is loaded then show it
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  final data = snapshot.data?.docs;
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 9.0,
                                      mainAxisSpacing: 5.0,
                                      childAspectRatio: 0.8
                                    ),
                                    itemCount: data?.length,
                                    itemBuilder: (context, index){
                                      final drugData = data?[index];
                                      return Stack(
                                        fit: StackFit.expand,
                                        alignment: Alignment.bottomLeft,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15)
                                            ),
                                            child: Image.network(
                                              drugData?['image'],
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.bottomLeft,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: width*0.01,
                                              vertical: height*0.01
                                            ),
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.black87,
                                                  Colors.transparent
                                                ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                stops: [
                                                  0.1,
                                                  0.5,
                                                ],
                                              ),
                                              // borderRadius: BorderRadius.circular(15)
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      drugData?['drug_name'],
                                                      style: GoogleFonts.poppins(
                                                          color: Colors.white,
                                                          fontSize: height*0.025,
                                                          fontWeight: FontWeight.w600
                                                      ),
                                                    ),
                                                    Text(
                                                      'ghs ${drugData?['price']}',
                                                      style: GoogleFonts.poppins(
                                                          color: Colors.white,
                                                          fontSize: height*0.02,
                                                          fontWeight: FontWeight.w600
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          )
                                        ],
                                      );
                                    },
                                  );
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddDrugPage()));
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: height*0.02,
        ),
      ),
    );
  }
}
