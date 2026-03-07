import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentme/home_page.dart';
import 'package:rentme/models/user_model.dart'; // ChatUser model
import 'package:rentme/public_profile.dart'; // PublicProfile widget

class SearchByCar extends StatefulWidget {
  const SearchByCar({super.key});

  @override
  State<SearchByCar> createState() => _SearchByCarState();
}

class _SearchByCarState extends State<SearchByCar> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Card(
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'search ..',
            ),
            onChanged: (value) {
              setState(() {
                search = value.trim().toLowerCase();
              });
            },
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cars')
                  .where(
                    'ownerId',
                    isNotEqualTo: FirebaseAuth.instance.currentUser!.uid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No cars found"));
                }

                final cars = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index].data() as Map<String, dynamic>;

                    final vehicleName =
                        car['vehiclefullname']
                            ?.toString()
                            .toLowerCase()
                            .trim() ??
                        '';
                    final year =
                        car['year']?.toString().toLowerCase().trim() ?? '';

                    if (search.isEmpty ||
                        vehicleName.contains(search) ||
                        year.contains(search)) {
                      return buildCarCard(car);
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCarCard(Map<String, dynamic> car) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(car['ownerId'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("");
        }

        final ownerData = snapshot.data!.data() as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            height: 180,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: InkWell(
                onTap: () {
                  final ownerUser = ChatUser.fromJson(ownerData);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PublicProfile(user: ownerUser),
                    ),
                  );
                },
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(car['vehiclefullname'] ?? ''),

                          Text(car['year']?.toString() ?? ''),

                          Text(car['transmission'] ?? ''),

                          Text(car['price'] ?? ''),

                          Text(car['status'] ?? 'Available'),

                          // ✅ Show location from owner profile
                          Text(
                            "Location: ${ownerData['country'] ?? ''}, "
                            "${ownerData['province'] ?? ''}, "
                            "${ownerData['townhall'] ?? ''}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
