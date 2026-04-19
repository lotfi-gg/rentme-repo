import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentme/home/home_page.dart';
import 'package:rentme/models/user_model.dart'; // ChatUser model
import 'package:rentme/public%20profile/public_profile.dart'; // PublicProfile widget

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
      backgroundColor: const Color(0xFF121212), // ✅ fond premium anthracite
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Card(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.deepOrangeAccent),
              hintText: 'Search cars...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                search = value.trim().toLowerCase();
              });
            },
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrangeAccent),
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
          const SizedBox(height: 10),
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
                  return const Center(
                    child: Text(
                      "No cars found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
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
          return const SizedBox();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final ownerData = snapshot.data!.data() as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Card(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
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
                      left: Radius.circular(20),
                    ),
                    child: car['img'] != null && car['img'] != ''
                        ? Image.network(
                            car['img'],
                            height: 180,
                            width: 160,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'images/car.png',
                            height: 180,
                            width: 160,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car['vehiclefullname'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Year : ${car['year']?.toString() ?? ''}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),

                          Text(
                            'Transmission : ${car['transmission'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Price : ${car['price']} DA",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          Text(
                            car['status'] ?? 'Available',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Location: ${ownerData['country'] ?? ''}, "
                            "${ownerData['province'] ?? ''}, "
                            "${ownerData['townhall'] ?? ''}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.deepOrangeAccent,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
