import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductPage extends StatefulWidget {
  final String? drug_name, pharmacy_name, pharmacy_location, price, description, image, latitude, longitude, contact;
  const ProductPage({Key? key, this.drug_name, this.pharmacy_name, this.description, this.pharmacy_location, this.price, this.image, this.latitude, this.longitude, this.contact}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {

  Future<void> openMap(double latitude, double longitude, {LaunchMode linkLaunchMode = LaunchMode.externalApplication}) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl), mode: linkLaunchMode);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: height*0.4,
              width: width,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white
                  ),
                    left: BorderSide(
                        color: Colors.white
                    ),
                    right: BorderSide(
                        color: Colors.white
                    )
                )
              ),
              child: Image.network((widget.image) as String, fit: BoxFit.cover,),
            ),
            SizedBox(height: height*0.01,),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width*0.02),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.drug_name}',
                            style: GoogleFonts.poppins(
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            'ghs ${widget.price}',
                            style: GoogleFonts.poppins(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.w600
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: height*0.05,),

                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(height: height*0.01,),
                      Text(
                        '${widget.description}',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.black,
                        ),
                      ),
                      SizedBox(height: height*0.05,),

                      Text(
                        'Location',
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(height: height*0.01,),
                      Text(
                        '${widget.pharmacy_name}, ${widget.pharmacy_location}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: height*0.05,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap:() async{
                              final call = Uri.parse('tel:${widget.contact}');
                              if (await canLaunchUrl(call)) {
                              launchUrl(call);
                              } else {
                              throw 'Could not launch $call';
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width*0.05,
                                vertical: height*0.02
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: Text(
                                'Call Pharmacy',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              double lng = double.parse("${widget.longitude}");
                              double lat = double.parse("${widget.latitude}");
                              openMap(lat, lng);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width*0.05,
                                  vertical: height*0.02
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: Text(
                                'Get Direction',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}
