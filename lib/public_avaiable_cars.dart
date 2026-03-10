import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PublicAvaiableCars extends StatefulWidget {
  const PublicAvaiableCars({super.key});

  @override
  State<PublicAvaiableCars> createState() => _PublicAvaiableCarsState();
}

class _PublicAvaiableCarsState extends State<PublicAvaiableCars> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('cars')
                  .where('avaiableIn', isEqualTo: 0) // ✅ only available cars
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No available vehicles"));
                }

                final cars = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index].data() as Map<String, dynamic>;
                    return buildCarCard(car);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build the car card UI
  Widget buildCarCard(Map<String, dynamic> car) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 150,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.noHeader,
                animType: AnimType.scale,
                body: SizedBox(
                  width: double.infinity, // full width
                  height:
                      MediaQuery.of(context).size.height * 0.45, // less height
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main car image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: car['img'] != null && car['img'] != ''
                              ? Image.network(
                                  car['img'],
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'images/car.jpg',
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(height: 10),

                        // Gallery of extra images if available
                        if (car['images'] != null)
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (car['images'] as List).length,
                              itemBuilder: (context, index) {
                                final imgUrl = car['images'][index];
                                return Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      imgUrl,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 10),

                        // Car details
                        Text(
                          car['vehiclefullname'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Year: ${car['year'] ?? ''}"),
                        Text("Transmission: ${car['transmission'] ?? ''}"),
                        Text("Price: ${car['price'] ?? ''}"),
                        Text("Status: ${car['status'] ?? 'Available'}"),
                      ],
                    ),
                  ),
                ),
                btnOkOnPress: () {},
              ).show();
            },

            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(25),
                    ),
                    child: car['img'] != null && car['img'] != ''
                        ? Image.network(
                            car['img'],
                            height: double.infinity,
                            width: 200,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'images/car.jpg',
                            height: double.infinity,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(car['vehiclefullname'] ?? ''),
                        const SizedBox(height: 6),
                        Text(car['year']?.toString() ?? ''),
                        const SizedBox(height: 6),
                        Text(car['transmission'] ?? ''),
                        const SizedBox(height: 6),
                        Text(car['price'] ?? ''),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
