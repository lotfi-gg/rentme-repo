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
    );
  }
}
