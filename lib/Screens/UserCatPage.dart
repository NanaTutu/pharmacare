import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pharmacare/Screens/Productpage.dart';
import 'package:pharmacare/Screens/ProfilePage.dart';

class ProdCatPage extends StatefulWidget {
  final String? category;
  const ProdCatPage({Key? key, this.category}) : super(key: key);

  @override
  State<ProdCatPage> createState() => _ProdCatPageState();
}

class _ProdCatPageState extends State<ProdCatPage> {

  Stream<QuerySnapshot<Map<String, dynamic>>> getCategories(){
    return FirebaseFirestore.instance.collection('drugs').where('category', isEqualTo: widget.category).snapshots();
  }

  String? currentLocation = 'Location not loaded';

  getCurrentPosition() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks.first;
    setState(() {
      currentLocation = placemark.street;
    });
    // 5.579841750685461, -0.24704438896613737
    print(Geolocator.distanceBetween(position.latitude, position.longitude, 5.5798, -0.2470));
  }

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

  @override
  void initState() {
    // TODO: implement initState
    getCurrentPosition();
    getUserDetails().then((value) {
      var data = jsonDecode(value);
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
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
                        onPressed: () {}, icon: const Icon(Icons.menu)),

                    //title
                    Text('PharmaCare',
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
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfilePage()));
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
              SizedBox(height: height*0.02,),
              Row(
                children: [
                  Text(
                    '${widget.category}',
                    style: GoogleFonts.poppins(
                        fontSize: height*0.025,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height*0.01,
              ),
              Expanded(
                  child: Container(
                    child: StreamBuilder(
                      stream: getCategories(),
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

                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            return GridView.builder(
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 9.0,
                                  mainAxisSpacing: 5.0,
                                  childAspectRatio: 0.8
                              ),
                              itemCount: data?.length,
                              itemBuilder: (context, index){
                                final drugData = data?[index];
                                return GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProductPage(
                                      drug_name: drugData?['drug_name'],
                                      description: drugData?['description'],
                                      pharmacy_location: drugData?['pharmacy_location'],
                                      pharmacy_name: drugData?['pharmacy_name'],
                                      price: drugData?['price'],
                                      image: drugData?['image'],
                                      latitude: drugData?['latitude'],
                                      longitude:drugData?['longitude'],
                                      contact: drugData?['pharmacy_phone'],
                                    )));
                                  },
                                  child: Stack(
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
                                                        fontSize: height*0.02,
                                                        fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                                  Text(
                                                    'ghs ${drugData?['price']}',
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: height*0.015,
                                                        fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                        }
                      },
                    ),
                  )
              )

            ],
          ),
        ),
      ),
    );
  }
}
