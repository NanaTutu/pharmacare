import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final first_name;
  final last_name;
  final age;
  final email;
  final phone_number;
  final image;

  UserModel({
    required this.first_name,
    required this.last_name,
    required this.age,
    required this.email,
    required this.phone_number,
    required this.image
  });

  toJson(){
    return {
      "first_name": first_name,
      "last_name":last_name,
      "age":age,
      "email":email,
      "phone_number":phone_number,
      "image":image
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){
    final data = document.data()!;
    return UserModel(
      first_name: data['first_name'],
      last_name: data['last_name'],
      age: data['age'],
      email: data['email'],
      phone_number: data['phone_number'],
      image: data['image']
    );
  }

}