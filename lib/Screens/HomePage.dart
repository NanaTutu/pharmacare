import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geofencing/geofencing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/Screens/PharmacyList.dart';
// import 'package:location/location.dart';
import 'package:pharmacare/Screens/ProfilePage.dart';
import 'package:pharmacare/Screens/SearchScreen.dart';
import 'package:pharmacare/Screens/UserCatPage.dart';
import 'package:pharmacare/Util/UserModel.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser!;

  //controller
  final _searchbarController = TextEditingController();
  String? currentLocation = 'Location not loaded';

  List<String> imagePath = [
    'assets/img/pharmacy001.jpg',
    'assets/img/pharmacy002.jpg',
    'assets/img/pharmacy003.jpg'
  ];

  List<String> names = [
    'LifeAid',
    'Mary De Rose',
    'PharmaLife'
  ];



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

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  bool _isInGeofence = false;

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

  List<QueryDocumentSnapshot> nearbyLocation= [];

  getPharmacies() async{
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'pharmacy')
        .get();

    List<QueryDocumentSnapshot> locations = querySnapshot.docs;

    double radius = 1000; // 1000 meters = 1 kilometer
    List<QueryDocumentSnapshot> nearbyLocations = [];

    for (QueryDocumentSnapshot location in locations) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        location['latitude'],
        location['longitude'],
      );

      if (distance <= radius) {
        nearbyLocations.add(location);
        setState(() {
          nearbyLocation = nearbyLocations;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getCurrentPosition();
    getPharmacies();
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // header
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
                    //location
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
                    // const SizedBox(height: 30),
                    //
                    // //search bar text field
                    // Container(
                    //   decoration: BoxDecoration(
                    //       color: Colors.grey[200],
                    //       border: Border.all(color: Colors.white),
                    //       borderRadius: BorderRadius.circular(12)),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(left: 20),
                    //     child: TextField(
                    //       controller: _searchbarController,
                    //       decoration: const InputDecoration(
                    //         border: InputBorder.none,
                    //         hintText: 'Search for drugs',
                    //         icon: Icon(Icons.search)
                    //       ),
                    //       onTap: (){
                    //         showSearch(
                    //           context: context,
                    //           delegate: CustomSearchDelegate()
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 50),

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
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProdCatPage(category: categories[index])));
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
                    SizedBox(height: height*0.02,),

                    //Options
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  //image
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(15),
                                      image: const DecorationImage(
                                        image: AssetImage('assets/img/pharmacy.jpg'),
                                        fit: BoxFit.cover
                                      )
                                    ),
                                  ),
                                  SizedBox(width: 10,),

                                  //title and description
                                  SizedBox(
                                    height: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pharmacies',
                                            style: GoogleFonts.poppins(
                                                fontSize: 25,
                                            )
                                        ),
                                        Text(
                                          'Get verified medicines',
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                            color: Colors.grey[500]
                                          )
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                             //View Button
                              GestureDetector(
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PharmacyList()));
                                },
                                child: Container(
                                  padding:const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Text(
                                    'View',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.green
                                    )
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pharmacies near you',
                          style: GoogleFonts.poppins(
                              fontSize: 25,
                          ),
                        ),
                        Text(
                            'See all',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.green
                            )
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                  height: 200,
                                  width: 150,
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            image: DecorationImage(
                                                image: AssetImage(imagePath[index]),
                                                fit: BoxFit.fill
                                            )
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          gradient: const LinearGradient(
                                              colors: [
                                                Colors.black,
                                                Colors.transparent
                                              ],
                                              begin: FractionalOffset(0.0, 1.0),
                                              end: FractionalOffset(0.0, 0.0),
                                              stops: [0.0, 1.0],
                                              tileMode: TileMode.clamp
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                                names[index],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                )
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                              ),
                            ],
                          );
                        },
                      ),
                    )


                    // Text(
                    //   'Signed In ${user.email!}',
                    //   style: GoogleFonts.lato(
                    //       fontSize: 30,
                    //       fontWeight: FontWeight.bold
                    //   ),
                    // ),
                    // MaterialButton(
                    //   onPressed: (){
                    //     FirebaseAuth.instance.signOut();
                    //   },
                    //   color: Colors.deepPurple[200],
                    //   child: const Text('Sign out'),
                    // )
                  ],
                )),
          ),
        ));
  }
}
