import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharmacare/Screens/Productpage.dart';

class PharmacySearchDelegate extends SearchDelegate{

  List<String> searchTerms = [
    'Apple',
    'Banana',
    'Pear',
    'Watermelons',
    'Oranges',
    'Blueberries',
    'Strawberries',
    'Raspberries',
  ];

  final CollectionReference _firebaseFirestore = FirebaseFirestore.instance.collection('drugs');

  Future<List<QueryDocumentSnapshot>> searchDocuments(String searchValue) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('drugs')
        .where('drug_name', arrayContains: searchValue)
        .where('')
        .get();

    return querySnapshot.docs;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: (){
            query = '';
          },
          icon: const Icon(Icons.clear)
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: (){
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseFirestore
          .where('drug_name', isGreaterThanOrEqualTo: query)
          .where('drug_name', isLessThan: query + '\uf8ff')
      // .where('drug_name', arrayContains: query)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final results = snapshot.data!.docs;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = results[index];
            return ListTile(
              title: Text(user['drug_name']),
              subtitle: Text(user['pharmacy_name']),
              onTap: () {
                // close(context, user['name']);
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProductPage(
                  drug_name: user['drug_name'],
                  description: user['description'],
                  pharmacy_location: user['pharmacy_location'],
                  pharmacy_name: user['pharmacy_name'],
                  price: user['price'],
                  image: user['image'],
                  latitude: user['latitude'],
                  longitude: user['longitude'],
                  contact: user['pharmacy_phone'],
                )));
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Center(child: Text('Search anything here'));
    // List<String> matchQuery = [];
    //
    // for(var fruit in searchTerms){
    //   if(fruit.toLowerCase().contains(query.toLowerCase())){
    //     matchQuery.add(fruit);
    //   }
    // }
    // return ListView.builder(
    //   itemCount: matchQuery.length,
    //   itemBuilder: (context, index){
    //     var result = matchQuery[index];
    //     return ListTile(
    //       title: Text(result),
    //     );
    //   }
    // );
  }

}
