import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pharmacare/Screens/ProfilePage.dart';
import 'package:pharmacare/Screens/SearchScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class PharmacyList extends StatefulWidget {
  const PharmacyList({Key? key}) : super(key: key);

  @override
  State<PharmacyList> createState() => _PharmacyListState();
}

class _PharmacyListState extends State<PharmacyList> {

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
  String? currentLocation = 'Location not loaded';

  getCurrentPosition() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // print(position);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks.first;
    // print(placemarks);
    // print(placemark.country);
    // print(placemark.administrativeArea);
    // print(placemark.isoCountryCode);
    // print(placemark.locality);
    // print(placemark.name);
    // print(placemark.postalCode);
    // print(placemark.street);
    // print(placemark.subAdministrativeArea);
    // print(placemark.subLocality);
    // print(placemark.subThoroughfare);
    // print(placemark.thoroughfare);
    setState(() {
      currentLocation = placemark.street;
    });
    // 5.579841750685461, -0.24704438896613737
    // print(Geolocator.distanceBetween(position.latitude, position.longitude, 5.5798, -0.2470));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPharmacies(){
    return FirebaseFirestore.instance.collection('users')
        .where('role', isEqualTo: 'pharmacy')
        .snapshots();
  }

  Future<void> openMap(double latitude, double longitude, {LaunchMode linkLaunchMode = LaunchMode.externalApplication}) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl), mode: linkLaunchMode);
    } else {
      throw 'Could not open the map.';
    }
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        IconButton(
                            onPressed: (){
                              showSearch(
                                  context: context,
                                  delegate: CustomSearchDelegate()
                              );
                            },
                            icon: const Icon(
                              Icons.search,
                              size: 30,
                            )
                        ),
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
              SizedBox(height: height*0.02),
              Expanded(
                child: Container(
                  child: StreamBuilder(
                    stream: getPharmacies(),
                    builder: (context, snapshot){
                      switch(snapshot.connectionState){
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
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: data?.length,
                            itemBuilder: (context, index){
                              final pharmacy = data?[index];
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width*0.05,
                                  vertical: height*0.02
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey.shade300
                                  )
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            pharmacy?['pharmacy_name'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                            ),
                                        ),
                                        Text(
                                          pharmacy?['location'],
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap:() async{
                                            final call = Uri.parse('tel:${pharmacy?['phone_number']}');
                                            if (await canLaunchUrl(call)) {
                                              launchUrl(call);
                                            } else {
                                              throw 'Could not launch $call';
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: width*0.01,
                                            ),
                                            child: Icon(
                                              Icons.phone,
                                              color: Colors.green,
                                              size: height*0.04,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            double lng = double.parse("${pharmacy?['longitude']}");
                                            double lat = double.parse("${pharmacy?['latitude']}");
                                            openMap(lat, lng);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width*0.01
                                            ),
                                            child: Icon(
                                              Icons.map,
                                              color: Colors.deepPurple,
                                              size: height*0.04,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
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
        ),
      ),
    );
  }
}
