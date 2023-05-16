import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  //controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phone_number = TextEditingController();
  final _pharmacyNameController = TextEditingController();
  final _pharmacy_location = TextEditingController();
  final _pharmacy_contact = TextEditingController();
  final _pharmacy_email = TextEditingController();

  double? longitude;
  double? latitude;

  String? groupValue = 'Customer';

  bool _isVisible = true;
  bool _confirmVisible = true;
  bool _isVisiblePharma = true;
  bool _confirmVisiblePharma = true;
  Icon visiblity = const Icon(Icons.visibility);
  Icon visibilityOff = const Icon(Icons.visibility_off);

  getCurrentLocation() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      longitude = position.longitude;
      latitude = position.latitude;
    });
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks.first;
    setState(() {
      String? location = '${placemark.street}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}';
      print(location);
      _pharmacy_location.text = location;
    });
  }

  Future signup() async{
    if(passwordConfirmed()) {
      //create user
      try{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim()
        );

        //add user details
        addUserDetails(
            _firstNameController.text.trim(),
            _lastNameController.text.trim(),
            _emailController.text.trim(),
            int.parse(_ageController.text.trim()),
          _phone_number.text.trim()
        );
      } on FirebaseAuthException catch(e){
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: e.message.toString(),
        );
      }
    }else{
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'Oops...',
        text: 'Your passwords do not match',
      );
    }
  }

  Future registerPharmacy() async{
    if(passwordConfirmed()) {
      //create user

      try{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _pharmacy_email.text.trim(),
            password: _passwordController.text.trim()
        );

        //add pharmacy details
        addPharmacyDetails(
            _pharmacyNameController.text.trim(),
            _pharmacy_email.text.trim(),
            _pharmacy_location.text.trim(),
            longitude.toString(),
            latitude.toString(),
            _pharmacy_contact.text.trim(),
        );
      } on FirebaseAuthException catch(e){
        print('error');
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: e.message.toString(),
        );
      }
    }else{
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'Oops...',
        text: 'Your passwords do not match',
      );
    }
  }

  Future addUserDetails(String firstname, String lastname, String email, int age, String phoneNumber) async{
    await FirebaseFirestore.instance.collection('users').add({
      'first_name': firstname,
      'last_name': lastname,
      'email': email,
      'age': age,
      'phone_number': phoneNumber,
      'image' : 'https://firebasestorage.googleapis.com/v0/b/pharmacare-f61b6.appspot.com/o/images%2Fprofile%20pics%2Fplaceholder.png?alt=media&token=980198b3-8c2d-4dce-9552-320e273c2bc6',
      'role': 'member'
    });
  }

  Future addPharmacyDetails(String name, String email, String location, String? longitude, String? latitude, String contact) async{
    await FirebaseFirestore.instance.collection('users').add(
      {
        'pharmacy_name': name,
        'phone_number': contact,
        'latitude': latitude,
        'location': location,
        'longitude': longitude,
        'email': email,
        'role': 'pharmacy',
        'image' : 'https://firebasestorage.googleapis.com/v0/b/pharmacare-f61b6.appspot.com/o/images%2Fprofile%20pics%2Fplaceholder.png?alt=media&token=980198b3-8c2d-4dce-9552-320e273c2bc6'
      }
    );

  }

  bool passwordConfirmed(){
    if(_passwordController.text.trim() == _confirmPasswordController.text.trim()){
      return true;
    }else{
      return false;
    }
  }

  Widget customerForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Phone Number'
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
                obscureText: _isVisible,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: _isVisible?visiblity:visibilityOff,
                      color: Colors.grey,
                      onPressed: () {
                        // print('i can see now');
                        if(_isVisible){
                          setState(() {
                            _isVisible = false;
                          });
                        }else{
                          setState(() {
                            _isVisible = true;
                          });
                        }
                      },
                    ),

                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        //password textfield
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
                controller: _confirmPasswordController,
                obscureText: _confirmVisible,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: _confirmVisible?visiblity:visibilityOff,
                    color: Colors.grey,
                    onPressed: () {
                      // print('i can see now');
                      if(_confirmVisible){
                        setState(() {
                          _confirmVisible = false;
                        });
                      }else{
                        setState(() {
                          _confirmVisible = true;
                        });
                      }
                    },
                  ),
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
            onTap: signup,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: const Center(
                child: Text(
                  'Sign Up',
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
            const Text(
              'Already a member? ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
            GestureDetector(
              onTap: widget.showLoginPage,
              child: const Text(
                'Sign In',
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
    );
  }

  Widget pharmacyForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //Name textfield
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
                    hintText: 'Name'
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
                controller: _pharmacy_email,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Email',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        //Location textfield
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
                controller: _pharmacy_location,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Location',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      color: Colors.grey,
                      onPressed: (){
                        getCurrentLocation();
                      },
                    )
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        //contact textfield
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
                controller: _pharmacy_contact,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Contact'
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
                obscureText: _isVisiblePharma,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: _isVisiblePharma?visiblity:visibilityOff,
                    color: Colors.grey,
                    onPressed: () {
                      // print('i can see now');
                      if(_isVisiblePharma){
                        setState(() {
                          _isVisiblePharma = false;
                        });
                      }else{
                        setState(() {
                          _isVisiblePharma = true;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        //password textfield
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
                controller: _confirmPasswordController,
                obscureText: _confirmVisiblePharma,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: _confirmVisiblePharma?visiblity:visibilityOff,
                    color: Colors.grey,
                    onPressed: () {
                      // print('i can see now');
                      if(_confirmVisiblePharma){
                        setState(() {
                          _confirmVisiblePharma = false;
                        });
                      }else{
                        setState(() {
                          _confirmVisiblePharma = true;
                        });
                      }
                    },
                  ),
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
            onTap: registerPharmacy,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: const Center(
                child: Text(
                  'Sign Up',
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
            const Text(
              'Already a member? ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
            GestureDetector(
              onTap: widget.showLoginPage,
              child: const Text(
                'Sign In',
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
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _confirmPasswordController.dispose();
    _phone_number.dispose();
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
                      'Hello there, Welcome',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Register as:',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: RadioListTile(
                            title: Text("Customer"),
                            value: "Customer",
                            groupValue: groupValue,
                            onChanged: (value){
                              print(value.toString());
                              setState(() {
                                groupValue = value.toString();
                              });
                            },
                          ),
                        ),
                        
                        Flexible(
                          child: RadioListTile(
                            title: Text("Pharmacy"),
                            value: "Pharmacy",
                            groupValue: groupValue,
                            onChanged: (value){
                              print(value.toString());
                              setState(() {
                                groupValue = value.toString();
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    groupValue == 'Customer' ?
                        customerForm():
                        pharmacyForm()
                  ],
                )
              ),
            )
        )
    );
  }
}
