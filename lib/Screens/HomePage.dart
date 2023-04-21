import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/Screens/ProfilePage.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser!;

  //controller
  final _searchbarController = TextEditingController();

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


  @override
  Widget build(BuildContext context) {
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

                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfilePage()));
                              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewScreen()));
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              backgroundImage: AssetImage('assets/img/profilepic.jpg'),
                            ),
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
                        Text('Greater Accra',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                            )
                        )
                      ],
                    ),
                    const SizedBox(height: 30),

                    //search bar text field
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: TextField(
                          controller: _searchbarController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search for drugs',
                            icon: Icon(Icons.search)
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

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
                                          'Pharmacy',
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
                              Container(
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
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 10,),

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
                                    image: AssetImage('assets/img/consultation.jpg'),
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
                                            'Consultation',
                                            style: GoogleFonts.poppins(
                                              fontSize: 25,
                                            )
                                        ),
                                        Text(
                                            'Advice from skilled doctor.',
                                            style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Colors.grey[500]
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              //View Button
                              Container(
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
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

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
                                            image: AssetImage('assets/img/lab.jpg'),
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
                                            'Lab Tests',
                                            style: GoogleFonts.poppins(
                                              fontSize: 25,
                                            )
                                        ),
                                        Text(
                                            'Top diagnostics near you.',
                                            style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Colors.grey[500]
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              //View Button
                              Container(
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
